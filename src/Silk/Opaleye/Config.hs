{-# LANGUAGE Rank2Types #-}
module Silk.Opaleye.Config
  ( Config
  , connectionPool
  , maxTries
  , beforeTransaction
  , afterTransaction

  , makeConfig
  , defaultConfig
  , defaultBeforeTransaction
  , defaultAfterTransaction
  , setCallbacks

  , defaultPool
  ) where

import Data.Pool (Pool, createPool)
import Database.PostgreSQL.Simple (ConnectInfo (..), Connection)
import qualified Database.PostgreSQL.Simple as PG

data Config a = Config
  { connectionPool    :: Pool Connection
  , maxTries          :: Int
  , beforeTransaction :: IO a
  , afterTransaction  :: a -> IO ()
  }

type Config_ = Config ()

makeConfig :: Pool Connection -> Config_
makeConfig pc = Config
  { connectionPool    = pc
  , maxTries          = 3
  , beforeTransaction = defaultBeforeTransaction
  , afterTransaction  = defaultAfterTransaction
  }

setCallbacks :: Config a -> IO b -> (b -> IO ()) -> Config b
setCallbacks cfg before after = cfg
  { beforeTransaction = before
  , afterTransaction  = after
  }

defaultConfig :: ConnectInfo -> IO (Config ())
defaultConfig = fmap makeConfig . defaultPool

defaultPool :: ConnectInfo -> IO (Pool Connection)
defaultPool connectInfo = createPool (PG.connect connectInfo) PG.close 10 5 10

defaultBeforeTransaction :: IO ()
defaultBeforeTransaction = return ()

defaultAfterTransaction :: a -> IO ()
defaultAfterTransaction = const (return ())
