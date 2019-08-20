{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators #-}
module Main where

import Lucid
import Network.Wai.Handler.Warp (run)
import Servant
import Servant.API.Generic
import Servant.HTML.Lucid
import Servant.Server.Generic

main :: IO ()
main = run 8080 (appMyMonad AppCustomState)

data Routes r = Routes
                { _get :: r :- Get '[HTML] (Html ())
                , _put :: r :- "alt" :> Get '[HTML] (Html ())
                , _static :: r :- "static" :> Raw
                } deriving (Generic)

api :: Proxy (ToServantApi Routes)
api = genericApi (Proxy :: Proxy Routes)

data AppCustomState =
  AppCustomState

type AppM = ReaderT AppCustomState Handler

recordMyMonad :: Routes (AsServerT AppM)
recordMyMonad = Routes {_get = getRouteMyMonad, _put = putRouteMyMonad, _static = serveDirectoryWebApp "./../build"}

getRouteMyMonad :: AppM (Html ())
getRouteMyMonad = return index

putRouteMyMonad :: AppM (Html ())
putRouteMyMonad = return index

nt :: AppCustomState -> AppM a -> Handler a
nt s x = runReaderT x s

appMyMonad :: AppCustomState -> Application
appMyMonad st = genericServeT (nt st) recordMyMonad

index :: Html ()
index =
  html_ $ do
    head_ $ do
      title_ "Skeleton"
      link_ [rel_ "stylesheet", href_ "/static/app.css"]
    body_ $ do
      a_ [href_ "/"] "index"
      a_ [href_ "/alt"] "alt"
      p_ "test23"
      p_ "test"
      script_ [src_ "/static/app.js"] ("" :: Text)
