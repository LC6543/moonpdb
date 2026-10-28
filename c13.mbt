///|
const C13_SUBSECTION_HEADER_SIZE : Int32 = 8

///|
const C13_LINE_FRAGMENT_HEADER_SIZE : Int32 = 12

///|
const C13_LINE_BLOCK_HEADER_SIZE : Int32 = 12

///|
const C13_LINE_ENTRY_SIZE : Int32 = 8

///|
const C13_COLUMN_ENTRY_SIZE : Int32 = 4

///|
const C13_CHECKSUM_HEADER_SIZE : Int32 = 6

///|
const C13_SUBSECTION_MASK : UInt32 = 0x7FFFFFFFU

///|
const C13_KIND_LINES : UInt32 = 0x000000F2U

///|
const C13_KIND_STRING_TABLE : UInt32 = 0x000000F3U

///|
const C13_KIND_FILE_CHECKSUMS : UInt32 = 0x000000F4U

///|
const C13_LINES_HAVE_COLUMNS : UInt16 = 0x0001

///|
/// Resource limits for one module's C13 debug subsections.
pub struct C13Limits {
  max_bytes : Int32
  max_subsections : Int32
  max_file_checksums : Int32
  max_line_fragments : Int32
  max_line_entries : Int32
}

///|
pub fn C13Limits::default() -> C13Limits {
  C13Limits::{
    max_bytes: 128 * 1024 * 1024,
    max_subsections: 4096,
    max_file_checksums: 1_000_000,
    max_line_fragments: 1_000_000,
    max_line_entries: 2_000_000,
  }
}

///|
/// One raw C13 debug subsection.
pub struct C13Subsection {
  kind : UInt32
  payload : Bytes
}

///|
pub fn C13Subsection::kind(self : C13Subsection) -> UInt32 {
  self.kind
}

///|
pub fn C13Subsection::payload(self : C13Subsection) -> Bytes {
  self.payload
}

///|
/// A flat CodeView string table addressed by byte offsets.
pub struct DebugStringTable {
  bytes : Bytes
}

///|
pub fn DebugStringTable::bytes(self : DebugStringTable) -> Bytes {
  self.bytes
}

///|
pub fn DebugStringTable::string_at(
  self : DebugStringTable,
  offset : UInt32,
) -> String? {
  let start = offset.reinterpret_as_int()
  if start < 0 || start >= self.bytes.length() {
    return None
  }
  let mut cursor = start
  while cursor < self.bytes.length() {
    if self.bytes.at(cursor) == 0 {
      return Some(@utf8.decode_lossy(self.bytes.exact_view(start~, end=cursor)))
    }
    cursor = cursor + 1
  }
  None
}

///|
/// One file-checksum entry in a C13 FileChecksums subsection.
pub struct FileChecksum {
  subsection_offset : UInt32
  file_name_offset : UInt32
  kind : Int32
  checksum : Bytes
  file_path : String
}

///|
pub fn FileChecksum::subsection_offset(self : FileChecksum) -> UInt32 {
  self.subsection_offset
}

///|
pub fn FileChecksum::file_name_offset(self : FileChecksum) -> UInt32 {
  self.file_name_offset
}

///|
pub fn FileChecksum::kind(self : FileChecksum) -> Int32 {
  self.kind
}

///|
pub fn FileChecksum::checksum(self : FileChecksum) -> Bytes {
  self.checksum
}

///|
pub fn FileChecksum::file_path(self : FileChecksum) -> String {
  self.file_path
}

///|
pub struct LineColumnRange {
  start : UInt16
  end : UInt16
}

///|
pub fn LineColumnRange::start(self : LineColumnRange) -> UInt16 {
  self.start
}

///|
pub fn LineColumnRange::end(self : LineColumnRange) -> UInt16 {
  self.end
}

///|
pub struct LineNumber {
  offset : UInt32
  line_start : UInt32
  line_end : UInt32
  is_statement : Bool
  columns : LineColumnRange?
}

///|
pub fn LineNumber::offset(self : LineNumber) -> UInt32 {
  self.offset
}

///|
pub fn LineNumber::line_start(self : LineNumber) -> UInt32 {
  self.line_start
}

