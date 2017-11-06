module Network.DNS.Types.Internal where

import Data.List.NonEmpty (NonEmpty(..))
import Network.Socket (AddrInfo(..), PortNumber(..), HostName)
import Data.Word (Word16)

----------------------------------------------------------------

-- | The type to specify a cache server.
data FileOrNumericHost = RCFilePath FilePath -- ^ A path for \"resolv.conf\"
                                             -- on Unix.
                                             -- A default DNS server is
                                             -- automatically detected
                                             -- on Windows.
                       | RCHostName HostName -- ^ A numeric IP address. /Warning/: host names are invalid.
                       | RCHostPort HostName PortNumber -- ^ A numeric IP address and port number. /Warning/: host names are invalid.
                       deriving Show

-- | Type for resolver configuration.
--
--  Use 'defaultResolvConf' to create a new value.
--  An example to use Google's public DNS cache instead of resolv.conf:
--
--   >>> let rc = defaultResolvConf { resolvInfo = RCHostName "8.8.8.8" }
--
data ResolvConf = ResolvConf {
   -- | Server information.
    resolvInfo :: FileOrNumericHost
   -- | Timeout in micro seconds.
  , resolvTimeout :: Int
   -- | The number of retries including the first try.
  , resolvRetry :: Int
   -- | This field was obsoleted.
  , resolvBufsize :: Integer
   -- | Enabling EDNS0 for UDP queries with 4,096-bytes buffer.
  , resolvEDNS0   :: Bool
} deriving Show

-- | Return a default 'ResolvConf':
--
--     * 'resolvInfo' is 'RCFilePath' \"\/etc\/resolv.conf\".
--
--     * 'resolvTimeout' is 3,000,000 micro seconds.
--
--     * 'resolvRetry' is 3.
--
--     * 'resolvEDNS0' is 'True'.
defaultResolvConf :: ResolvConf
defaultResolvConf = ResolvConf {
    resolvInfo = RCFilePath "/etc/resolv.conf"
  , resolvTimeout = 3 * 1000 * 1000
  , resolvRetry = 3
  , resolvBufsize = 512
  , resolvEDNS0 = True
}

----------------------------------------------------------------

-- | Abstract data type of DNS Resolver seed.
--   When implementing a DNS cache, this should be re-used.
data ResolvSeed = ResolvSeed {
    resolvconf  :: ResolvConf
  , nameservers :: NonEmpty AddrInfo
}

----------------------------------------------------------------

-- | Abstract data type of DNS Resolver
--   When implementing a DNS cache, this MUST NOT be re-used.
data Resolver = Resolver {
    resolvseed :: ResolvSeed
  , genId      :: IO Word16
}
