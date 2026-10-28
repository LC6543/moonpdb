///|
const DBI_HEADER_SIZE : Int32 = 64

///|
const DBI_MODULE_HEADER_SIZE : Int32 = 64

///|
const DBI_SECTION_CONTRIB_60_SIZE : Int32 = 28

///|
const DBI_SECTION_CONTRIB_2_SIZE : Int32 = 32

///|
const DBI_SECTION_MAP_HEADER_SIZE : Int32 = 4

///|
const DBI_SECTION_MAP_ENTRY_SIZE : Int32 = 20

///|
const DBI_FILE_INFO_HEADER_SIZE : Int32 = 4

///|
const DBI_VERSION_SIGNATURE : UInt32 = 0xFFFFFFFFU

///|
const DBI_VERSION_70 : UInt32 = 19990903U

///|
const DBI_SECTION_CONTRIBUTION_60 : UInt32 = 0xEFFE0000U + 19970605U

///|
const DBI_SECTION_CONTRIBUTION_2 : UInt32 = 0xEFFE0000U + 20140516U

///|
/// Resource limits for parsing the DBI stream.
pub struct DbiLimits {
  max_stream_bytes : Int32
  max_modules : Int32
  max_section_contributions : Int32
  max_section_map_entries : Int32
  max_source_files : Int32
  max_string_bytes : Int32
  max_debug_streams : Int32
}

///|
pub fn DbiLimits::default() -> DbiLimits {
  DbiLimits::{
    max_stream_bytes: 128 * 1024 * 1024,
    max_modules: 65_536,
    max_section_contributions: 1_000_000,
    max_section_map_entries: 65_536,
    max_source_files: 1_000_000,
    max_string_bytes: 64 * 1024 * 1024,
    max_debug_streams: 64,
  }
}

///|
/// The version marker at the start of the section-contribution substream.
pub enum SectionContributionVersion {
  None
  V60
  V2
}

///|
/// Optional indexed streams listed in the DBI debug header.
pub enum DebugStreamKind {
  Fpo
  Exception
  Fixup
  OmapToSrc
  OmapFromSrc
  SectionHdr
  TokenRidMap
  Xdata
  Pdata
  NewFpo
  SectionHdrOrig
}

///|
pub fn DebugStreamKind::all() -> Array[DebugStreamKind] {
  [
    Fpo,
    Exception,
    Fixup,
    OmapToSrc,
    OmapFromSrc,
    SectionHdr,
    TokenRidMap,
    Xdata,
    Pdata,
    NewFpo,
    SectionHdrOrig,
  ]
}

///|
/// The fixed 64-byte header at the start of DBI stream 3.
pub struct DbiHeader {
  version_signature : UInt32
  version : UInt32
  age : UInt32
  global_symbol_stream_index : UInt16
  build_number : UInt16
  public_symbol_stream_index : UInt16
  pdb_dll_version : UInt16
  symbol_record_stream_index : UInt16
  pdb_dll_rebuild : UInt16
  modi_substream_bytes : Int32
  section_contributions_bytes : Int32
  section_map_bytes : Int32
  file_info_bytes : Int32
  type_server_map_bytes : Int32
  mfc_type_server_index : UInt32
  optional_debug_header_bytes : Int32
  ec_substream_bytes : Int32
  flags : UInt16
  machine_type : UInt16
  reserved : UInt32
}

///|
pub fn DbiHeader::version_signature(self : DbiHeader) -> UInt32 {
  self.version_signature
}

///|
pub fn DbiHeader::version(self : DbiHeader) -> UInt32 {
  self.version
}

///|
pub fn DbiHeader::age(self : DbiHeader) -> UInt32 {
  self.age
}

///|
pub fn DbiHeader::global_symbol_stream_index(self : DbiHeader) -> UInt16 {
  self.global_symbol_stream_index
}

///|
pub fn DbiHeader::build_number(self : DbiHeader) -> UInt16 {
  self.build_number
}

///|
pub fn DbiHeader::build_major_version(self : DbiHeader) -> UInt16 {
  (self.build_number >> 8) & 0x7F
}

///|
pub fn DbiHeader::build_minor_version(self : DbiHeader) -> UInt16 {
  self.build_number & 0x00FF
}

///|
pub fn DbiHeader::uses_new_version_format(self : DbiHeader) -> Bool {
  (self.build_number & 0x8000) != 0
}

///|
pub fn DbiHeader::public_symbol_stream_index(self : DbiHeader) -> UInt16 {
  self.public_symbol_stream_index
}

///|
pub fn DbiHeader::pdb_dll_version(self : DbiHeader) -> UInt16 {
  self.pdb_dll_version
}

///|
pub fn DbiHeader::symbol_record_stream_index(self : DbiHeader) -> UInt16 {
  self.symbol_record_stream_index
}

///|
pub fn DbiHeader::pdb_dll_rebuild(self : DbiHeader) -> UInt16 {
  self.pdb_dll_rebuild
}

///|
pub fn DbiHeader::modi_substream_bytes(self : DbiHeader) -> Int32 {
  self.modi_substream_bytes
}

///|
pub fn DbiHeader::section_contributions_bytes(self : DbiHeader) -> Int32 {
  self.section_contributions_bytes
}

