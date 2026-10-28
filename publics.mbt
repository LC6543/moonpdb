///|
const PUBLICS_HEADER_SIZE : Int32 = 28

///|
const GSI_HEADER_SIZE : Int32 = 16

///|
const GSI_BITMAP_WORDS : Int32 = 129

///|
const GSI_BUCKET_COUNT : Int32 = 4097

///|
const GSI_SIGNATURE : UInt32 = 0xFFFFFFFFU

///|
const GSI_VERSION : UInt32 = 0xEFFE0000U + 19990810U

///|
/// The fixed header before a Publics or Globals GSI hash table.
pub struct GsiHashHeader {
  signature : UInt32
  version : UInt32
  hash_record_bytes : UInt32
  declared_bucket_count : UInt32
}

///|
pub fn GsiHashHeader::signature(self : GsiHashHeader) -> UInt32 {
  self.signature
}

///|
pub fn GsiHashHeader::version(self : GsiHashHeader) -> UInt32 {
  self.version
}

///|
pub fn GsiHashHeader::hash_record_bytes(self : GsiHashHeader) -> UInt32 {
  self.hash_record_bytes
}

///|
pub fn GsiHashHeader::declared_bucket_count(self : GsiHashHeader) -> UInt32 {
  self.declared_bucket_count
}

///|
/// One GSI hash record. On-disk offsets are stored one greater than zero.
pub struct GsiHashRecord {
  raw_offset : UInt32
  reference_count : UInt32
}

///|
pub fn GsiHashRecord::raw_offset(self : GsiHashRecord) -> UInt32 {
  self.raw_offset
}

///|
pub fn GsiHashRecord::symbol_offset(self : GsiHashRecord) -> UInt32? {
  if self.raw_offset == 0U {
    None
  } else {
    Some(self.raw_offset - 1U)
  }
}

///|
pub fn GsiHashRecord::reference_count(self : GsiHashRecord) -> UInt32 {
  self.reference_count
}

///|
/// A parsed GSI hash table, including its compressed bucket map.
pub struct GsiTable {
  header : GsiHashHeader
  hash_records : Array[GsiHashRecord]
  bitmap : Array[UInt32]
  buckets : Array[UInt32]
  bucket_map : Array[Int32]
}

///|
pub fn GsiTable::header(self : GsiTable) -> GsiHashHeader {
  self.header
}

///|
pub fn GsiTable::hash_record_count(self : GsiTable) -> Int32 {
  self.hash_records.length()
}

///|
pub fn GsiTable::hash_record_at(
  self : GsiTable,
  index : Int32,
) -> GsiHashRecord? {
  if index < 0 || index >= self.hash_records.length() {
    None
  } else {
    Some(self.hash_records[index])
  }
}

///|
pub fn GsiTable::hash_records(self : GsiTable) -> Array[GsiHashRecord] {
  self.hash_records.copy()
}

///|
pub fn GsiTable::bitmap(self : GsiTable) -> Array[UInt32] {
  self.bitmap.copy()
}

///|
pub fn GsiTable::buckets(self : GsiTable) -> Array[UInt32] {
  self.buckets.copy()
}

///|
pub fn GsiTable::bucket_count(self : GsiTable) -> Int32 {
  self.buckets.length()
}

///|
pub fn GsiTable::bucket_map_index(
  self : GsiTable,
  expanded_bucket : Int32,
) -> Int32? {
  if expanded_bucket < 0 || expanded_bucket >= self.bucket_map.length() {
    None
  } else {
    Some(self.bucket_map[expanded_bucket])
  }
}

///|
/// The fixed 28-byte header at the start of the Publics stream.
pub struct PublicsHeader {
  symbol_hash : UInt32
  address_map_bytes : UInt32
  thunk_count : UInt32
  thunk_size : UInt32
  thunk_table_section : UInt16
  thunk_table_offset : UInt32
  section_count : UInt32
}

