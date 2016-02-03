module Game.Chunk.Data(
    Chunk(..)
  , ChunkId(..)
  , emptyChunk
  ) where

import Control.DeepSeq
import Data.Hashable 
import Data.Serialize
import GHC.Generics 
import Linear

import Game.GoreAndAsh.Actor

-- | Small part of world
data Chunk = Chunk {
  chunkId :: !ChunkId
-- | World coordinates of chunk
, chunkCoords :: !(V2 Int)
} deriving (Generic)

instance NFData Chunk

newtype ChunkId = ChunkId { unChunkId :: Int } deriving (Eq, Show, Generic)

instance NFData ChunkId 
instance Hashable ChunkId 
instance Serialize ChunkId

data ChunkMessage 

instance ActorMessage ChunkId where 
  type ActorMessageType ChunkId = ChunkMessage

  fromCounter = ChunkId 
  toCounter = unChunkId

emptyChunk :: ChunkId -> V2 Int -> Chunk 
emptyChunk i v = Chunk {
    chunkId = i 
  , chunkCoords = v
  }