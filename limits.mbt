///|
/// Resource limits for parsing untrusted MSF files.
pub struct MsfLimits {
  max_file_bytes : Int
  max_directory_bytes : Int
  max_streams : Int
  max_stream_bytes : Int
}

///|
pub fn MsfLimits::default() -> MsfLimits {
  MsfLimits::{
    max_file_bytes: 512 * 1024 * 1024,
    max_directory_bytes: 16 * 1024 * 1024,
    max_streams: 65_536,
    max_stream_bytes: 256 * 1024 * 1024,
  }
}
