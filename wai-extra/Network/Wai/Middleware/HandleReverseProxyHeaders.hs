module Network.Wai.Middleware.HandleReverseProxyHeaders
  ( handleReverseProxyHeaders
  , TrustedReverseProxy(..)
  , HandleReverseProxyHeadersSettings
  , trustedReverseProxies
  )
where

import Data.Default.Class (Default (def))

import Network.Socket
import Network.Wai

data TrustedReverseProxy =
    TrustedReverseProxyInet HostAddress
  | TrustedReverseProxyInet6 HostAddress6

data HandleReverseProxyHeadersSettings =
  HandleReverseProxyHeadersSettings
    { trustedReverseProxies :: [TrustedReverseProxy]
    }


instance Default HandleReverseProxyHeadersSettings where
  def =
    HandleReverseProxyHeadersSettings
      { trustedReverseProxies = [ TrustedReverseProxyInet
                                    -- TODO: better way to get the raw
                                    --       HostAddress as this will probably
                                    --       break on non little endian
                                    --       systems
                                    16777343 -- 127.0.0.1
                                -- TODO: add ::1
                                ]
      }

handleReverseProxyHeaders :: HandleReverseProxyHeadersSettings -> Middleware
handleReverseProxyHeaders _ app = app