///|
pub fn PublicsHeader::symbol_hash(self : PublicsHeader) -> UInt32 {
  self.symbol_hash
}

///|
pub fn PublicsHeader::address_map_bytes(self : PublicsHeader) -> UInt32 {
  self.address_map_bytes
}

///|
pub fn PublicsHeader::thunk_count(self : PublicsHeader) -> UInt32 {
  self.thunk_count
}

///|
pub fn PublicsHeader::thunk_size(self : PublicsHeader) -> UInt32 {
  self.thunk_size
}

///|
pub fn PublicsHeader::thunk_table_section(self : PublicsHeader) -> UInt16 {
  self.thunk_table_section
}

///|
pub fn PublicsHeader::thunk_table_offset(self : PublicsHeader) -> UInt32 {
  self.thunk_table_offset
}

///|
pub fn PublicsHeader::section_count(self : PublicsHeader) -> UInt32 {
  self.section_count
}

///|
pub struct PublicSectionOffset {
  offset : UInt32
  section : UInt16
}

///|
pub fn PublicSectionOffset::offset(self : PublicSectionOffset) -> UInt32 {
  self.offset
}

///|
pub fn PublicSectionOffset::section(self : PublicSectionOffset) -> UInt16 {
  self.section
}

///|
/// A Publics address-map entry resolved to its S_PUB32 symbol.
pub struct ResolvedPublicSymbol {
  symbol_offset : UInt32
  flags : UInt32
  segment : UInt16
  offset : UInt32
  name : String
}

///|
pub fn ResolvedPublicSymbol::symbol_offset(
  self : ResolvedPublicSymbol,
) -> UInt32 {
  self.symbol_offset
}

///|
pub fn ResolvedPublicSymbol::flags(self : ResolvedPublicSymbol) -> UInt32 {
  self.flags
}

///|
pub fn ResolvedPublicSymbol::segment(self : ResolvedPublicSymbol) -> UInt16 {
  self.segment
}

///|
pub fn ResolvedPublicSymbol::offset(self : ResolvedPublicSymbol) -> UInt32 {
  self.offset
}

///|
pub fn ResolvedPublicSymbol::name(self : ResolvedPublicSymbol) -> String {
  self.name
}

///|
/// The Publics stream, its GSI table, and address-resolved S_PUB32 records.
pub struct PublicsStream {
  header : PublicsHeader
  gsi : GsiTable
  address_map : Array[UInt32]
  thunk_map : Array[UInt32]
  section_offsets : Array[PublicSectionOffset]
  public_symbols : Array[ResolvedPublicSymbol]
}

///|
pub fn PublicsStream::header(self : PublicsStream) -> PublicsHeader {
  self.header
}

///|
pub fn PublicsStream::gsi(self : PublicsStream) -> GsiTable {
  self.gsi
}

///|
pub fn PublicsStream::address_map(self : PublicsStream) -> Array[UInt32] {
  self.address_map.copy()
}

///|
pub fn PublicsStream::thunk_map(self : PublicsStream) -> Array[UInt32] {
  self.thunk_map.copy()
}

///|
pub fn PublicsStream::section_offsets(
  self : PublicsStream,
) -> Array[PublicSectionOffset] {
  self.section_offsets.copy()
}

///|
pub fn PublicsStream::public_symbol_count(self : PublicsStream) -> Int32 {
  self.public_symbols.length()
}

///|
pub fn PublicsStream::public_symbol_at(
  self : PublicsStream,
  index : Int32,
) -> ResolvedPublicSymbol? {
  if index < 0 || index >= self.public_symbols.length() {
    None
  } else {
    Some(self.public_symbols[index])
  }
}

