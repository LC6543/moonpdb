///|
suberror CliError {
  CliError(String)
}

///|
fn main {
  let args = @env.args()
  run(args) catch {
    CliError(message) => println("error: \{message}")
  }
}

///|
fn usage() -> Unit {
  println("MoonPDB 0.3.1")
  println("Usage:")
  println("  moonpdb summary <pdb>")
  println("  moonpdb modules <pdb>")
  println("  moonpdb types <pdb> [limit]")
  println("  moonpdb symbols <pdb> [limit]")
  println("  moonpdb publics <pdb> [limit]")
  println("  moonpdb find <pdb> <name>")
  println("  moonpdb address <pe> <pdb> <segment> <offset>")
}

///|
fn run(args : Array[String]) -> Unit raise CliError {
  let command = match argument(args, 1) {
    Some(value) => value
    None => {
      usage()
      return
    }
  }
  match command {
    "help" | "--help" | "-h" => usage()
    "summary" => command_summary(required_argument(args, 2, "PDB path"))
    "modules" => command_modules(required_argument(args, 2, "PDB path"))
    "types" =>
      command_types(
        required_argument(args, 2, "PDB path"),
        optional_limit(args, 3),
      )
    "symbols" =>
      command_symbols(
        required_argument(args, 2, "PDB path"),
        optional_limit(args, 3),
      )
    "publics" =>
      command_publics(
        required_argument(args, 2, "PDB path"),
        optional_limit(args, 3),
      )
    "find" =>
      command_find(
        required_argument(args, 2, "PDB path"),
        required_argument(args, 3, "symbol name"),
      )
    "address" =>
      command_address(
        required_argument(args, 2, "PE path"),
        required_argument(args, 3, "PDB path"),
        required_argument(args, 4, "segment"),
        required_argument(args, 5, "section offset"),
      )
    _ => raise CliError("unknown command: \{command}")
  }
}

///|
fn argument(args : Array[String], index : Int32) -> String? {
  if index < 0 || index >= args.length() {
    None
  } else {
    Some(args[index])
  }
}

///|
fn required_argument(
  args : Array[String],
  index : Int32,
  field : String,
) -> String raise CliError {
  match argument(args, index) {
    Some(value) => value
    None => raise CliError("missing \{field}")
  }
}

///|
fn optional_limit(args : Array[String], index : Int32) -> Int32 raise CliError {
  match argument(args, index) {
    None => 100
    Some(value) =>
      match parse_uint64(value) {
        Some(number) => {
          if number == 0UL || number > 10_000UL {
            raise CliError("limit must be between 1 and 10000")
          }
          number.to_uint().reinterpret_as_int()
        }
        None => raise CliError("invalid limit: \{value}")
      }
  }
}

///|
fn load_pdb(path : String) -> @lib.MsfFile raise CliError {
  let bytes = @fs.read_file_to_bytes(path) catch {
    _ => raise CliError("cannot read PDB: \{path}")
  }
  @lib.parse_msf(bytes, @lib.MsfLimits::default()) catch {
    _ => raise CliError("cannot parse PDB: \{path}")
  }
}

///|
fn load_pe(path : String) -> @lib.PeImage raise CliError {
  let bytes = @fs.read_file_to_bytes(path) catch {
    _ => raise CliError("cannot read PE: \{path}")
  }
  @lib.parse_pe_image(bytes, @lib.PeLimits::default()) catch {
    _ => raise CliError("cannot parse PE: \{path}")
  }
}

