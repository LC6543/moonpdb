///|
/// Errors raised while reading an MSF/PDB container.
pub suberror MsfError {
  TooSmall(Int)
  BadMagic
  UnsupportedBlockSize(Int)
  InvalidBlockCount(Int)
  InvalidFreeBlockMap(Int)
  InvalidBlockIndex(Int)
  Truncated(Int)
  InvalidDirectory(String)
  InvalidStream(Int)
  LimitExceeded(String)
  InvalidValue(String)
}
