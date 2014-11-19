{-# LANGUAGE RecordWildCards #-}

module Network.Wai.Handler.Warp.HTTP2.Timeout where

import Control.Reaper
import qualified Data.Foldable as F
import Data.IORef (readIORef, writeIORef)
import Data.IntMap.Strict as M
import Network.Wai.Handler.Warp.HTTP2.Types
import System.IO.Unsafe

initialize :: IO (Reaper (IntMap Stream) (Int, Stream))
initialize = mkReaper defaultReaperSettings
    { reaperAction = clean
    , reaperDelay = 10 -- checkme
    , reaperCons = uncurry M.insert
    , reaperNull = M.null
    , reaperEmpty = empty
    }

clean :: IntMap Stream -> IO (IntMap Stream -> IntMap Stream)
clean old = do
    let (inactive, active) = partition prune old
    F.mapM_ gonext inactive
    -- side-effect to active
    F.mapM_ inactivate active
    return $ union active
  where
    prune Stream{..} = unsafePerformIO $ do
        x <- readIORef streamActivity
        return $ x == Active
    gonext Stream{..} = do
        act <- readIORef streamTimeoutAction
        act
    inactivate Stream{..} = writeIORef streamActivity Inactive
