///|
/// Errors raised while reading an MSF/PDB container.
pub suberror MsfError {
  TooSmall(Int32)
  BadMagic
  UnsupportedBlockSize(Int32)
  InvalidBlockCount(Int32)
  InvalidFreeBlockMap(Int32)
  InvalidBlockIndex(Int32)
  Truncated(Int32)
  InvalidDirectory(String)
  InvalidStream(Int32)
  LimitExceeded(String)
  InvalidValue(String)
}