///|
pub fn DbiHeader::section_map_bytes(self : DbiHeader) -> Int32 {
  self.section_map_bytes
}

///|
pub fn DbiHeader::file_info_bytes(self : DbiHeader) -> Int32 {
  self.file_info_bytes
}

///|
pub fn DbiHeader::type_server_map_bytes(self : DbiHeader) -> Int32 {
  self.type_server_map_bytes
}

///|
pub fn DbiHeader::mfc_type_server_index(self : DbiHeader) -> UInt32 {
  self.mfc_type_server_index
}

///|
pub fn DbiHeader::optional_debug_header_bytes(self : DbiHeader) -> Int32 {
  self.optional_debug_header_bytes
}

///|
pub fn DbiHeader::ec_substream_bytes(self : DbiHeader) -> Int32 {
  self.ec_substream_bytes
}

///|
pub fn DbiHeader::flags(self : DbiHeader) -> UInt16 {
  self.flags
}

///|
pub fn DbiHeader::is_incrementally_linked(self : DbiHeader) -> Bool {
  (self.flags & 0x0001) != 0
}

///|
pub fn DbiHeader::is_stripped(self : DbiHeader) -> Bool {
  (self.flags & 0x0002) != 0
}

///|
pub fn DbiHeader::has_c_types(self : DbiHeader) -> Bool {
  (self.flags & 0x0004) != 0
}

///|
pub fn DbiHeader::machine_type(self : DbiHeader) -> UInt16 {
  self.machine_type
}

///|
pub fn DbiHeader::reserved(self : DbiHeader) -> UInt32 {
  self.reserved
}

///|
/// One section contribution record.
pub struct SectionContribution {
  version : SectionContributionVersion
  section_index : UInt16
  offset : Int32
  size : Int32
  characteristics : UInt32
  module_index : UInt16
  data_crc : UInt32
  relocation_crc : UInt32
  coff_section_index : UInt32?
}

///|
pub fn SectionContribution::version(
  self : SectionContribution,
) -> SectionContributionVersion {
  self.version
}

///|
pub fn SectionContribution::section_index(self : SectionContribution) -> UInt16 {
  self.section_index
}

///|
pub fn SectionContribution::offset(self : SectionContribution) -> Int32 {
  self.offset
}

///|
pub fn SectionContribution::size(self : SectionContribution) -> Int32 {
  self.size
}

///|
pub fn SectionContribution::characteristics(
  self : SectionContribution,
) -> UInt32 {
  self.characteristics
}

///|
pub fn SectionContribution::module_index(self : SectionContribution) -> UInt16 {
  self.module_index
}

///|
pub fn SectionContribution::data_crc(self : SectionContribution) -> UInt32 {
  self.data_crc
}

///|
pub fn SectionContribution::relocation_crc(
  self : SectionContribution,
) -> UInt32 {
  self.relocation_crc
}

///|
pub fn SectionContribution::coff_section_index(
  self : SectionContribution,
) -> UInt32? {
  self.coff_section_index
}

///|
/// One logical-to-physical section mapping.
pub struct SectionMapEntry {
  flags : UInt16
  overlay : UInt16
  group : UInt16
  frame : UInt16
  section_name_offset : UInt16
  class_name_offset : UInt16
  offset : UInt32
  byte_length : UInt32
}

///|
pub fn SectionMapEntry::flags(self : SectionMapEntry) -> UInt16 {
  self.flags
}

///|
pub fn SectionMapEntry::overlay(self : SectionMapEntry) -> UInt16 {
  self.overlay
}

///|
pub fn SectionMapEntry::group(self : SectionMapEntry) -> UInt16 {
  self.group
}

///|
pub fn SectionMapEntry::frame(self : SectionMapEntry) -> UInt16 {
  self.frame
}

///|
pub fn SectionMapEntry::section_name_offset(self : SectionMapEntry) -> UInt16 {
  self.section_name_offset
}

///|
pub fn SectionMapEntry::class_name_offset(self : SectionMapEntry) -> UInt16 {
  self.class_name_offset
}

///|
pub fn SectionMapEntry::offset(self : SectionMapEntry) -> UInt32 {
  self.offset
}

///|
pub fn SectionMapEntry::byte_length(self : SectionMapEntry) -> UInt32 {
  self.byte_length
}

///|
/// A parsed section map and its two declared counts.
pub struct SectionMap {
  physical_count : UInt16
  logical_count : UInt16
  entries : Array[SectionMapEntry]
}

///|
pub fn SectionMap::physical_count(self : SectionMap) -> UInt16 {
  self.physical_count
}

///|
pub fn SectionMap::logical_count(self : SectionMap) -> UInt16 {
  self.logical_count
}

///|
pub fn SectionMap::entry_count(self : SectionMap) -> Int32 {
  self.entries.length()
}

///|
pub fn SectionMap::entry(self : SectionMap, index : Int32) -> SectionMapEntry? {
  if index < 0 || index >= self.entries.length() {
    None
  } else {
    Some(self.entries[index])
  }
}

