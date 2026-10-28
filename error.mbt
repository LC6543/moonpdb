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

///|
/// Errors raised while reading the PDB Info stream.
pub suberror PdbInfoError {
  TruncatedInfo(Int32)
  InvalidInfoValue(String)
  InvalidNamedStream(String)
  InfoStreamUnavailable
  LimitExceededInfo(String)
}

///|
/// Errors raised while reading a TPI or IPI CodeView type stream.
pub suberror TpiError {
  TruncatedTpi(Int32)
  InvalidTpiHeader(String)
  InvalidTypeRecord(String)
  TypeStreamUnavailable(Int32)
  TpiLimitExceeded(String)
}

///|
/// Errors raised while reading the PDB DBI stream.
pub suberror DbiError {
  TruncatedDbi(Int32)
  InvalidDbiHeader(String)
  UnsupportedDbiVersion(UInt32)
  UnsupportedSectionContributionVersion(UInt32)
  InvalidDbiModule(String)
  InvalidSectionContribution(String)
  InvalidSectionMap(String)
  InvalidFileInfo(String)
  DbiStreamUnavailable
  DbiLimitExceeded(String)
}

///|
/// Errors raised while reading CodeView symbol and module-debug streams.
pub suberror SymbolError {
  TruncatedSymbol(Int32)
  InvalidSymbolRecord(String)
  InvalidModuleStream(String)
  UnsupportedModuleSignature(UInt32)
  SymbolStreamUnavailable(UInt16)
  ModuleStreamUnavailable(UInt16)
  SymbolLimitExceeded(String)
  TruncatedPublics(Int32)
  InvalidPublicsHeader(String)
  UnsupportedGsiVersion(UInt32)
  InvalidGsi(String)
  PublicsStreamUnavailable(UInt16)
  InvalidPublicSymbol(String)
  PublicsLimitExceeded(String)
  GlobalsStreamUnavailable(UInt16)
  InvalidGlobalIndex(String)
  TruncatedC13(Int32)
  InvalidC13Subsection(String)
  InvalidFileChecksum(String)
  InvalidLineInfo(String)
  MissingC13StringTable
  C13LimitExceeded(String)
}

///|
/// Errors raised while reading the PE image needed for PDB address mapping.
pub suberror PeError {
  TooSmallPe(Int32)
  BadDosMagic
  BadPeSignature
  TruncatedPe(Int32)
  UnsupportedPeOptionalHeader(UInt16)
  InvalidPeSection(String)
  PeLimitExceeded(String)
}
