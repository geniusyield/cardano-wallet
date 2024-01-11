-- |
-- Copyright: © 2018-2024 IOHK
-- License: Apache-2.0
--
-- Provides functions to launch cardano-nodes in a cluster for /testing/.
module Cardano.Wallet.Launch.Cluster
    ( -- * Local test cluster launcher
      withCluster
    , withFaucet
    , Config (..)
    , ShelleyGenesisModifier
    , TestnetMagic (..)
    , ClusterEra (..)
    , FaucetFunds (..)

      -- * Node launcher
    , NodeParams (..)
    , singleNodeParams
    , RunningNode (..)

      -- * Cluster node launcher
    , defaultPoolConfigs
    , clusterEraFromEnv
    , localClusterConfigsFromEnv
    , clusterEraToString
    , withSMASH

      -- * Configuration
    , LogFileConfig (..)
    , logFileConfigFromEnv
    , minSeverityFromEnv
    , nodeMinSeverityFromEnv
    , walletMinSeverityFromEnv
    , testMinSeverityFromEnv
    , testLogDirFromEnv
    , genTopology

      -- * Faucets
    , Credential (..)
    , sendFaucetFundsTo
    , sendFaucetAssetsTo
    , moveInstantaneousRewardsTo
    , genMonetaryPolicyScript

      -- * Logging
    , ClusterLog (..)
    ) where

import Cardano.Wallet.Launch.Cluster.Cluster
    ( FaucetFunds (..)
    , withCluster
    )
import Cardano.Wallet.Launch.Cluster.ClusterEra
    ( ClusterEra (..)
    , clusterEraFromEnv
    , clusterEraToString
    , localClusterConfigsFromEnv
    )
import Cardano.Wallet.Launch.Cluster.Config
    ( Config (..)
    , ShelleyGenesisModifier
    , TestnetMagic (..)
    )
import Cardano.Wallet.Launch.Cluster.Faucet
    ( sendFaucetAssetsTo
    , sendFaucetFundsTo
    , withFaucet
    )
import Cardano.Wallet.Launch.Cluster.InstantaneousRewards
    ( Credential (..)
    , moveInstantaneousRewardsTo
    )
import Cardano.Wallet.Launch.Cluster.Logging
    ( ClusterLog (..)
    , LogFileConfig (..)
    , logFileConfigFromEnv
    , minSeverityFromEnv
    , nodeMinSeverityFromEnv
    , testLogDirFromEnv
    , testMinSeverityFromEnv
    , walletMinSeverityFromEnv
    )
import Cardano.Wallet.Launch.Cluster.MonetaryPolicyScript
    ( genMonetaryPolicyScript
    )
import Cardano.Wallet.Launch.Cluster.Node.GenTopology
    ( genTopology
    )
import Cardano.Wallet.Launch.Cluster.Node.NodeParams
    ( NodeParams (..)
    , singleNodeParams
    )
import Cardano.Wallet.Launch.Cluster.Node.RunningNode
    ( RunningNode (..)
    )
import Cardano.Wallet.Launch.Cluster.PoolRecipe
    ( defaultPoolConfigs
    )
import Cardano.Wallet.Launch.Cluster.SMASH
    ( withSMASH
    )
import Data.Generics.Labels
    ()