///|
/// One variable-length module descriptor from the MODI substream.
pub struct DbiModule {
  record_index : Int32
  module_name : String
  object_name : String
  section_contribution : SectionContribution
  flags : UInt16
  module_stream_index : UInt16
  symbol_debug_bytes : UInt32
  c11_line_bytes : UInt32
  c13_line_bytes : UInt32
  declared_source_file_count : UInt16
  source_file_name_index : UInt32
  pdb_file_path_index : UInt32
  source_files : Array[String]
}

///|
pub fn DbiModule::record_index(self : DbiModule) -> Int32 {
  self.record_index
}

///|
pub fn DbiModule::module_name(self : DbiModule) -> String {
  self.module_name
}

///|
pub fn DbiModule::object_name(self : DbiModule) -> String {
  self.object_name
}

///|
pub fn DbiModule::section_contribution(self : DbiModule) -> SectionContribution {
  self.section_contribution
}

///|
pub fn DbiModule::flags(self : DbiModule) -> UInt16 {
  self.flags
}

///|
pub fn DbiModule::has_ec_info(self : DbiModule) -> Bool {
  (self.flags & 0x0002) != 0
}

///|
pub fn DbiModule::type_server_index(self : DbiModule) -> UInt16 {
  (self.flags >> 8) & 0x00FF
}

///|
pub fn DbiModule::module_stream_index(self : DbiModule) -> UInt16 {
  self.module_stream_index
}

///|
pub fn DbiModule::symbol_debug_bytes(self : DbiModule) -> UInt32 {
  self.symbol_debug_bytes
}

///|
pub fn DbiModule::c11_line_bytes(self : DbiModule) -> UInt32 {
  self.c11_line_bytes
}

///|
pub fn DbiModule::c13_line_bytes(self : DbiModule) -> UInt32 {
  self.c13_line_bytes
}

///|
pub fn DbiModule::declared_source_file_count(self : DbiModule) -> UInt16 {
  self.declared_source_file_count
}

///|
pub fn DbiModule::source_file_name_index(self : DbiModule) -> UInt32 {
  self.source_file_name_index
}

///|
pub fn DbiModule::pdb_file_path_index(self : DbiModule) -> UInt32 {
  self.pdb_file_path_index
}

///|
pub fn DbiModule::source_files(self : DbiModule) -> Array[String] {
  self.source_files.copy()
}

///|
fn DbiModule::with_source_files(
  self : DbiModule,
  source_files : Array[String],
) -> DbiModule {
  DbiModule::{
    record_index: self.record_index,
    module_name: self.module_name,
    object_name: self.object_name,
    section_contribution: self.section_contribution,
    flags: self.flags,
    module_stream_index: self.module_stream_index,
    symbol_debug_bytes: self.symbol_debug_bytes,
    c11_line_bytes: self.c11_line_bytes,
    c13_line_bytes: self.c13_line_bytes,
    declared_source_file_count: self.declared_source_file_count,
    source_file_name_index: self.source_file_name_index,
    pdb_file_path_index: self.pdb_file_path_index,
    source_files,
  }
}

///|
/// A parsed DBI stream with its addressable substreams.
pub struct DbiFile {
  data : Bytes
  header : DbiHeader
  modules : Array[DbiModule]
  section_contributions : Array[SectionContribution]
  section_contribution_version : SectionContributionVersion
  section_map : SectionMap
  reported_source_file_count : UInt16
  type_server_map : Bytes
  ec_substream : Bytes
  optional_debug_streams : Array[UInt16]
}

///|
pub fn DbiFile::data(self : DbiFile) -> Bytes {
  self.data
}

///|
pub fn DbiFile::header(self : DbiFile) -> DbiHeader {
  self.header
}

///|
pub fn DbiFile::module_count(self : DbiFile) -> Int32 {
  self.modules.length()
}

///|
pub fn DbiFile::module_at(self : DbiFile, index : Int32) -> DbiModule? {
  if index < 0 || index >= self.modules.length() {
    None
  } else {
    Some(self.modules[index])
  }
}

///|
pub fn DbiFile::modules(self : DbiFile) -> Array[DbiModule] {
  self.modules.copy()
}

///|
pub fn DbiFile::section_contribution_count(self : DbiFile) -> Int32 {
  self.section_contributions.length()
}

///|
pub fn DbiFile::section_contribution(
  self : DbiFile,
  index : Int32,
) -> SectionContribution? {
  if index < 0 || index >= self.section_contributions.length() {
    None
  } else {
    Some(self.section_contributions[index])
  }
}

///|
pub fn DbiFile::section_contribution_version(
  self : DbiFile,
) -> SectionContributionVersion {
  self.section_contribution_version
}

///|
pub fn DbiFile::section_map(self : DbiFile) -> SectionMap {
  self.section_map
}

///|
pub fn DbiFile::reported_source_file_count(self : DbiFile) -> UInt16 {
  self.reported_source_file_count
}

///|
pub fn DbiFile::source_file_count(self : DbiFile) -> Int32 {
  let mut count = 0
  for item in self.modules {
    count = count + item.source_files.length()
  }
  count
}

///|
pub fn DbiFile::type_server_map(self : DbiFile) -> Bytes {
  self.type_server_map
}

///|
pub fn DbiFile::ec_substream(self : DbiFile) -> Bytes {
  self.ec_substream
}