///|
pub fn PublicsStream::find_public_exact(
  self : PublicsStream,
  segment : UInt16,
  offset : UInt32,
) -> ResolvedPublicSymbol? {
  let mut low = 0
  let mut high = self.public_symbols.length()
  while low < high {
    let middle = low + (high - low) / 2
    let item = self.public_symbols[middle]
    let comparison = compare_public_address(
      item.segment,
      item.offset,
      segment,
      offset,
    )
    if comparison < 0 {
      low = middle + 1
    } else {
      high = middle
    }
  }
  if low < self.public_symbols.length() {
    let item = self.public_symbols[low]
    if item.segment == segment && item.offset == offset {
      Some(item)
    } else {
      None
    }
  } else {
    None
  }
}

///|
pub fn PublicsStream::find_public_nearest(
  self : PublicsStream,
  segment : UInt16,
  offset : UInt32,
) -> ResolvedPublicSymbol? {
  let mut low = 0
  let mut high = self.public_symbols.length()
  while low < high {
    let middle = low + (high - low) / 2
    let item = self.public_symbols[middle]
    if compare_public_address(item.segment, item.offset, segment, offset) <= 0 {
      low = middle + 1
    } else {
      high = middle
    }
  }
  if low == 0 {
    return None
  }
  let item = self.public_symbols[low - 1]
  if item.segment == segment {
    Some(item)
  } else {
    None
  }
}

///|
/// Read the Publics stream referenced by DBI and resolve its address map.
pub fn MsfFile::publics_stream(
  self : MsfFile,
  dbi : DbiFile,
  limits : SymbolLimits,
) -> PublicsStream raise SymbolError {
  let index = dbi.header().public_symbol_stream_index()
  if index == 0xFFFF {
    raise PublicsStreamUnavailable(index)
  }
  let bytes = self.stream(index.to_int()) catch {
    _ => raise PublicsStreamUnavailable(index)
  }
  let symbols = self.symbol_record_stream(dbi, limits)
  parse_publics_stream(bytes, symbols, limits)
}

///|
pub fn parse_publics_stream(
  data : Bytes,
  symbols : SymbolTable,
  limits : SymbolLimits,
) -> PublicsStream raise SymbolError {
  if data.length() > limits.max_stream_bytes {
    raise PublicsLimitExceeded("Publics stream byte limit exceeded")
  }
  if data.length() < PUBLICS_HEADER_SIZE {
    raise TruncatedPublics(data.length())
  }
  let (header, after_header) = parse_publics_header(data)
  let (gsi, after_gsi) = parse_gsi_table(data, after_header, limits)
  let mut cursor = after_gsi
  let address_count_raw = header.address_map_bytes / 4U
  let address_count = symbol_uint_to_int(
    address_count_raw, "Publics address-map count",
  )
  if address_count > limits.max_public_symbols {
    raise PublicsLimitExceeded("Publics address-map count limit exceeded")
  }
  let address_end = checked_symbol_add(
    cursor,
    checked_symbol_mul(address_count, 4, "address map"),
    "address map",
  )
  if address_end > data.length() {
    raise TruncatedPublics(address_end)
  }
  let address_map = []
  for _ in 0..<address_count {
    let (value, next) = read_symbol_u32(data, cursor, address_end)
    address_map.push(value)
    cursor = next
  }
  let thunk_count = symbol_uint_to_int(header.thunk_count, "thunk count")
  if thunk_count > limits.max_public_symbols {
    raise PublicsLimitExceeded("Publics thunk count limit exceeded")
  }
  let thunk_end = checked_symbol_add(
    cursor,
    checked_symbol_mul(thunk_count, 4, "thunk map"),
    "thunk map",
  )
  if thunk_end > data.length() {
    raise TruncatedPublics(thunk_end)
  }
  let thunk_map = []
  for _ in 0..<thunk_count {
    let (value, next) = read_symbol_u32(data, cursor, thunk_end)
    thunk_map.push(value)
    cursor = next
  }
  let section_count = symbol_uint_to_int(
    header.section_count,
    "Publics section count",
  )
  let section_end = checked_symbol_add(
    cursor,
    checked_symbol_mul(section_count, 8, "section offsets"),
    "section offsets",
  )
  if section_end != data.length() {
    if section_end > data.length() {
      raise TruncatedPublics(section_end)
    }
    raise InvalidPublicsHeader("Publics stream has trailing bytes")
  }
  let section_offsets = []
  for _ in 0..<section_count {
    let (offset, next) = read_symbol_u32(data, cursor, section_end)
    let (section, next) = read_symbol_u16(data, next, section_end)
    let (padding, next) = read_symbol_u16(data, next, section_end)
    if padding != 0 {
      raise InvalidPublicsHeader("section offset padding is not zero")
    }
    section_offsets.push(PublicSectionOffset::{ offset, section, })
    cursor = next
  }
  let public_symbols = resolve_public_symbols(address_map, symbols)
  PublicsStream::{
    header,
    gsi,
    address_map,
    thunk_map,
    section_offsets,
    public_symbols,
  }
}

