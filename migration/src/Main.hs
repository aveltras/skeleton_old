{-# LANGUAGE PartialTypeSignatures #-}
module Main where

import qualified Di
import qualified Moto
import qualified Moto.PostgreSQL

main :: IO ()
main = do
  (myOpts, ()) <- Moto.getOpts Moto.PostgreSQL.registryConf (pure ())
  Di.new $ \di ->
    Moto.run di migs myOpts
    where migs = Moto.migs