///|
pub fn DbiFile::optional_debug_streams(self : DbiFile) -> Array[UInt16] {
  self.optional_debug_streams.copy()
}

///|
pub fn DbiFile::debug_stream_index(
  self : DbiFile,
  kind : DebugStreamKind,
) -> UInt16? {
  let index = match kind {
    Fpo => 0
    Exception => 1
    Fixup => 2
    OmapToSrc => 3
    OmapFromSrc => 4
    SectionHdr => 5
    TokenRidMap => 6
    Xdata => 7
    Pdata => 8
    NewFpo => 9
    SectionHdrOrig => 10
  }
  if index < 0 || index >= self.optional_debug_streams.length() {
    None
  } else {
    Some(self.optional_debug_streams[index])
  }
}

///|
/// Parse stream 3 of an MSF file as the DBI stream.
pub fn MsfFile::dbi(
  self : MsfFile,
  limits : DbiLimits,
) -> DbiFile raise DbiError {
  let bytes = self.stream(3) catch { _ => raise DbiStreamUnavailable }
  parse_dbi(bytes, limits)
}

///|
/// Parse a complete DBI stream and all bounded substreams.
pub fn parse_dbi(data : Bytes, limits : DbiLimits) -> DbiFile raise DbiError {
  if data.length() > limits.max_stream_bytes {
    raise DbiLimitExceeded("DBI stream byte limit exceeded")
  }
  let header = parse_dbi_header(data)
  let expected_size = dbi_substream_end(header)
  if expected_size != data.length() {
    raise InvalidDbiHeader(
      "DBI stream length does not equal the header and substream sizes",
    )
  }
  validate_dbi_alignment(header)
  let modi_start = DBI_HEADER_SIZE
  let modi_end = checked_dbi_add(
    modi_start,
    header.modi_substream_bytes,
    "MODI substream",
  )
  let contributions_end = checked_dbi_add(
    modi_end,
    header.section_contributions_bytes,
    "section contribution substream",
  )
  let section_map_end = checked_dbi_add(
    contributions_end,
    header.section_map_bytes,
    "section map substream",
  )
  let file_info_end = checked_dbi_add(
    section_map_end,
    header.file_info_bytes,
    "file info substream",
  )
  let type_server_end = checked_dbi_add(
    file_info_end,
    header.type_server_map_bytes,
    "type server map substream",
  )
  let ec_end = checked_dbi_add(
    type_server_end,
    header.ec_substream_bytes,
    "EC substream",
  )
  let debug_end = checked_dbi_add(
    ec_end,
    header.optional_debug_header_bytes,
    "optional debug header",
  )
  if debug_end != data.length() {
    raise InvalidDbiHeader("DBI substreams do not cover the complete stream")
  }
  let modules = parse_dbi_modules(
    data.exact_view(start=modi_start, end=modi_end).to_owned(),
    limits,
  )
  let (contribution_version, contributions) = parse_section_contributions(
    data.exact_view(start=modi_end, end=contributions_end).to_owned(),
    limits,
  )
  let section_map = parse_section_map(
    data.exact_view(start=contributions_end, end=section_map_end).to_owned(),
    limits,
  )
  let (modules, reported_source_file_count) = attach_file_info(
    data.exact_view(start=section_map_end, end=file_info_end).to_owned(),
    modules,
    limits,
  )
  let optional_debug_streams = parse_optional_debug_header(
    data.exact_view(start=ec_end, end=debug_end).to_owned(),
    limits,
  )
  DbiFile::{
    data,
    header,
    modules,
    section_contributions: contributions,
    section_contribution_version: contribution_version,
    section_map,
    reported_source_file_count,
    type_server_map: data
    .exact_view(start=file_info_end, end=type_server_end)
    .to_owned(),
    ec_substream: data.exact_view(start=type_server_end, end=ec_end).to_owned(),
    optional_debug_streams,
  }
}

