///|
const DOS_HEADER_OFFSET : Int32 = 0x3C

///|
const DOS_HEADER_SIZE : Int32 = 0x40

///|
const COFF_HEADER_SIZE : Int32 = 20

///|
const PE_SECTION_HEADER_SIZE : Int32 = 40

///|
const PE_OPTIONAL_MAGIC_PE32 : UInt16 = 0x010B

///|
const PE_OPTIONAL_MAGIC_PE32_PLUS : UInt16 = 0x020B

///|
/// Resource limits for parsing a PE image.
pub struct PeLimits {
  max_file_bytes : Int32
  max_sections : Int32
}

///|
pub fn PeLimits::default() -> PeLimits {
  PeLimits::{ max_file_bytes: 512 * 1024 * 1024, max_sections: 96, }
}

///|
pub struct PeSection {
  name : String
  virtual_size : UInt32
  virtual_address : UInt32
  raw_size : UInt32
  raw_pointer : UInt32
  characteristics : UInt32
}

///|
pub fn PeSection::name(self : PeSection) -> String {
  self.name
}

///|
pub fn PeSection::virtual_size(self : PeSection) -> UInt32 {
  self.virtual_size
}

///|
pub fn PeSection::virtual_address(self : PeSection) -> UInt32 {
  self.virtual_address
}

///|
pub fn PeSection::raw_size(self : PeSection) -> UInt32 {
  self.raw_size
}

///|
pub fn PeSection::raw_pointer(self : PeSection) -> UInt32 {
  self.raw_pointer
}

///|
pub fn PeSection::characteristics(self : PeSection) -> UInt32 {
  self.characteristics
}

///|
pub fn PeSection::virtual_span(self : PeSection) -> UInt32 {
  if self.virtual_size > self.raw_size {
    self.virtual_size
  } else {
    self.raw_size
  }
}

///|
/// A PE section-number and section-relative offset mapped to RVA and VA.
pub struct RvaLocation {
  segment : UInt16
  section_offset : UInt32
  section_name : String
  rva : UInt32
  image_address : UInt64
}

///|
pub fn RvaLocation::segment(self : RvaLocation) -> UInt16 {
  self.segment
}

///|
pub fn RvaLocation::section_offset(self : RvaLocation) -> UInt32 {
  self.section_offset
}

///|
pub fn RvaLocation::section_name(self : RvaLocation) -> String {
  self.section_name
}

///|
pub fn RvaLocation::rva(self : RvaLocation) -> UInt32 {
  self.rva
}

///|
pub fn RvaLocation::image_address(self : RvaLocation) -> UInt64 {
  self.image_address
}

///|
pub struct PeImage {
  machine : UInt16
  section_count : UInt16
  timestamp : UInt32
  optional_magic : UInt16
  image_base : UInt64
  sections : Array[PeSection]
}

///|
pub fn PeImage::machine(self : PeImage) -> UInt16 {
  self.machine
}

///|
pub fn PeImage::section_count(self : PeImage) -> UInt16 {
  self.section_count
}

///|
pub fn PeImage::timestamp(self : PeImage) -> UInt32 {
  self.timestamp
}

///|
pub fn PeImage::optional_magic(self : PeImage) -> UInt16 {
  self.optional_magic
}

///|
pub fn PeImage::image_base(self : PeImage) -> UInt64 {
  self.image_base
}

///|
pub fn PeImage::section_at(self : PeImage, index : Int32) -> PeSection? {
  if index < 0 || index >= self.sections.length() {
    None
  } else {
    Some(self.sections[index])
  }
}

///|
pub fn PeImage::map_segment_offset(
  self : PeImage,
  segment : UInt16,
  offset : UInt32,
) -> RvaLocation? {
  if segment == 0 || segment > self.section_count {
    return None
  }
  let section = self.sections[segment.to_int() - 1]
  let span = section.virtual_span()
  if span == 0U || offset >= span {
    return None
  }
  let rva_wide = section.virtual_address.to_uint64() + offset.to_uint64()
  if rva_wide > 0xFFFFFFFFUL {
    return None
  }
  if self.image_base > 0xFFFFFFFFFFFFFFFFUL - rva_wide {
    return None
  }
  let rva = rva_wide.to_uint()
  Some(RvaLocation::{
    segment,
    section_offset: offset,
    section_name: section.name,
    rva: UInt32(rva),
    image_address: self.image_base + rva_wide,
  })
}