///|
fn command_summary(path : String) -> Unit raise CliError {
  let msf = load_pdb(path)
  println("file: \{path}")
  println("streams: \{msf.stream_count()}")
  let info = Some(msf.pdb_info(@lib.PdbInfoLimits::default())) catch {
    _ => None
  }
  match info {
    Some(value) => {
      println("guid: \{value.guid_string()}")
      println("age: \{value.age()}")
      println("named streams: \{value.named_stream_count()}")
    }
    None => println("guid: unavailable")
  }
  let tpi = Some(msf.tpi(@lib.TpiLimits::default())) catch { _ => None }
  match tpi {
    Some(value) => println("tpi types: \{value.record_count()}")
    None => println("tpi types: unavailable")
  }
  let dbi = Some(msf.dbi(@lib.DbiLimits::default())) catch { _ => None }
  match dbi {
    Some(value) => println("modules: \{value.module_count()}")
    None => println("modules: unavailable")
  }
  match dbi {
    Some(value) => {
      let publics = Some(
        msf.publics_stream(value, @lib.SymbolLimits::default()),
      ) catch {
        _ => None
      }
      match publics {
        Some(table) => println("public symbols: \{table.public_symbol_count()}")
        None => println("public symbols: unavailable")
      }
    }
    None => println("public symbols: unavailable")
  }
}

///|
fn command_modules(path : String) -> Unit raise CliError {
  let msf = load_pdb(path)
  let dbi = msf.dbi(@lib.DbiLimits::default()) catch {
    _ => raise CliError("DBI stream is unavailable")
  }
  println("modules: \{dbi.module_count()}")
  for index in 0..<dbi.module_count() {
    let item = dbi.module_at(index).unwrap()
    println(
      "\{index}: \{item.module_name()} | obj=\{item.object_name()} | stream=\{item.module_stream_index()} | files=\{item.source_files().length()}",
    )
  }
}

///|
fn command_types(path : String, limit : Int32) -> Unit raise CliError {
  let msf = load_pdb(path)
  let tpi = msf.tpi(@lib.TpiLimits::default()) catch {
    _ => raise CliError("TPI stream is unavailable")
  }
  let count = if limit < tpi.record_count() {
    limit
  } else {
    tpi.record_count()
  }
  println("types: \{tpi.record_count()} shown: \{count}")
  for index in 0..<count {
    let record = tpi.record_at(index).unwrap()
    println(
      "\{record.type_index()}: kind=\{record.kind()} bytes=\{record.payload().length()}",
    )
  }
}

///|
fn command_symbols(path : String, limit : Int32) -> Unit raise CliError {
  let msf = load_pdb(path)
  let dbi = msf.dbi(@lib.DbiLimits::default()) catch {
    _ => raise CliError("DBI stream is unavailable")
  }
  let symbols = msf.symbol_record_stream(dbi, @lib.SymbolLimits::default()) catch {
    _ => raise CliError("global symbol stream is unavailable")
  }
  let count = if limit < symbols.record_count() {
    limit
  } else {
    symbols.record_count()
  }
  println("symbols: \{symbols.record_count()} shown: \{count}")
  for index in 0..<count {
    let record = symbols.record_at(index).unwrap()
    let name = match record.name() {
      Some(value) => value
      None => "-"
    }
    println("\{record.offset()}: kind=\{record.kind()} name=\{name}")
  }
}

///|
fn command_publics(path : String, limit : Int32) -> Unit raise CliError {
  let msf = load_pdb(path)
  let dbi = msf.dbi(@lib.DbiLimits::default()) catch {
    _ => raise CliError("DBI stream is unavailable")
  }
  let publics = msf.publics_stream(dbi, @lib.SymbolLimits::default()) catch {
    _ => raise CliError("Publics stream is unavailable")
  }
  let count = if limit < publics.public_symbol_count() {
    limit
  } else {
    publics.public_symbol_count()
  }
  println("public symbols: \{publics.public_symbol_count()} shown: \{count}")
  for index in 0..<count {
    let symbol = publics.public_symbol_at(index).unwrap()
    println(
      "\{symbol.segment()}:\{symbol.offset()} \{symbol.name()} offset=\{symbol.symbol_offset()}",
    )
  }
}

///|
fn command_find(path : String, name : String) -> Unit raise CliError {
  let msf = load_pdb(path)
  let dbi = msf.dbi(@lib.DbiLimits::default()) catch {
    _ => raise CliError("DBI stream is unavailable")
  }
  let globals = msf.globals_stream(dbi, @lib.SymbolLimits::default()) catch {
    _ => raise CliError("Globals stream is unavailable")
  }
  let matches = globals.find_records_by_name(name) catch {
    _ => raise CliError("Globals index is invalid")
  }
  println("matches: \{matches.length()}")
  for record in matches {
    let symbol_name = match record.name() {
      Some(value) => value
      None => "-"
    }
    println("\{record.offset()}: kind=\{record.kind()} name=\{symbol_name}")
  }
}