///|
fn parse_dbi_header(data : Bytes) -> DbiHeader raise DbiError {
  require_dbi_bytes(data, 0, DBI_HEADER_SIZE, "DBI header")
  let (version_signature, cursor) = read_dbi_u32(data, 0, DBI_HEADER_SIZE)
  if version_signature != DBI_VERSION_SIGNATURE {
    raise InvalidDbiHeader("DBI version signature must be 0xFFFFFFFF")
  }
  let (version, cursor) = read_dbi_u32(data, cursor, DBI_HEADER_SIZE)
  if version < DBI_VERSION_70 {
    raise UnsupportedDbiVersion(version)
  }
  let (age, cursor) = read_dbi_u32(data, cursor, DBI_HEADER_SIZE)
  let (global_symbol_stream_index, cursor) = read_dbi_u16(
    data,
    cursor,
    DBI_HEADER_SIZE,
  )
  let (build_number, cursor) = read_dbi_u16(data, cursor, DBI_HEADER_SIZE)
  let (public_symbol_stream_index, cursor) = read_dbi_u16(
    data,
    cursor,
    DBI_HEADER_SIZE,
  )
  let (pdb_dll_version, cursor) = read_dbi_u16(data, cursor, DBI_HEADER_SIZE)
  let (symbol_record_stream_index, cursor) = read_dbi_u16(
    data,
    cursor,
    DBI_HEADER_SIZE,
  )
  let (pdb_dll_rebuild, cursor) = read_dbi_u16(data, cursor, DBI_HEADER_SIZE)
  let (modi_substream_bytes, cursor) = read_dbi_i32(
    data,
    cursor,
    DBI_HEADER_SIZE,
  )
  let (section_contributions_bytes, cursor) = read_dbi_i32(
    data,
    cursor,
    DBI_HEADER_SIZE,
  )
  let (section_map_bytes, cursor) = read_dbi_i32(data, cursor, DBI_HEADER_SIZE)
  let (file_info_bytes, cursor) = read_dbi_i32(data, cursor, DBI_HEADER_SIZE)
  let (type_server_map_bytes, cursor) = read_dbi_i32(
    data,
    cursor,
    DBI_HEADER_SIZE,
  )
  let (mfc_type_server_index, cursor) = read_dbi_u32(
    data,
    cursor,
    DBI_HEADER_SIZE,
  )
  let (optional_debug_header_bytes, cursor) = read_dbi_i32(
    data,
    cursor,
    DBI_HEADER_SIZE,
  )
  let (ec_substream_bytes, cursor) = read_dbi_i32(data, cursor, DBI_HEADER_SIZE)
  let (flags, cursor) = read_dbi_u16(data, cursor, DBI_HEADER_SIZE)
  let (machine_type, cursor) = read_dbi_u16(data, cursor, DBI_HEADER_SIZE)
  let (reserved, cursor) = read_dbi_u32(data, cursor, DBI_HEADER_SIZE)
  if cursor != DBI_HEADER_SIZE {
    raise InvalidDbiHeader("DBI header did not consume exactly 64 bytes")
  }
  let sizes = [
    modi_substream_bytes, section_contributions_bytes, section_map_bytes, file_info_bytes,
    type_server_map_bytes, optional_debug_header_bytes, ec_substream_bytes,
  ]
  for size in sizes {
    if size < 0 {
      raise InvalidDbiHeader("DBI substream size must not be negative")
    }
  }
  DbiHeader::{
    version_signature,
    version,
    age,
    global_symbol_stream_index,
    build_number,
    public_symbol_stream_index,
    pdb_dll_version,
    symbol_record_stream_index,
    pdb_dll_rebuild,
    modi_substream_bytes,
    section_contributions_bytes,
    section_map_bytes,
    file_info_bytes,
    type_server_map_bytes,
    mfc_type_server_index,
    optional_debug_header_bytes,
    ec_substream_bytes,
    flags,
    machine_type,
    reserved,
  }
}

///|
fn dbi_substream_end(header : DbiHeader) -> Int32 raise DbiError {
  let mut end = DBI_HEADER_SIZE
  end = checked_dbi_add(end, header.modi_substream_bytes, "MODI substream")
  end = checked_dbi_add(
    end,
    header.section_contributions_bytes,
    "section contribution substream",
  )
  end = checked_dbi_add(end, header.section_map_bytes, "section map substream")
  end = checked_dbi_add(end, header.file_info_bytes, "file info substream")
  end = checked_dbi_add(
    end,
    header.type_server_map_bytes,
    "type server map substream",
  )
  end = checked_dbi_add(end, header.ec_substream_bytes, "EC substream")
  checked_dbi_add(
    end,
    header.optional_debug_header_bytes,
    "optional debug header",
  )
}

///|
fn validate_dbi_alignment(header : DbiHeader) -> Unit raise DbiError {
  if header.modi_substream_bytes % 4 != 0 {
    raise InvalidDbiHeader("MODI substream is not 4-byte aligned")
  }
  if header.section_contributions_bytes % 4 != 0 {
    raise InvalidDbiHeader("section contribution substream is not aligned")
  }
  if header.section_map_bytes % 4 != 0 {
    raise InvalidDbiHeader("section map substream is not aligned")
  }
  if header.file_info_bytes % 4 != 0 {
    raise InvalidDbiHeader("file info substream is not aligned")
  }
  if header.type_server_map_bytes % 4 != 0 {
    raise InvalidDbiHeader("type server map substream is not aligned")
  }
  if header.optional_debug_header_bytes % 2 != 0 {
    raise InvalidDbiHeader("optional debug header is not uint16-aligned")
  }
}

///|
fn parse_section_contributions(
  data : Bytes,
  limits : DbiLimits,
) -> (SectionContributionVersion, Array[SectionContribution]) raise DbiError {
  if data.length() == 0 {
    return (None, [])
  }
  require_dbi_bytes(data, 0, 4, "section contribution version")
  let (version_raw, cursor0) = read_dbi_u32(data, 0, data.length())
  let mut cursor = cursor0
  let version = if version_raw == DBI_SECTION_CONTRIBUTION_60 {
    V60
  } else if version_raw == DBI_SECTION_CONTRIBUTION_2 {
    V2
  } else {
    raise UnsupportedSectionContributionVersion(version_raw)
  }
  let record_size = match version {
    V60 => DBI_SECTION_CONTRIB_60_SIZE
    V2 => DBI_SECTION_CONTRIB_2_SIZE
    None => 0
  }
  let remaining = data.length() - cursor
  if remaining % record_size != 0 {
    raise InvalidSectionContribution(
      "section contribution bytes do not match the record size",
    )
  }
  let count = remaining / record_size
  if count > limits.max_section_contributions {
    raise DbiLimitExceeded("section contribution count limit exceeded")
  }
  let contributions = []
  for _ in 0..<count {
    let (contribution, next) = read_section_contribution(
      data,
      cursor,
      data.length(),
      version,
    )
    contributions.push(contribution)
    cursor = next
  }
  (version, contributions)
}

