volatile int moonpdb_counter = 7;
volatile int moonpdb_sink = 0;

__declspec(noinline) int moonpdb_add(int left, int right) {
  int result = left + right + moonpdb_counter;
  return result;
}

__declspec(noinline) int moonpdb_mul(int left, int right) {
  int result = left * right;
  return result;
}

void moonpdb_entry(void) {
  moonpdb_sink = moonpdb_add(5, 6) + moonpdb_mul(7, 8);
}
