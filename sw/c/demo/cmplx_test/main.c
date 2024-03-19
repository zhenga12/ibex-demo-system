// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "demo_system.h"

#define FP_EXP 12
#define FP_MANT 15
#define MAKE_FP(i, f, f_bits) ((i << FP_EXP) | (f << (FP_EXP - f_bits)))

typedef uint32_t cmplx_packed_t;


static inline cmplx_packed_t cmplx_add_insn(uint32_t a, uint32_t b) {
  uint32_t result;

  asm (".insn r CUSTOM_0, 1, 0, %0, %1, %2" :
       "=r"(result) :
       "r"(a), "r"(b));

  return result;
}


typedef struct {
  int32_t real;
  int32_t imag;
} cmplx_t;

cmplx_t test_nums[] = {
  {MAKE_FP(2, 0, 0)},
  {MAKE_FP(3, 0, 0)}
};

#define NUM_TESTS 1
//#define NUM_TESTS 9

int32_t fp_clamp(int32_t x) {
  if ((x < 0) && (x < -(1 << FP_MANT))) {
      return -(1 << FP_MANT);
  }

  if ((x > 0) && (x >= (1 << FP_MANT))) {
    return (1 << FP_MANT) - 1;
  }

  return x;
}

int32_t fp_trunc(int32_t x) {
  uint32_t res = x & 0xffff;

  if (res & 0x8000) {
    return 0xffff0000 | res;
  }

  return res;
}

int32_t to_fp(int32_t x) {
  int32_t res;
  res = fp_trunc(x << FP_EXP);

  return res;
}

int32_t fp_add(int32_t a, int32_t b) {
  return fp_trunc(a + b);
}




cmplx_t cmplx_add_test(cmplx_t c1, cmplx_t c2) {
  cmplx_t res;

  res.real = fp_add(c1.real, c2.real);
  res.imag = fp_add(c1.imag, c2.imag);

  return res;
}

cmplx_packed_t pack_cmplx(cmplx_t c) {
  return ((c.real & 0xffff) << 16) | (c.imag & 0xffff);
}

cmplx_t unpack_cmplx(cmplx_packed_t c) {
  cmplx_t result;

  result.real = ((int32_t)c) >> 16;
  result.imag = c & 0xffff;
  if (result.imag & 0x8000) {
    result.imag |= 0xffff0000;
  }

  return result;
}

void dump_binop_result(cmplx_t c1, cmplx_t c2, cmplx_packed_t c1_packed,
    cmplx_packed_t c2_packed, cmplx_t result, cmplx_packed_t result_packed) {
  puts("C1\n");
  puthex(c1.real);
  puts("\n");
  puthex(c1.imag);
  puts("\n");
  puts("\n");

  puts("C2\n");
  puthex(c2.real);
  puts("\n");
  puthex(c2.imag);
  puts("\n");
  puts("\n");

  puts("C1 Packed\n");
  puthex(c1_packed);
  puts("\n");
  puts("\n");

  puts("C2 Packed\n");
  puthex(c2_packed);
  puts("\n");
  puts("\n");

  puts("Result (from soft cmplx)\n");
  puthex(result.real);
  puts("\n");
  puthex(result.imag);
  puts("\n");
  puts("\n");

  puts("Result Packed (from hard cmplx insn)\n");
  puthex(result_packed);
  puts("\n");
  puts("\n");
}



int run_add_test(cmplx_t c1, cmplx_t c2, int dump_result) {
  cmplx_packed_t c1_packed, c2_packed, result_packed;

  c1_packed = pack_cmplx(c1);
  c2_packed = pack_cmplx(c2);

  result_packed = cmplx_add_insn(c1_packed, c2_packed);

  cmplx_t result;
  result = cmplx_add_test(c1, c2);

  cmplx_t result_unpacked;
  result_unpacked = unpack_cmplx(result_packed);

  if (dump_result) {
    dump_binop_result(c1, c2, c1_packed, c2_packed, result, result_packed);
  }

  if (result_unpacked.real != result.real) {
    return 0;
  }

  if (result_unpacked.imag != result.imag) {
    return 0;
  }

  return 1;
}



int main(void) {
  int failures = 0;

  for (int i = 0;i < NUM_TESTS; ++i) {

    if (!run_add_test(test_nums[i * 2], test_nums[i * 2 + 1], 0)) {
      puts("Add test failed: ");
      puthex(i);
      puts("\n");
      run_add_test(test_nums[i * 2], test_nums[i * 2 + 1], 1);
      puts("\n\n");
      ++failures;
    }
    else {
      puts("Add test passed: ");
      puthex(i);
      puts("\n");
      run_add_test(test_nums[i * 2], test_nums[i * 2 + 1], 1);
      puts("\n\n");
    }
  }

  if (failures) {
    puthex(failures);
    puts(" failures seen\n");
  } else {
    puts("All tests passed maybe!\n");
  }

  return 0;
}