///|
fn read_section_contribution(
  data : Bytes,
  start : Int32,
  end : Int32,
  version : SectionContributionVersion,
) -> (SectionContribution, Int32) raise DbiError {
  let record_size = match version {
    V60 => DBI_SECTION_CONTRIB_60_SIZE
    V2 => DBI_SECTION_CONTRIB_2_SIZE
    None => raise InvalidSectionContribution("missing contribution version")
  }
  require_dbi_bytes(data, start, record_size, "section contribution record")
  let record_end = checked_dbi_add(start, record_size, "section contribution")
  if record_end > end {
    raise TruncatedDbi(record_end)
  }
  let (section_index, cursor) = read_dbi_u16(data, start, record_end)
  let (_, cursor) = read_dbi_u16(data, cursor, record_end)
  let (offset, cursor) = read_dbi_i32(data, cursor, record_end)
  let (size, cursor) = read_dbi_i32(data, cursor, record_end)
  let (characteristics, cursor) = read_dbi_u32(data, cursor, record_end)
  let (module_index, cursor) = read_dbi_u16(data, cursor, record_end)
  let (_, cursor) = read_dbi_u16(data, cursor, record_end)
  let (data_crc, cursor) = read_dbi_u32(data, cursor, record_end)
  let (relocation_crc, cursor) = read_dbi_u32(data, cursor, record_end)
  let (coff_section_index, cursor) = match version {
    V2 => {
      let (value, next) = read_dbi_u32(data, cursor, record_end)
      (Some(value), next)
    }
    _ => (None, cursor)
  }
  if cursor != record_end {
    raise InvalidSectionContribution(
      "section contribution has unexpected trailing bytes",
    )
  }
  (
    SectionContribution::{
      version,
      section_index,
      offset,
      size,
      characteristics,
      module_index,
      data_crc,
      relocation_crc,
      coff_section_index,
    },
    record_end,
  )
}

///|
fn parse_section_map(
  data : Bytes,
  limits : DbiLimits,
) -> SectionMap raise DbiError {
  if data.length() == 0 {
    return SectionMap::{ physical_count: 0, logical_count: 0, entries: [], }
  }
  require_dbi_bytes(data, 0, DBI_SECTION_MAP_HEADER_SIZE, "section map header")
  let (physical_count, cursor) = read_dbi_u16(
    data,
    0,
    DBI_SECTION_MAP_HEADER_SIZE,
  )
  let (logical_count, _) = read_dbi_u16(
    data,
    cursor,
    DBI_SECTION_MAP_HEADER_SIZE,
  )
  let count = physical_count.to_int()
  if count > limits.max_section_map_entries {
    raise DbiLimitExceeded("section map entry limit exceeded")
  }
  let expected_size = checked_dbi_add(
    DBI_SECTION_MAP_HEADER_SIZE,
    checked_dbi_mul(count, DBI_SECTION_MAP_ENTRY_SIZE, "section map"),
    "section map",
  )
  if expected_size != data.length() {
    raise InvalidSectionMap("section map size does not match its entry count")
  }
  let entries = []
  let mut cursor = DBI_SECTION_MAP_HEADER_SIZE
  for _ in 0..<count {
    let (entry, next) = read_section_map_entry(data, cursor, data.length())
    entries.push(entry)
    cursor = next
  }
  SectionMap::{ physical_count, logical_count, entries, }
}

///|
fn read_section_map_entry(
  data : Bytes,
  start : Int32,
  end : Int32,
) -> (SectionMapEntry, Int32) raise DbiError {
  require_dbi_bytes(
    data,
    start,
    DBI_SECTION_MAP_ENTRY_SIZE,
    "section map entry",
  )
  let entry_end = checked_dbi_add(
    start,
    DBI_SECTION_MAP_ENTRY_SIZE,
    "section map entry",
  )
  if entry_end > end {
    raise TruncatedDbi(entry_end)
  }
  let (flags, cursor) = read_dbi_u16(data, start, entry_end)
  let (overlay, cursor) = read_dbi_u16(data, cursor, entry_end)
  let (group, cursor) = read_dbi_u16(data, cursor, entry_end)
  let (frame, cursor) = read_dbi_u16(data, cursor, entry_end)
  let (section_name_offset, cursor) = read_dbi_u16(data, cursor, entry_end)
  let (class_name_offset, cursor) = read_dbi_u16(data, cursor, entry_end)
  let (offset, cursor) = read_dbi_u32(data, cursor, entry_end)
  let (byte_length, cursor) = read_dbi_u32(data, cursor, entry_end)
  if cursor != entry_end {
    raise InvalidSectionMap("section map entry has trailing bytes")
  }
  (
    SectionMapEntry::{
      flags,
      overlay,
      group,
      frame,
      section_name_offset,
      class_name_offset,
      offset,
      byte_length,
    },
    entry_end,
  )
}