///|
/// Parse the DOS, PE/COFF, optional-header, and section-table structures.
pub fn parse_pe_image(data : Bytes, limits : PeLimits) -> PeImage raise PeError {
  if data.length() > limits.max_file_bytes {
    raise PeLimitExceeded("PE file byte limit exceeded")
  }
  if data.length() < DOS_HEADER_SIZE {
    raise TooSmallPe(data.length())
  }
  if data.at(0) != b'M' || data.at(1) != b'Z' {
    raise BadDosMagic
  }
  let (pe_offset_raw, _) = read_pe_u32(data, DOS_HEADER_OFFSET, data.length())
  let pe_offset = pe_u32_to_int(pe_offset_raw, "PE header offset")
  if pe_offset < DOS_HEADER_SIZE {
    raise InvalidPeSection("PE header overlaps the DOS header")
  }
  let signature_end = checked_pe_add(pe_offset, 4, "PE signature")
  if signature_end > data.length() {
    raise TruncatedPe(signature_end)
  }
  if data.at(pe_offset) != b'P' ||
    data.at(pe_offset + 1) != b'E' ||
    data.at(pe_offset + 2) != 0 ||
    data.at(pe_offset + 3) != 0 {
    raise BadPeSignature
  }
  let coff_start = signature_end
  let coff_end = checked_pe_add(coff_start, COFF_HEADER_SIZE, "COFF header")
  if coff_end > data.length() {
    raise TruncatedPe(coff_end)
  }
  let (machine, cursor) = read_pe_u16(data, coff_start, coff_end)
  let (section_count, cursor) = read_pe_u16(data, cursor, coff_end)
  let (timestamp, cursor) = read_pe_u32(data, cursor, coff_end)
  let (_, cursor) = read_pe_u32(data, cursor, coff_end)
  let (_, cursor) = read_pe_u32(data, cursor, coff_end)
  let (optional_size_raw, cursor) = read_pe_u16(data, cursor, coff_end)
  let (_, cursor) = read_pe_u16(data, cursor, coff_end)
  if cursor != coff_end {
    raise InvalidPeSection("COFF header has trailing bytes")
  }
  if section_count.to_int() > limits.max_sections {
    raise PeLimitExceeded("PE section count limit exceeded")
  }
  let optional_size = optional_size_raw.to_int()
  let optional_start = coff_end
  let optional_end = checked_pe_add(
    optional_start, optional_size, "PE optional header",
  )
  if optional_end > data.length() {
    raise TruncatedPe(optional_end)
  }
  let (optional_magic, _) = read_pe_u16(data, optional_start, optional_end)
  let image_base = match optional_magic {
    PE_OPTIONAL_MAGIC_PE32 => {
      if optional_size < 32 {
        raise TruncatedPe(optional_end)
      }
      let (value, _) = read_pe_u32(data, optional_start + 28, optional_end)
      value.to_uint64()
    }
    PE_OPTIONAL_MAGIC_PE32_PLUS => {
      if optional_size < 32 {
        raise TruncatedPe(optional_end)
      }
      let (value, _) = read_pe_u64(data, optional_start + 24, optional_end)
      value
    }
    _ => raise UnsupportedPeOptionalHeader(optional_magic)
  }
  let section_table_end = checked_pe_add(
    optional_end,
    checked_pe_mul(
      section_count.to_int(),
      PE_SECTION_HEADER_SIZE,
      "PE sections",
    ),
    "PE section table",
  )
  if section_table_end > data.length() {
    raise TruncatedPe(section_table_end)
  }
  let sections = []
  let mut cursor = optional_end
  for _ in 0..<section_count.to_int() {
    let (section, next) = read_pe_section(data, cursor, section_table_end)
    sections.push(section)
    cursor = next
  }
  PeImage::{
    machine,
    section_count,
    timestamp,
    optional_magic,
    image_base,
    sections,
  }
}

