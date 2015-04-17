{-# LANGUAGE OverloadedStrings #-}
module Network.Wai.Middleware.HandleReverseProxyHeadersSpec
    ( main
    , spec
    ) where

import Test.Hspec

import Data.Default.Class (Default (def))

import Data.Function (on)

import Network.Socket

import Network.Wai.Middleware.HandleReverseProxyHeaders
import Network.Wai.Test
import Network.Wai
import Network.Wai.Internal (ResponseReceived(..))

main :: IO ()
main = hspec spec

spec :: Spec
spec =
  describe "handleReverseProxyHeaders" $ do
    it "does not modify a request that does not originate from a trusted reverse proxy" $ do
      reqAddr <- inet_addr "127.0.0.2"
      let req =
            defaultRequest { remoteHost =
                               SockAddrInet
                                 1234 -- port number
                                 reqAddr
                           }
      ResponseReceived <- handleReverseProxyHeaders def
        (\req' _ -> do
            (shouldBe `on` remoteHost       ) req' req
            (shouldBe `on` requestHeaders   ) req' req
            (shouldBe `on` isSecure         ) req' req
            (shouldBe `on` requestHeaderHost) req' req
            return ResponseReceived
        )
        req
        (const (return ResponseReceived))
      return ()
