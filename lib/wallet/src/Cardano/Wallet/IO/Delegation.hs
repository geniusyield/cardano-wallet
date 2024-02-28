{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}

-- |
-- Copyright: © 2024 Cardano Foundation
-- License: Apache-2.0
--
-- Delegation functionality used by Daedalus.
--
module Cardano.Wallet.IO.Delegation
    ( selectCoinsForJoin
    , selectCoinsForQuit
    )
    where

import Prelude

import Cardano.Pool.Types
    ( PoolId
    )
import Cardano.Wallet
    ( WalletLayer
    , dbLayer
    , logger
    , networkLayer
    , transactionLayer
    )
import Cardano.Wallet.Address.Book
    ( AddressBookIso
    )
import Cardano.Wallet.Address.Derivation
    ( DelegationAddress (..)
    , Depth (..)
    , DerivationType (..)
    , HardDerivation (..)
    , delegationAddressS
    )
import Cardano.Wallet.Address.Derivation.SharedKey
    ( SharedKey
    )
import Cardano.Wallet.Address.Derivation.Shelley
    ( ShelleyKey
    )
import Cardano.Wallet.Address.Discovery
    ( GenChange (..)
    , IsOurs
    )
import Cardano.Wallet.Address.Discovery.Sequential
    ( SeqState (..)
    )
import Cardano.Wallet.Flavor
    ( Excluding
    , WalletFlavor (..)
    , keyOfWallet
    )
import Cardano.Wallet.Network
    ( NetworkLayer (..)
    )
import Cardano.Wallet.Primitive.NetworkId
    ( HasSNetworkId
    )
import Cardano.Wallet.Primitive.Passphrase
    ( Passphrase
    )
import Cardano.Wallet.Primitive.Types
    ( PoolLifeCycleStatus
    , ProtocolParameters (..)
    , WalletId
    )
import Cardano.Wallet.Primitive.Types.RewardAccount
    ( RewardAccount
    )
import Cardano.Wallet.Transaction
    ( PreSelection (..)
    , TransactionCtx (..)
    , defaultTransactionCtx
    )
import Data.Functor.Contravariant
    ( (>$<)
    )
import Data.Generics.Internal.VL.Lens
    ( (^.)
    )
import Data.Set
    ( Set
    )
import Data.Time.Clock
    ( UTCTime
    )

import qualified Cardano.Wallet as W
import qualified Cardano.Wallet.Address.Discovery.Sequential as Seq
import qualified Cardano.Wallet.Delegation as WD
import qualified Internal.Cardano.Write.Tx as Write

{-----------------------------------------------------------------------------
    Delegation
------------------------------------------------------------------------------}
-- | Perform a coin selection for a transaction that joins a stake pool.
selectCoinsForJoin
    :: forall s n k.
        ( s ~ SeqState n k
        , WalletFlavor s
        , Excluding '[SharedKey] k
        , AddressBookIso s
        , Seq.SupportsDiscovery n k
        , DelegationAddress k 'CredFromKeyK
        )
    => WalletLayer IO s
    -> Set PoolId
    -> PoolId
    -> PoolLifeCycleStatus
    -> IO W.CoinSelection
selectCoinsForJoin ctx pools poolId poolStatus = do
    (Write.PParamsInAnyRecentEra era pp, timeTranslation)
        <- W.readNodeTipStateForTxWrite netLayer
    currentEpochSlotting <- W.getCurrentEpochSlotting netLayer

    action <- WD.joinStakePoolDelegationAction @s
        (W.MsgWallet >$< (ctx ^. logger))
        db
        currentEpochSlotting
        pools
        poolId
        poolStatus

    let changeAddrGen = W.defaultChangeAddressGen (delegationAddressS @n)

    optionalVoteAction <-
        W.handleVotingWhenMissingInConway era db

    let txCtx = defaultTransactionCtx
            { txDelegationAction = Just action
            , txVotingAction = optionalVoteAction
            , txDeposit = Just $ W.getStakeKeyDeposit pp
            }

    let paymentOuts = []

    (tx, walletState) <-
        W.buildTransaction @s era
            db timeTranslation changeAddrGen pp txCtx paymentOuts

    pure
        $ W.buildCoinSelectionForTransaction @s @n
            walletState
            paymentOuts
            (W.getStakeKeyDeposit pp)
            (Just action)
            tx
  where
    db = ctx ^. dbLayer
    netLayer = ctx ^. networkLayer

-- | Perform a coin selection for a transactions that quits a stake pool.
selectCoinsForQuit
    :: forall s n k.
        ( s ~ SeqState n k
        , WalletFlavor s
        , Excluding '[SharedKey] k
        , AddressBookIso s
        , Seq.SupportsDiscovery n k
        , DelegationAddress k 'CredFromKeyK
        )
    => WalletLayer IO s
    -> IO W.CoinSelection
selectCoinsForQuit ctx = do
    (Write.PParamsInAnyRecentEra era pp, timeTranslation)
        <- W.readNodeTipStateForTxWrite netLayer
    currentEpochSlotting <- W.getCurrentEpochSlotting netLayer

    withdrawal <- W.shelleyOnlyMkSelfWithdrawal
        netLayer
        (W.txWitnessTagForKey $ keyOfWallet $ walletFlavor @s)
        db

    action <- WD.quitStakePoolDelegationAction
        db currentEpochSlotting withdrawal

    let changeAddrGen = W.defaultChangeAddressGen (delegationAddressS @n)

    let txCtx = defaultTransactionCtx
            { txDelegationAction = Just action
            , txWithdrawal = withdrawal
            , txDeposit = Just $ W.getStakeKeyDeposit pp
            }

    let paymentOuts = []

    (tx, walletState) <-
        W.buildTransaction @s era
            db timeTranslation changeAddrGen pp txCtx paymentOuts

    pure
        $ W.buildCoinSelectionForTransaction @s @n
            walletState
            paymentOuts
            (W.getStakeKeyDeposit pp)
            (Just action)
            tx
  where
    db = ctx ^. dbLayer
    netLayer = ctx ^. networkLayer