///|
fn parse_publics_header(
  data : Bytes,
) -> (PublicsHeader, Int32) raise SymbolError {
  let (symbol_hash, cursor) = read_symbol_u32(data, 0, PUBLICS_HEADER_SIZE)
  let (address_map_bytes, cursor) = read_symbol_u32(
    data,
    cursor,
    PUBLICS_HEADER_SIZE,
  )
  if address_map_bytes % 4U != 0U {
    raise InvalidPublicsHeader("address-map byte count is not uint32-aligned")
  }
  let (thunk_count, cursor) = read_symbol_u32(data, cursor, PUBLICS_HEADER_SIZE)
  let (thunk_size, cursor) = read_symbol_u32(data, cursor, PUBLICS_HEADER_SIZE)
  let (thunk_table_section, cursor) = read_symbol_u16(
    data,
    cursor,
    PUBLICS_HEADER_SIZE,
  )
  let (padding, cursor) = read_symbol_u16(data, cursor, PUBLICS_HEADER_SIZE)
  if padding != 0 {
    raise InvalidPublicsHeader("Publics header padding is not zero")
  }
  let (thunk_table_offset, cursor) = read_symbol_u32(
    data,
    cursor,
    PUBLICS_HEADER_SIZE,
  )
  let (section_count, cursor) = read_symbol_u32(
    data,
    cursor,
    PUBLICS_HEADER_SIZE,
  )
  (
    PublicsHeader::{
      symbol_hash,
      address_map_bytes,
      thunk_count,
      thunk_size,
      thunk_table_section,
      thunk_table_offset,
      section_count,
    },
    cursor,
  )
}

