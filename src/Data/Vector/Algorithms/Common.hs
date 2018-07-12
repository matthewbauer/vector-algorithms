{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE TypeFamilies #-}

-- ---------------------------------------------------------------------------
-- |
-- Module      : Data.Vector.Algorithms.Common
-- Copyright   : (c) 2008-2011 Dan Doel
-- Maintainer  : Dan Doel
-- Stability   : Experimental
-- Portability : Portable
--
-- Common operations and utility functions for all sorts

module Data.Vector.Algorithms.Common where

import Prelude hiding (read, length)

import Control.Monad.Primitive

import Data.Vector.Generic.Mutable

import qualified Data.Vector.Primitive.Mutable as PV

-- | A type of comparisons between two values of a given type.
type Comparison e = e -> e -> Ordering

copyOffset :: (PrimMonad m, MVector v e)
           => v (PrimState m) e -> v (PrimState m) e -> Int -> Int -> Int -> m ()
copyOffset from to iFrom iTo len =
  unsafeCopy (unsafeSlice iTo len to) (unsafeSlice iFrom len from)
{-# INLINE copyOffset #-}

inc :: (PrimMonad m, MVector v Int) => v (PrimState m) Int -> Int -> m Int
inc arr i = unsafeRead arr i >>= \e -> unsafeWrite arr i (e+1) >> return e
{-# INLINE inc #-}

-- shared bucket sorting stuff
countLoop :: (PrimMonad m, MVector v e)
          => (e -> Int)
          -> v (PrimState m) e -> PV.MVector (PrimState m) Int -> m ()
countLoop rdx src count = set count 0 >> go 0
 where
 len = length src
 go i
   | i < len    = unsafeRead src i >>= inc count . rdx >> go (i+1)
   | otherwise  = return ()
{-# INLINE countLoop #-}

