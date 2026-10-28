///|
/// A PDB address combined with PE mapping, public symbol, and source location.
pub struct SymbolizedAddress {
  segment : UInt16
  section_offset : UInt32
  section_name : String
  rva : UInt32
  image_address : UInt64
  public_symbol : ResolvedPublicSymbol?
  source : SourceLocation?
}

///|
pub fn SymbolizedAddress::segment(self : SymbolizedAddress) -> UInt16 {
  self.segment
}

///|
pub fn SymbolizedAddress::section_offset(self : SymbolizedAddress) -> UInt32 {
  self.section_offset
}

///|
pub fn SymbolizedAddress::section_name(self : SymbolizedAddress) -> String {
  self.section_name
}

///|
pub fn SymbolizedAddress::rva(self : SymbolizedAddress) -> UInt32 {
  self.rva
}

///|
pub fn SymbolizedAddress::image_address(self : SymbolizedAddress) -> UInt64 {
  self.image_address
}

///|
pub fn SymbolizedAddress::public_symbol(
  self : SymbolizedAddress,
) -> ResolvedPublicSymbol? {
  self.public_symbol
}

///|
pub fn SymbolizedAddress::source(self : SymbolizedAddress) -> SourceLocation? {
  self.source
}

///|
/// Combine PE mapping, nearest public symbol, and C13 source line information.
pub fn symbolicate_address(
  pe : PeImage,
  publics : PublicsStream,
  c13_modules : Array[C13DebugInfo],
  segment : UInt16,
  offset : UInt32,
) -> SymbolizedAddress? {
  let mapped = match pe.map_segment_offset(segment, offset) {
    Some(value) => value
    None => return None
  }
  let public_symbol = publics.find_public_nearest(segment, offset)
  let mut source : SourceLocation? = None
  for item in c13_modules {
    match item.find_line(segment, offset) {
      Some(value) => {
        source = Some(value)
        break
      }
      None => ()
    }
  }
  Some(SymbolizedAddress::{
    segment,
    section_offset: offset,
    section_name: mapped.section_name,
    rva: mapped.rva,
    image_address: mapped.image_address,
    public_symbol,
    source,
  })
}

///|
/// Symbolicate a batch of PDB segment-relative addresses.
pub fn symbolicate_addresses(
  pe : PeImage,
  publics : PublicsStream,
  c13_modules : Array[C13DebugInfo],
  addresses : Array[(UInt16, UInt32)],
) -> Array[SymbolizedAddress] {
  let results = []
  for address in addresses {
    match symbolicate_address(pe, publics, c13_modules, address.0, address.1) {
      Some(value) => results.push(value)
      None => ()
    }
  }
  results
}