///|
pub fn LineNumber::line_end(self : LineNumber) -> UInt32 {
  self.line_end
}

///|
pub fn LineNumber::is_statement(self : LineNumber) -> Bool {
  self.is_statement
}

///|
pub fn LineNumber::columns(self : LineNumber) -> LineColumnRange? {
  self.columns
}

///|
pub struct LineBlock {
  file_checksum_offset : UInt32
  file_path : String
  record_size : UInt32
  lines : Array[LineNumber]
}

///|
pub fn LineBlock::file_checksum_offset(self : LineBlock) -> UInt32 {
  self.file_checksum_offset
}

///|
pub fn LineBlock::file_path(self : LineBlock) -> String {
  self.file_path
}

///|
pub fn LineBlock::record_size(self : LineBlock) -> UInt32 {
  self.record_size
}

///|
pub fn LineBlock::line_count(self : LineBlock) -> Int32 {
  self.lines.length()
}

///|
pub fn LineBlock::line_at(self : LineBlock, index : Int32) -> LineNumber? {
  if index < 0 || index >= self.lines.length() {
    None
  } else {
    Some(self.lines[index])
  }
}

///|
pub struct LineFragment {
  relocation_offset : UInt32
  relocation_segment : UInt16
  flags : UInt16
  code_size : UInt32
  blocks : Array[LineBlock]
}

///|
pub fn LineFragment::relocation_offset(self : LineFragment) -> UInt32 {
  self.relocation_offset
}

///|
pub fn LineFragment::relocation_segment(self : LineFragment) -> UInt16 {
  self.relocation_segment
}

///|
pub fn LineFragment::flags(self : LineFragment) -> UInt16 {
  self.flags
}

///|
pub fn LineFragment::has_columns(self : LineFragment) -> Bool {
  (self.flags & C13_LINES_HAVE_COLUMNS) != 0
}

///|
pub fn LineFragment::code_size(self : LineFragment) -> UInt32 {
  self.code_size
}

///|
pub fn LineFragment::block_count(self : LineFragment) -> Int32 {
  self.blocks.length()
}

///|
pub fn LineFragment::block_at(self : LineFragment, index : Int32) -> LineBlock? {
  if index < 0 || index >= self.blocks.length() {
    None
  } else {
    Some(self.blocks[index])
  }
}

///|
/// A resolved source line at a segment-relative code offset.
pub struct SourceLocation {
  segment : UInt16
  code_offset : UInt32
  file_path : String
  line_start : UInt32
  line_end : UInt32
  is_statement : Bool
  columns : LineColumnRange?
}

///|
pub fn SourceLocation::segment(self : SourceLocation) -> UInt16 {
  self.segment
}

///|
pub fn SourceLocation::code_offset(self : SourceLocation) -> UInt32 {
  self.code_offset
}

///|
pub fn SourceLocation::file_path(self : SourceLocation) -> String {
  self.file_path
}

///|
pub fn SourceLocation::line_start(self : SourceLocation) -> UInt32 {
  self.line_start
}

///|
pub fn SourceLocation::line_end(self : SourceLocation) -> UInt32 {
  self.line_end
}

///|
pub fn SourceLocation::is_statement(self : SourceLocation) -> Bool {
  self.is_statement
}

///|
pub fn SourceLocation::columns(self : SourceLocation) -> LineColumnRange? {
  self.columns
}

///|
/// Parsed C13 subsections, file checksums, and line contributions.
pub struct C13DebugInfo {
  subsections : Array[C13Subsection]
  string_table : DebugStringTable?
  checksums : Array[FileChecksum]
  line_fragments : Array[LineFragment]
}

///|
pub fn C13DebugInfo::subsection_count(self : C13DebugInfo) -> Int32 {
  self.subsections.length()
}

///|
pub fn C13DebugInfo::subsection_at(
  self : C13DebugInfo,
  index : Int32,
) -> C13Subsection? {
  if index < 0 || index >= self.subsections.length() {
    None
  } else {
    Some(self.subsections[index])
  }
}

///|
pub fn C13DebugInfo::string_table(self : C13DebugInfo) -> DebugStringTable? {
  self.string_table
}