///|
fn parse_gsi_table(
  data : Bytes,
  start : Int32,
  limits : SymbolLimits,
) -> (GsiTable, Int32) raise SymbolError {
  let header_end = checked_symbol_add(start, GSI_HEADER_SIZE, "GSI header")
  if header_end > data.length() {
    raise TruncatedPublics(header_end)
  }
  let (signature, cursor0) = read_symbol_u32(data, start, header_end)
  if signature != GSI_SIGNATURE {
    raise InvalidGsi("GSI signature must be 0xFFFFFFFF")
  }
  let (version, cursor1) = read_symbol_u32(data, cursor0, header_end)
  if version != GSI_VERSION {
    raise UnsupportedGsiVersion(version)
  }
  let (hash_record_bytes, cursor2) = read_symbol_u32(data, cursor1, header_end)
  let (declared_bucket_count, cursor3) = read_symbol_u32(
    data, cursor2, header_end,
  )
  let mut cursor = cursor3
  if hash_record_bytes % 8U != 0U {
    raise InvalidGsi("GSI hash-record byte count is not aligned")
  }
  let hash_record_count = symbol_uint_to_int(
    hash_record_bytes / 8U,
    "GSI hash-record count",
  )
  if hash_record_count > limits.max_hash_records {
    raise PublicsLimitExceeded("GSI hash-record count limit exceeded")
  }
  let records_end = checked_symbol_add(
    cursor,
    checked_symbol_mul(hash_record_count, 8, "GSI hash records"),
    "GSI hash records",
  )
  if records_end > data.length() {
    raise TruncatedPublics(records_end)
  }
  let hash_records = []
  for _ in 0..<hash_record_count {
    let (raw_offset, next) = read_symbol_u32(data, cursor, records_end)
    let (reference_count, next) = read_symbol_u32(data, next, records_end)
    hash_records.push(GsiHashRecord::{ raw_offset, reference_count, })
    cursor = next
  }
  let bitmap = []
  let buckets = []
  let bucket_map = []
  if hash_record_count > 0 {
    let bitmap_end = checked_symbol_add(
      cursor,
      checked_symbol_mul(GSI_BITMAP_WORDS, 4, "GSI bitmap"),
      "GSI bitmap",
    )
    if bitmap_end > data.length() {
      raise TruncatedPublics(bitmap_end)
    }
    for _ in 0..<GSI_BITMAP_WORDS {
      let (word, next) = read_symbol_u32(data, cursor, bitmap_end)
      bitmap.push(word)
      cursor = next
    }
    let mut compressed_bucket = 0
    for expanded in 0..<GSI_BUCKET_COUNT {
      let word = bitmap[expanded / 32]
      let bit = expanded % 32
      let present = (word & (1U << bit)) != 0U
      if present {
        bucket_map.push(compressed_bucket)
        compressed_bucket = compressed_bucket + 1
      } else {
        bucket_map.push(-1)
      }
    }
    let buckets_end = checked_symbol_add(
      cursor,
      checked_symbol_mul(compressed_bucket, 4, "GSI buckets"),
      "GSI buckets",
    )
    if buckets_end > data.length() {
      raise TruncatedPublics(buckets_end)
    }
    for _ in 0..<compressed_bucket {
      let (bucket, next) = read_symbol_u32(data, cursor, buckets_end)
      buckets.push(bucket)
      cursor = next
    }
  }
  (
    GsiTable::{
      header: GsiHashHeader::{
        signature,
        version,
        hash_record_bytes,
        declared_bucket_count,
      },
      hash_records,
      bitmap,
      buckets,
      bucket_map,
    },
    cursor,
  )
}

///|
fn resolve_public_symbols(
  address_map : Array[UInt32],
  symbols : SymbolTable,
) -> Array[ResolvedPublicSymbol] raise SymbolError {
  let resolved = []
  let mut previous : (UInt16, UInt32)? = None
  for symbol_offset in address_map {
    let offset = symbol_uint_to_int(symbol_offset, "public symbol offset")
    let record = match symbols.record_at_offset(offset) {
      Some(value) => value
      None =>
        raise InvalidPublicSymbol("address map references a missing symbol")
    }
    let public = match record.details() {
      Public(value) => value
      _ => raise InvalidPublicSymbol("address map does not reference S_PUB32")
    }
    match previous {
      Some((segment, previous_offset)) =>
        if segment > public.segment ||
          (segment == public.segment && previous_offset > public.offset) {
          raise InvalidPublicSymbol("address map is not sorted by address")
        }
      None => ()
    }
    previous = Some((public.segment, public.offset))
    resolved.push(ResolvedPublicSymbol::{
      symbol_offset,
      flags: public.flags,
      segment: public.segment,
      offset: public.offset,
      name: public.name,
    })
  }
  resolved
}

///|
fn compare_public_address(
  left_segment : UInt16,
  left_offset : UInt32,
  right_segment : UInt16,
  right_offset : UInt32,
) -> Int32 {
  if left_segment < right_segment {
    -1
  } else if left_segment > right_segment {
    1
  } else if left_offset < right_offset {
    -1
  } else if left_offset > right_offset {
    1
  } else {
    0
  }
}