///|
fn command_address(
  pe_path : String,
  pdb_path : String,
  segment_text : String,
  offset_text : String,
) -> Unit raise CliError {
  let pdb = load_pdb(pdb_path)
  let pe = load_pe(pe_path)
  let dbi = pdb.dbi(@lib.DbiLimits::default()) catch {
    _ => raise CliError("DBI stream is unavailable")
  }
  let publics = pdb.publics_stream(dbi, @lib.SymbolLimits::default()) catch {
    _ => raise CliError("Publics stream is unavailable")
  }
  let segment = match parse_uint64(segment_text) {
    Some(value) => {
      if value > 65_535UL {
        raise CliError("segment is outside UInt16 range")
      }
      value.to_uint16()
    }
    None => raise CliError("invalid segment: \{segment_text}")
  }
  let offset = match parse_uint64(offset_text) {
    Some(value) => {
      if value > 0xFFFFFFFFUL {
        raise CliError("offset is outside UInt32 range")
      }
      UInt32(value.to_uint())
    }
    None => raise CliError("invalid offset: \{offset_text}")
  }
  let modules = collect_c13(pdb, dbi)
  let result = match
    @lib.symbolicate_address(pe, publics, modules, segment, offset) {
    Some(value) => value
    None => raise CliError("address is outside the PE section table")
  }
  println("segment: \{result.segment()}")
  println("section offset: \{result.section_offset()}")
  println("section: \{result.section_name()}")
  println("rva: \{result.rva()}")
  println("image address: \{result.image_address()}")
  match result.public_symbol() {
    Some(value) =>
      println(
        "public: \{value.name()} +\{result.section_offset() - value.offset()}",
      )
    None => println("public: unavailable")
  }
  match result.source() {
    Some(value) => {
      println("source: \{value.file_path()}:\{value.line_start()}")
      match value.columns() {
        Some(columns) => println("columns: \{columns.start()}-\{columns.end()}")
        None => println("columns: unavailable")
      }
    }
    None => println("source: unavailable")
  }
}

///|
fn collect_c13(
  msf : @lib.MsfFile,
  dbi : @lib.DbiFile,
) -> Array[@lib.C13DebugInfo] {
  let modules = []
  for index in 0..<dbi.module_count() {
    let info = Some(
      msf.module_c13_info(
        dbi,
        index,
        @lib.SymbolLimits::default(),
        @lib.C13Limits::default(),
      ),
    ) catch {
      _ => None
    }
    match info {
      Some(value) => modules.push(value)
      None => ()
    }
  }
  modules
}

///|
fn parse_uint64(value : String) -> UInt64? {
  let bytes = @utf8.encode(value)
  let length = bytes.length()
  if length == 0 {
    return None
  }
  let mut cursor = 0
  let mut base = 10
  if length >= 2 &&
    bytes.at(0) == 0x30 &&
    (bytes.at(1) == 0x78 || bytes.at(1) == 0x58) {
    base = 16
    cursor = 2
  }
  if cursor == length {
    return None
  }
  let mut result = 0UL
  let base_u = base.reinterpret_as_uint().to_uint64()
  while cursor < length {
    let code = bytes.at(cursor).to_int()
    let digit = if code >= 0x30 && code <= 0x39 {
      code - 0x30
    } else if code >= 0x41 && code <= 0x46 {
      code - 0x41 + 10
    } else if code >= 0x61 && code <= 0x66 {
      code - 0x61 + 10
    } else {
      return None
    }
    if digit < 0 || digit >= base {
      return None
    }
    let digit_u = digit.to_int64().reinterpret_as_uint64()
    if result > (0xFFFFFFFFFFFFFFFFUL - digit_u) / base_u {
      return None
    }
    result = result * base_u + digit_u
    cursor = cursor + 1
  }
  Some(result)
}
