///|
fn read_u8(
  data : Bytes,
  pos : Int32,
  end : Int32,
) -> (Byte, Int32) raise MsfError {
  if pos < 0 || pos >= end || pos >= data.length() {
    raise Truncated(pos)
  }
  (data.at(pos), pos + 1)
}

///|
fn read_u32_le(
  data : Bytes,
  pos : Int32,
  end : Int32,
) -> (UInt32, Int32) raise MsfError {
  let (b0, pos) = read_u8(data, pos, end)
  let (b1, pos) = read_u8(data, pos, end)
  let (b2, pos) = read_u8(data, pos, end)
  let (b3, pos) = read_u8(data, pos, end)
  (
    ((b3.to_int() << 24) |
    (b2.to_int() << 16) |
    (b1.to_int() << 8) |
    b0.to_int()).reinterpret_as_uint(),
    pos,
  )
}

///|
fn read_u32_le_at(data : Bytes, offset : Int32) -> UInt32 raise MsfError {
  let (value, _) = read_u32_le(data, offset, data.length())
  value
}

///|
fn uint_to_int(value : UInt32, field : String) -> Int32 raise MsfError {
  let wide = value.to_int64()
  if wide > 0x7FFFFFFFL {
    raise InvalidValue("\{field} exceeds Int range")
  }
  wide.to_int()
}

///|
fn be_div_ceil(value : Int32, divisor : Int32) -> Int32 {
  if value == 0 {
    0
  } else {
    (value + divisor - 1) / divisor
  }
}

///|
fn checked_mul(
  left : Int32,
  right : Int32,
  field : String,
) -> Int32 raise MsfError {
  if left < 0 || right < 0 || (left != 0 && right > 0x7FFFFFFF / left) {
    raise InvalidValue("\{field} overflows Int range")
  }
  left * right
}

///|
fn checked_add(
  left : Int32,
  right : Int32,
  field : String,
) -> Int32 raise MsfError {
  if left < 0 || right < 0 || left > 0x7FFFFFFF - right {
    raise InvalidValue("\{field} overflows Int range")
  }
  left + right
}
