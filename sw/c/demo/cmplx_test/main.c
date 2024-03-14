// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include <stdio.h>
#include <stdint.h>

static inline uint8_t cmplx_add_insn(uint32_t a, uint32_t b) {
  uint8_t result;

  asm (".insn r CUSTOM_0, 0, 0, %0, %1, %2" :
       "=r"(result) :
       "r"(a), "r"(b));

  return result;
}

void dump_binop_result(uint8_t result) {
  printf("Result (from soft cmplx): 0x%x\n", result);
}

int run_add_test() {
  // Assuming you meant to pass the values 100 and 100 to cmplx_add_insn
  uint32_t a = 100;
  uint32_t b = 100;

  uint8_t result_packed = cmplx_add_insn(a, b);

  dump_binop_result(result_packed);

  return 1;
}

int main(void) {
  run_add_test();

  return 0;
}
