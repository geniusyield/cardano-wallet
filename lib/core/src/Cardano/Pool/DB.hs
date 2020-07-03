{-# LANGUAGE DataKinds #-}
{-# LANGUAGE ExistentialQuantification #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE RankNTypes #-}

-- |
-- Copyright: © 2018-2020 IOHK
-- License: Apache-2.0
--
-- Database / Persistence layer for the pool production.

module Cardano.Pool.DB
    ( -- * Interface
      DBLayer (..)

    , PoolRegistrationStatus (..)
    , determinePoolRegistrationStatus
    , readPoolRegistrationStatus

      -- * Errors
    , ErrPointAlreadyExists (..)
    ) where

import Prelude

import Cardano.Wallet.Primitive.Types
    ( BlockHeader
    , EpochNo (..)
    , PoolId
    , PoolRegistrationCertificate
    , PoolRetirementCertificate
    , SlotId (..)
    , SlotInternalIndex (..)
    , StakePoolMetadata
    , StakePoolMetadataHash
    , StakePoolMetadataUrl
    )
import Control.Monad.Fail
    ( MonadFail )
import Control.Monad.IO.Class
    ( MonadIO )
import Control.Monad.Trans.Except
    ( ExceptT )
import Data.Map.Strict
    ( Map )
import Data.Quantity
    ( Quantity (..) )
import Data.Word
    ( Word64 )
import System.Random
    ( StdGen )

-- | A Database interface for storing pool production in DB.
--
-- To use it, you will need the NamedFieldPuns extension and wrap operations
-- with @atomically@:
--
-- Example:
--
-- >>> :set -XNamedFieldPuns
-- >>> DBLayer{atomically,putPoolProduction} = db
-- >>> atomically $ putPoolProduction blockHeader pool
--
-- This gives you the power to also run /multiple/ operations atomically.
--
-- FIXME: Allowing 'MonadIO' to enable logging also within db transactions.
-- Ideally, we should lower than constraint to only allow logging effects and
-- not any dragons in IO.
data DBLayer m = forall stm. (MonadFail stm, MonadIO stm) => DBLayer
    { putPoolProduction
        :: BlockHeader
        -> PoolId
        -> ExceptT ErrPointAlreadyExists stm ()
        -- ^ Write for a given slot id the id of stake pool that produced a
        -- a corresponding block

    , readPoolProduction
        :: EpochNo
        -> stm (Map PoolId [BlockHeader])
        -- ^ Read the all stake pools together with corresponding slot ids
        -- for a given epoch.

    , readTotalProduction
        :: stm (Map PoolId (Quantity "block" Word64))
        -- ^ Read the total pool production since the pool was first registered.

    , putStakeDistribution
        :: EpochNo
        -> [(PoolId, Quantity "lovelace" Word64)]
        -> stm ()
        -- ^ Replace an existing distribution for the given epoch by the one
        -- given as argument.
        --
        -- If there's no existing distribution, simply inserts it.

    , readStakeDistribution
        :: EpochNo
        -> stm [(PoolId, Quantity "lovelace" Word64)]

    , readPoolProductionCursor
        :: Int
        -> stm [BlockHeader]
        -- ^ Read the latest @k@ blockheaders in ascending order. The tip will
        -- be the last element in the list.
        --
        -- This is useful for the @NetworkLayer@ to know how far we have synced.

    , putPoolRegistration
        :: SlotIndex
        -> PoolRegistrationCertificate
        -> stm ()
        -- ^ Add a mapping between stake pools and their corresponding
        -- certificate. If the mapping already exists, data are replaced with
        -- the latest version.

    , readPoolRegistration
        :: PoolId
        -> stm (Maybe (SlotIndex, PoolRegistrationCertificate))
        -- ^ Find a registration certificate associated to a given pool

    , putPoolRetirement
        :: SlotIndex
        -> PoolRetirementCertificate
        -> stm ()
        -- ^ Add a retirement certificate for a particular pool.

    , readPoolRetirement
        :: PoolId
        -> stm (Maybe (SlotIndex, PoolRetirementCertificate))
        -- ^ Find a retirement certificate for a particular pool.

    , unfetchedPoolMetadataRefs
        :: Int
        -> stm [(StakePoolMetadataUrl, StakePoolMetadataHash)]
        -- ^ Read the list of metadata remaining to fetch from remote server,
        -- possibly empty if every pool already has an associated metadata
        -- cached.
        --
        -- It returns at most `n` results, where `n` is the first argument.

    , putFetchAttempt
        :: (StakePoolMetadataUrl, StakePoolMetadataHash)
        -> stm ()
        -- ^ Store a fetch attempt for a given hash, so that it isn't retried
        -- too often.

    , listRegisteredPools
        :: stm [PoolId]
        -- ^ List the list of known pools, based on their registration
        -- certificate. This list doesn't necessarily match the keys of the
        -- map we would get from 'readPoolProduction' because not all registered
        -- pools have necessarily produced any block yet!

    , putPoolMetadata
        :: StakePoolMetadataHash
        -> StakePoolMetadata
        -> stm ()
        -- ^ Store metadata fetched from a remote server.

    , readPoolMetadata
        :: stm (Map StakePoolMetadataHash StakePoolMetadata)

    , readSystemSeed
        :: stm StdGen
        -- ^ Read the seed assigned to this particular database. The seed is
        -- created with the database and is "unique" for each database. This
        -- however allow to have a seed that can be used to produce consistent
        -- results across requests.

    , rollbackTo
        :: SlotId
        -> stm ()
        -- ^ Remove all entries of slot ids newer than the argument

    , cleanDB
        :: stm ()
        -- ^ Clean a database

    , atomically
        :: forall a. stm a -> m a
        -- ^ Run an operation.
        --
        -- For a Sqlite DB, this would be "run a query inside a transaction".
    }

type SlotIndex = (SlotId, SlotInternalIndex)

data PoolRegistrationStatus
    = PoolNotRegistered
        -- ^ Indicates that a pool is not registered.
    | PoolRegistered
        PoolRegistrationCertificate
        -- ^ Indicates that a pool is registered BUT NOT marked for retirement.
        -- Records the latest registration certificate.
    | PoolRegisteredAndRetired
        PoolRegistrationCertificate
        PoolRetirementCertificate
        -- ^ Indicates that a pool is registered AND ALSO marked for retirement.
        -- Records the latest registration and retirement certificates.
    deriving (Eq, Show)

determinePoolRegistrationStatus
    :: Maybe (SlotIndex, PoolRegistrationCertificate)
    -> Maybe (SlotIndex, PoolRetirementCertificate)
    -> PoolRegistrationStatus
determinePoolRegistrationStatus = f
  where
    f Nothing _ =
        PoolNotRegistered
    f (Just (_, regCert)) Nothing =
        PoolRegistered regCert
    f (Just (regTime, regCert)) (Just (retTime, retCert))
        | regTime > retTime =
            PoolRegistered regCert
        | otherwise =
            PoolRegisteredAndRetired regCert retCert

readPoolRegistrationStatus
    :: DBLayer m
    -> PoolId
    -> m PoolRegistrationStatus
readPoolRegistrationStatus
    DBLayer {atomically, readPoolRegistration, readPoolRetirement} poolId =
        atomically $ determinePoolRegistrationStatus
            <$> readPoolRegistration poolId
            <*> readPoolRetirement poolId

-- | Forbidden operation was executed on an already existing slot
newtype ErrPointAlreadyExists
    = ErrPointAlreadyExists BlockHeader -- Point already exists in db
    deriving (Eq, Show)
