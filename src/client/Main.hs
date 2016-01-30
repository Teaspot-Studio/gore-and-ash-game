module Main where  

import Control.DeepSeq 
import Control.Monad (join)
import Control.Monad.IO.Class
import Data.Maybe (fromMaybe)
import Data.Proxy 
import FPS
import Linear (V4(..))
import Network.BSD (getHostByName, hostAddress)
import Network.Socket (SockAddr(..))
import System.Environment
import Text.Read 

import Game.GoreAndAsh
import Game.GoreAndAsh.Network
import Game.GoreAndAsh.SDL
import Game.GoreAndAsh.Sync

import Consts
import Game 
import Game.Core 

gameFPS :: Int 
gameFPS = 60 

parseArgs :: IO (String, Int)
parseArgs = do 
  args <- getArgs 
  case args of 
    [h, p] -> case readMaybe p of 
      Nothing -> fail "Failed to parse port"
      Just pint -> return (h, pint)
    _ -> fail "Misuse of arguments: gore-and-ash-client HOST PORT"


main :: IO ()
main = withModule (Proxy :: Proxy AppMonad) $ do
  gs <- newGameState mainWire
  (host, port) <- liftIO parseArgs
  fps <- makeFPSBounder 60
  firstLoop fps host port gs 
  where 
    -- | Resolve given hostname and port
    getAddr s p = do
      he <- getHostByName s
      return $ SockAddrInet p $ hostAddress he

    firstLoop fps host port gs = do 
      (_, gs') <- stepGame gs $ do 
        networkSetDetailedLoggingM False
        syncSetLoggingM False
        syncSetRoleM SyncSlave
        networkBind Nothing 1 2 0 0
        addr <- liftIO $ getAddr host (fromIntegral port)
        _ <- networkConnect addr 2 0
        _ <- sdlCreateWindowM mainWindowName "Gore&Ash Client" defaultWindow defaultRenderer
        sdlSetBackColor mainWindowName $ V4 200 200 200 255
      gameLoop fps gs'

    gameLoop fps gs = do
      waitFPSBound fps 
      (mg, gs') <- stepGame gs (return ())
      mg `deepseq` if fromMaybe False $ gameExit <$> join mg
        then cleanupGameState gs'
        else gameLoop fps gs'