///|
pub fn C13DebugInfo::file_checksum_count(self : C13DebugInfo) -> Int32 {
  self.checksums.length()
}

///|
pub fn C13DebugInfo::file_checksum_at(
  self : C13DebugInfo,
  index : Int32,
) -> FileChecksum? {
  if index < 0 || index >= self.checksums.length() {
    None
  } else {
    Some(self.checksums[index])
  }
}

///|
pub fn C13DebugInfo::line_fragment_count(self : C13DebugInfo) -> Int32 {
  self.line_fragments.length()
}

///|
pub fn C13DebugInfo::line_fragment_at(
  self : C13DebugInfo,
  index : Int32,
) -> LineFragment? {
  if index < 0 || index >= self.line_fragments.length() {
    None
  } else {
    Some(self.line_fragments[index])
  }
}

///|
pub fn C13DebugInfo::find_line(
  self : C13DebugInfo,
  segment : UInt16,
  offset : UInt32,
) -> SourceLocation? {
  for fragment in self.line_fragments {
    let fragment_end = fragment.relocation_offset.to_uint64() +
      fragment.code_size.to_uint64()
    if fragment.relocation_segment == segment &&
      offset.to_uint64() >= fragment.relocation_offset.to_uint64() &&
      offset.to_uint64() < fragment_end {
      let mut best : (LineBlock, LineNumber)? = None
      for block in fragment.blocks {
        for line in block.lines {
          if line.offset.to_uint64() <= offset.to_uint64() {
            let replace = match best {
              Some((_, current)) =>
                line.offset.to_uint64() > current.offset.to_uint64()
              None => true
            }
            if replace {
              best = Some((block, line))
            }
          }
        }
      }
      match best {
        Some((block, line)) =>
          return Some(SourceLocation::{
            segment,
            code_offset: offset,
            file_path: block.file_path,
            line_start: line.line_start,
            line_end: line.line_end,
            is_statement: line.is_statement,
            columns: line.columns,
          })
        None => ()
      }
    }
  }
  None
}

///|
/// Parse the C13 subsection buffer stored in a module debug stream.
pub fn ModuleDebugStream::c13_info(
  self : ModuleDebugStream,
  limits : C13Limits,
) -> C13DebugInfo raise SymbolError {
  parse_c13_debug_info(self.c13_lines, limits)
}

///|
/// Read a module debug stream and parse its C13 line information.
pub fn MsfFile::module_c13_info(
  self : MsfFile,
  dbi : DbiFile,
  module_index : Int32,
  symbol_limits : SymbolLimits,
  limits : C13Limits,
) -> C13DebugInfo raise SymbolError {
  let debug = self.module_debug_stream(dbi, module_index, symbol_limits)
  debug.c13_info(limits)
}

///|
pub fn parse_c13_debug_info(
  data : Bytes,
  limits : C13Limits,
) -> C13DebugInfo raise SymbolError {
  if data.length() > limits.max_bytes {
    raise C13LimitExceeded("C13 debug byte limit exceeded")
  }
  let subsections = parse_c13_subsections(data, limits)
  let mut string_table : DebugStringTable? = None
  for subsection in subsections {
    if subsection.kind == C13_KIND_STRING_TABLE {
      string_table = Some(DebugStringTable::{ bytes: subsection.payload, })
      break
    }
  }
  let checksums = if has_c13_subsection(subsections, C13_KIND_FILE_CHECKSUMS) {
    let table = match string_table {
      Some(value) => value
      None => raise MissingC13StringTable
    }
    parse_file_checksums(subsections, table, limits)
  } else {
    []
  }
  let line_fragments = if has_c13_subsection(subsections, C13_KIND_LINES) {
    parse_line_fragments(subsections, checksums, limits)
  } else {
    []
  }
  C13DebugInfo::{ subsections, string_table, checksums, line_fragments, }
}