///|
fn read_pe_section(
  data : Bytes,
  start : Int32,
  end : Int32,
) -> (PeSection, Int32) raise PeError {
  let section_end = checked_pe_add(start, PE_SECTION_HEADER_SIZE, "PE section")
  if section_end > end {
    raise TruncatedPe(section_end)
  }
  let name_bytes = data.exact_view(start~, end=start + 8).to_owned()
  let mut name_end = 0
  while name_end < 8 && name_bytes.at(name_end) != 0 {
    name_end = name_end + 1
  }
  let name = @utf8.decode_lossy(name_bytes.exact_view(end=name_end))
  let (virtual_size, cursor) = read_pe_u32(data, start + 8, section_end)
  let (virtual_address, cursor) = read_pe_u32(data, cursor, section_end)
  let (raw_size, cursor) = read_pe_u32(data, cursor, section_end)
  let (raw_pointer, cursor) = read_pe_u32(data, cursor, section_end)
  let (_, cursor) = read_pe_u32(data, cursor, section_end)
  let (_, cursor) = read_pe_u32(data, cursor, section_end)
  let (_, cursor) = read_pe_u16(data, cursor, section_end)
  let (_, cursor) = read_pe_u16(data, cursor, section_end)
  let (characteristics, cursor) = read_pe_u32(data, cursor, section_end)
  if cursor != section_end {
    raise InvalidPeSection("PE section header has trailing bytes")
  }
  (
    PeSection::{
      name,
      virtual_size,
      virtual_address,
      raw_size,
      raw_pointer,
      characteristics,
    },
    section_end,
  )
}

///|
fn read_pe_u16(
  data : Bytes,
  pos : Int32,
  end : Int32,
) -> (UInt16, Int32) raise PeError {
  if pos < 0 || pos + 2 > end || pos + 2 > data.length() {
    raise TruncatedPe(pos)
  }
  (
    ((data.at(pos + 1).to_int() << 8) | data.at(pos).to_int()).to_uint16(),
    pos + 2,
  )
}

///|
fn read_pe_u32(
  data : Bytes,
  pos : Int32,
  end : Int32,
) -> (UInt32, Int32) raise PeError {
  if pos < 0 || pos + 4 > end || pos + 4 > data.length() {
    raise TruncatedPe(pos)
  }
  (
    UInt32(
      (data.at(pos + 3).to_int().reinterpret_as_uint() << 24) |
      (data.at(pos + 2).to_int().reinterpret_as_uint() << 16) |
      (data.at(pos + 1).to_int().reinterpret_as_uint() << 8) |
      data.at(pos).to_int().reinterpret_as_uint(),
    ),
    pos + 4,
  )
}

///|
fn read_pe_u64(
  data : Bytes,
  pos : Int32,
  end : Int32,
) -> (UInt64, Int32) raise PeError {
  let (low, next) = read_pe_u32(data, pos, end)
  let (high, next) = read_pe_u32(data, next, end)
  ((high.to_uint64() << 32) | low.to_uint64(), next)
}

///|
fn pe_u32_to_int(value : UInt32, field : String) -> Int32 raise PeError {
  if value > 0x7FFFFFFFU {
    raise InvalidPeSection("\{field} exceeds Int range")
  }
  value.reinterpret_as_int()
}

///|
fn checked_pe_add(
  left : Int32,
  right : Int32,
  field : String,
) -> Int32 raise PeError {
  if left < 0 || right < 0 || left > 0x7FFFFFFF - right {
    raise InvalidPeSection("\{field} overflows Int range")
  }
  left + right
}

///|
fn checked_pe_mul(
  left : Int32,
  right : Int32,
  field : String,
) -> Int32 raise PeError {
  if left < 0 || right < 0 || (left != 0 && right > 0x7FFFFFFF / left) {
    raise InvalidPeSection("\{field} overflows Int range")
  }
  left * right
}