///|
fn parse_dbi_modules(
  data : Bytes,
  limits : DbiLimits,
) -> Array[DbiModule] raise DbiError {
  if data.length() == 0 {
    return []
  }
  if data.length() > limits.max_string_bytes {
    raise DbiLimitExceeded("MODI string data limit exceeded")
  }
  let modules = []
  let mut position = 0
  while position < data.length() {
    if modules.length() >= limits.max_modules {
      raise DbiLimitExceeded("module count limit exceeded")
    }
    let record_start = position
    require_dbi_bytes(data, position, DBI_MODULE_HEADER_SIZE, "module record")
    let (_, cursor) = read_dbi_u32(data, position, data.length())
    let (section_contribution, cursor) = read_section_contribution(
      data,
      cursor,
      data.length(),
      V60,
    )
    let (flags, cursor) = read_dbi_u16(data, cursor, data.length())
    let (module_stream_index, cursor) = read_dbi_u16(
      data,
      cursor,
      data.length(),
    )
    let (symbol_debug_bytes, cursor) = read_dbi_u32(data, cursor, data.length())
    let (c11_line_bytes, cursor) = read_dbi_u32(data, cursor, data.length())
    let (c13_line_bytes, cursor) = read_dbi_u32(data, cursor, data.length())
    let (declared_source_file_count, cursor) = read_dbi_u16(
      data,
      cursor,
      data.length(),
    )
    let (_, cursor) = read_dbi_u16(data, cursor, data.length())
    let (_, cursor) = read_dbi_u32(data, cursor, data.length())
    let (source_file_name_index, cursor) = read_dbi_u32(
      data,
      cursor,
      data.length(),
    )
    let (pdb_file_path_index, cursor) = read_dbi_u32(
      data,
      cursor,
      data.length(),
    )
    let (module_name, cursor) = read_dbi_string(data, cursor, data.length())
    let (object_name, cursor) = read_dbi_string(data, cursor, data.length())
    let record_size = align_dbi4(cursor - record_start)
    let record_end = checked_dbi_add(
      record_start, record_size, "module record end",
    )
    if record_end > data.length() {
      raise TruncatedDbi(record_end)
    }
    modules.push(DbiModule::{
      record_index: modules.length(),
      module_name,
      object_name,
      section_contribution,
      flags,
      module_stream_index,
      symbol_debug_bytes,
      c11_line_bytes,
      c13_line_bytes,
      declared_source_file_count,
      source_file_name_index,
      pdb_file_path_index,
      source_files: [],
    })
    position = record_end
  }
  if position != data.length() {
    raise InvalidDbiModule("MODI substream has trailing bytes")
  }
  modules
}

///|
fn attach_file_info(
  data : Bytes,
  modules : Array[DbiModule],
  limits : DbiLimits,
) -> (Array[DbiModule], UInt16) raise DbiError {
  if data.length() == 0 {
    for item in modules {
      if item.declared_source_file_count != 0 {
        raise InvalidFileInfo("module source files exist without file info")
      }
    }
    return (modules, 0)
  }
  if data.length() > limits.max_string_bytes {
    raise DbiLimitExceeded("file info string data limit exceeded")
  }
  require_dbi_bytes(data, 0, DBI_FILE_INFO_HEADER_SIZE, "file info header")
  let (num_modules, cursor) = read_dbi_u16(data, 0, DBI_FILE_INFO_HEADER_SIZE)
  let (reported_source_file_count, _) = read_dbi_u16(
    data,
    cursor,
    DBI_FILE_INFO_HEADER_SIZE,
  )
  if num_modules.to_int() != modules.length() {
    raise InvalidFileInfo("file info module count does not match MODI records")
  }
  let module_count = num_modules.to_int()
  let module_indices_end = checked_dbi_add(
    DBI_FILE_INFO_HEADER_SIZE,
    checked_dbi_mul(module_count, 2, "module index array"),
    "module index array",
  )
  let counts_end = checked_dbi_add(
    module_indices_end,
    checked_dbi_mul(module_count, 2, "module file counts"),
    "module file counts",
  )
  if counts_end > data.length() {
    raise TruncatedDbi(counts_end)
  }
  let mut cursor = DBI_FILE_INFO_HEADER_SIZE
  for _ in 0..<module_count {
    let (module_index, next) = read_dbi_u16(data, cursor, module_indices_end)
    if module_index.to_int() >= module_count {
      raise InvalidFileInfo("module index is outside the module table")
    }
    cursor = next
  }
  let file_counts = []
  let mut total_source_files = 0
  for _ in 0..<module_count {
    let (count, next) = read_dbi_u16(data, cursor, counts_end)
    total_source_files = checked_dbi_add(
      total_source_files,
      count.to_int(),
      "source file count",
    )
    if total_source_files > limits.max_source_files {
      raise DbiLimitExceeded("source file count limit exceeded")
    }
    file_counts.push(count)
    cursor = next
  }
  let offsets_end = checked_dbi_add(
    cursor,
    checked_dbi_mul(total_source_files, 4, "source file offsets"),
    "source file offsets",
  )
  if offsets_end > data.length() {
    raise TruncatedDbi(offsets_end)
  }
  let offsets = []
  for _ in 0..<total_source_files {
    let (offset, next) = read_dbi_u32(data, cursor, offsets_end)
    offsets.push(offset)
    cursor = next
  }
  let names = data.exact_view(start=offsets_end, end=data.length()).to_owned()
  let flat_source_files = []
  for offset_raw in offsets {
    let offset = dbi_uint_to_int(offset_raw, "source file name offset")
    let (name, _) = read_dbi_string(names, offset, names.length())
    flat_source_files.push(name)
  }
  let updated_modules = []
  let mut next_file = 0
  for index in 0..<module_count {
    let count = file_counts[index].to_int()
    if count != modules[index].declared_source_file_count.to_int() {
      raise InvalidFileInfo(
        "file info count does not match the module descriptor",
      )
    }
    let files = []
    for _ in 0..<count {
      files.push(flat_source_files[next_file])
      next_file = next_file + 1
    }
    updated_modules.push(modules[index].with_source_files(files))
  }
  if next_file != total_source_files {
    raise InvalidFileInfo("source file table is inconsistent")
  }
  (updated_modules, reported_source_file_count)
}