///|
fn parse_c13_subsections(
  data : Bytes,
  limits : C13Limits,
) -> Array[C13Subsection] raise SymbolError {
  let subsections = []
  let mut position = 0
  while position < data.length() {
    if subsections.length() >= limits.max_subsections {
      raise C13LimitExceeded("C13 subsection count limit exceeded")
    }
    let start = position
    let header_end = checked_symbol_add(
      start,
      C13_SUBSECTION_HEADER_SIZE,
      "C13 subsection header",
    )
    if header_end > data.length() {
      raise TruncatedC13(header_end)
    }
    let (kind_raw, cursor) = read_symbol_u32(data, start, header_end)
    let (length_raw, cursor) = read_symbol_u32(data, cursor, header_end)
    let length = symbol_uint_to_int(length_raw, "C13 subsection length")
    let payload_end = checked_symbol_add(
      cursor, length, "C13 subsection payload",
    )
    if payload_end > data.length() {
      raise TruncatedC13(payload_end)
    }
    let aligned_end = align_symbol4(payload_end)
    if aligned_end > data.length() {
      raise TruncatedC13(aligned_end)
    }
    subsections.push(C13Subsection::{
      kind: kind_raw & C13_SUBSECTION_MASK,
      payload: data.exact_view(start=cursor, end=payload_end).to_owned(),
    })
    position = aligned_end
  }
  subsections
}

///|
fn has_c13_subsection(
  subsections : Array[C13Subsection],
  kind : UInt32,
) -> Bool {
  for subsection in subsections {
    if subsection.kind == kind {
      return true
    }
  }
  false
}

///|
fn parse_file_checksums(
  subsections : Array[C13Subsection],
  strings : DebugStringTable,
  limits : C13Limits,
) -> Array[FileChecksum] raise SymbolError {
  let checksums = []
  for subsection in subsections {
    if subsection.kind != C13_KIND_FILE_CHECKSUMS {
      continue
    }
    let payload = subsection.payload
    let mut position = 0
    while position < payload.length() {
      if checksums.length() >= limits.max_file_checksums {
        raise C13LimitExceeded("file checksum count limit exceeded")
      }
      let entry_offset = position
      let header_end = checked_symbol_add(
        position,
        C13_CHECKSUM_HEADER_SIZE,
        "file checksum header",
      )
      if header_end > payload.length() {
        raise TruncatedC13(header_end)
      }
      let (file_name_offset, cursor) = read_symbol_u32(
        payload, position, header_end,
      )
      let (checksum_size, cursor) = read_symbol_u8(payload, cursor, header_end)
      let (checksum_kind, cursor) = read_symbol_u8(payload, cursor, header_end)
      let checksum_end = checked_symbol_add(
        cursor, checksum_size, "file checksum bytes",
      )
      if checksum_end > payload.length() {
        raise TruncatedC13(checksum_end)
      }
      let file_path = match strings.string_at(file_name_offset) {
        Some(value) => value
        None =>
          raise InvalidFileChecksum(
            "file name offset is outside the string table",
          )
      }
      checksums.push(FileChecksum::{
        subsection_offset: entry_offset.reinterpret_as_uint(),
        file_name_offset,
        kind: checksum_kind,
        checksum: payload.exact_view(start=cursor, end=checksum_end).to_owned(),
        file_path,
      })
      position = align_symbol4(checksum_end)
      if position > payload.length() {
        raise TruncatedC13(position)
      }
    }
  }
  checksums
}

///|
fn parse_line_fragments(
  subsections : Array[C13Subsection],
  checksums : Array[FileChecksum],
  limits : C13Limits,
) -> Array[LineFragment] raise SymbolError {
  let fragments = []
  let mut total_lines = 0
  for subsection in subsections {
    if subsection.kind != C13_KIND_LINES {
      continue
    }
    if fragments.length() >= limits.max_line_fragments {
      raise C13LimitExceeded("line fragment count limit exceeded")
    }
    let payload = subsection.payload
    if payload.length() < C13_LINE_FRAGMENT_HEADER_SIZE {
      raise TruncatedC13(payload.length())
    }
    let (relocation_offset, cursor) = read_symbol_u32(
      payload,
      0,
      payload.length(),
    )
    let (relocation_segment, cursor) = read_symbol_u16(
      payload,
      cursor,
      payload.length(),
    )
    let (flags, cursor) = read_symbol_u16(payload, cursor, payload.length())
    let (code_size, cursor) = read_symbol_u32(payload, cursor, payload.length())
    let mut position = cursor
    let has_columns = (flags & C13_LINES_HAVE_COLUMNS) != 0
    let blocks = []
    while position < payload.length() {
      let block_start = position
      let block_header_end = checked_symbol_add(
        position,
        C13_LINE_BLOCK_HEADER_SIZE,
        "line block header",
      )
      if block_header_end > payload.length() {
        raise TruncatedC13(block_header_end)
      }
      let (file_checksum_offset, cursor) = read_symbol_u32(
        payload, position, block_header_end,
      )
      let (line_count_raw, cursor) = read_symbol_u32(
        payload, cursor, block_header_end,
      )
      let (block_size_raw, cursor) = read_symbol_u32(
        payload, cursor, block_header_end,
      )
      let line_count = symbol_uint_to_int(line_count_raw, "line count")
      let block_size = symbol_uint_to_int(block_size_raw, "line block size")
      if line_count < 0 || block_size < C13_LINE_BLOCK_HEADER_SIZE {
        raise InvalidLineInfo("invalid line block header")
      }
      total_lines = checked_symbol_add(total_lines, line_count, "line count")
      if total_lines > limits.max_line_entries {
        raise C13LimitExceeded("line entry count limit exceeded")
      }
      let block_end = checked_symbol_add(block_start, block_size, "line block")
      if block_end > payload.length() {
        raise TruncatedC13(block_end)
      }
      let line_bytes = checked_symbol_mul(
        line_count,
        C13_LINE_ENTRY_SIZE,
        "line entries",
      )
      let column_bytes = if has_columns {
        checked_symbol_mul(line_count, C13_COLUMN_ENTRY_SIZE, "column entries")
      } else {
        0
      }
      let records_end = checked_symbol_add(
        checked_symbol_add(cursor, line_bytes, "line entries"),
        column_bytes,
        "line columns",
      )
      if records_end > block_end {
        raise InvalidLineInfo("line block content exceeds its declared size")
      }
      let file_path = file_path_for_checksum(checksums, file_checksum_offset)
      let lines = []
      let line_cursor_start = cursor
      for index in 0..<line_count {
        let entry_offset = checked_symbol_add(
          line_cursor_start,
          checked_symbol_mul(index, C13_LINE_ENTRY_SIZE, "line entry"),
          "line entry",
        )
        let (offset, cursor) = read_symbol_u32(
          payload, entry_offset, records_end,
        )
        let (line_flags, _) = read_symbol_u32(payload, cursor, records_end)
        let columns = if has_columns {
          let column_offset = checked_symbol_add(
            line_cursor_start + line_bytes,
            checked_symbol_mul(index, C13_COLUMN_ENTRY_SIZE, "column entry"),
            "column entry",
          )
          let (start, cursor) = read_symbol_u16(
            payload, column_offset, records_end,
          )
          let (end, _) = read_symbol_u16(payload, cursor, records_end)
          Some(LineColumnRange::{ start, end, })
        } else {
          None
        }
        lines.push(LineNumber::{
          offset,
          line_start: line_flags & 0x00FFFFFFU,
          line_end: (line_flags >> 24) & 0x0000007FU,
          is_statement: (line_flags & 0x80000000U) != 0U,
          columns,
        })
      }
      blocks.push(LineBlock::{
        file_checksum_offset,
        file_path,
        record_size: block_size_raw,
        lines,
      })
      position = block_end
    }
    fragments.push(LineFragment::{
      relocation_offset,
      relocation_segment,
      flags,
      code_size,
      blocks,
    })
  }
  fragments
}

///|
fn file_path_for_checksum(
  checksums : Array[FileChecksum],
  offset : UInt32,
) -> String raise SymbolError {
  for checksum in checksums {
    if checksum.subsection_offset == offset {
      return checksum.file_path
    }
  }
  raise InvalidLineInfo("line block references a missing file checksum")
}

///|
fn align_symbol4(value : Int32) -> Int32 raise SymbolError {
  if value < 0 || value > 0x7FFFFFFD {
    raise InvalidC13Subsection("C13 alignment overflows Int range")
  }
  (value + 3) / 4 * 4
}