///|
fn parse_optional_debug_header(
  data : Bytes,
  limits : DbiLimits,
) -> Array[UInt16] raise DbiError {
  if data.length() % 2 != 0 {
    raise InvalidDbiHeader("optional debug header has an odd byte count")
  }
  let count = data.length() / 2
  if count > limits.max_debug_streams {
    raise DbiLimitExceeded("optional debug stream count limit exceeded")
  }
  let streams = []
  let mut cursor = 0
  for _ in 0..<count {
    let (stream, next) = read_dbi_u16(data, cursor, data.length())
    streams.push(stream)
    cursor = next
  }
  streams
}

///|
fn read_dbi_string(
  data : Bytes,
  start : Int32,
  end : Int32,
) -> (String, Int32) raise DbiError {
  if start < 0 || start >= end {
    raise TruncatedDbi(start)
  }
  let mut cursor = start
  while cursor < end {
    if data.at(cursor) == 0 {
      let name = @utf8.decode_lossy(data.exact_view(start~, end=cursor))
      return (name, cursor + 1)
    }
    cursor = cursor + 1
  }
  raise InvalidDbiModule("DBI name is not NUL-terminated")
}

///|
fn read_dbi_u16(
  data : Bytes,
  pos : Int32,
  end : Int32,
) -> (UInt16, Int32) raise DbiError {
  require_dbi_bytes(data, pos, 2, "uint16 field")
  if pos + 2 > end {
    raise TruncatedDbi(pos + 2)
  }
  let value = ((data.at(pos + 1).to_int() << 8) | data.at(pos).to_int()).to_uint16()
  (value, pos + 2)
}

///|
fn read_dbi_u32(
  data : Bytes,
  pos : Int32,
  end : Int32,
) -> (UInt32, Int32) raise DbiError {
  require_dbi_bytes(data, pos, 4, "uint32 field")
  if pos + 4 > end {
    raise TruncatedDbi(pos + 4)
  }
  let value = UInt32(
    (data.at(pos + 3).to_int().reinterpret_as_uint() << 24) |
    (data.at(pos + 2).to_int().reinterpret_as_uint() << 16) |
    (data.at(pos + 1).to_int().reinterpret_as_uint() << 8) |
    data.at(pos).to_int().reinterpret_as_uint(),
  )
  (value, pos + 4)
}

///|
fn read_dbi_i32(
  data : Bytes,
  pos : Int32,
  end : Int32,
) -> (Int32, Int32) raise DbiError {
  let (value, next) = read_dbi_u32(data, pos, end)
  (value.reinterpret_as_int(), next)
}

///|
fn require_dbi_bytes(
  data : Bytes,
  start : Int32,
  length : Int32,
  _field : String,
) -> Unit raise DbiError {
  if start < 0 || length < 0 {
    raise TruncatedDbi(start)
  }
  let end = checked_dbi_add(start, length, "DBI field")
  if end > data.length() {
    raise TruncatedDbi(end)
  }
}

///|
fn dbi_uint_to_int(value : UInt32, field : String) -> Int32 raise DbiError {
  if value > 0x7FFFFFFFU {
    raise InvalidDbiHeader("\{field} exceeds Int range")
  }
  value.reinterpret_as_int()
}

///|
fn align_dbi4(value : Int32) -> Int32 raise DbiError {
  if value < 0 || value > 0x7FFFFFFD {
    raise InvalidDbiModule("module record size overflows Int range")
  }
  (value + 3) / 4 * 4
}

///|
fn checked_dbi_add(
  left : Int32,
  right : Int32,
  field : String,
) -> Int32 raise DbiError {
  if left < 0 || right < 0 || left > 0x7FFFFFFF - right {
    raise InvalidDbiHeader("\{field} overflows Int range")
  }
  left + right
}

///|
fn checked_dbi_mul(
  left : Int32,
  right : Int32,
  field : String,
) -> Int32 raise DbiError {
  if left < 0 || right < 0 || (left != 0 && right > 0x7FFFFFFF / left) {
    raise InvalidDbiHeader("\{field} overflows Int range")
  }
  left * right
}
