// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

/* #include <stdio.h>
#include <stdint.h>

static inline uint8_t vmul(uint32_t a, uint32_t b) {
  uint8_t result;

  asm (".insn r CUSTOM_0, 3, 0, %0, %1, %2" :
       "=r"(result) :
       "r"(a), "r"(b));

  return result;
}

void dump_binop_result(uint8_t result) {
  printf("Result (from VMUL cmplx): 0x%f\n", result);
}

int run_mul_test() {
  // Assuming you meant to pass the values 100 and 100 to cmplx_add_insn
  uint32_t a = 100;
  uint32_t b = 100;

  uint8_t result_packed = vmul(a, b);

  dump_binop_result(result_packed);

  return 0;
}

int main(void) {
  for (int i=0;i<2;++i){
    run_mul_test();
  }
 

  return 0;
} */

// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "demo_system.h"






uint32_t vdot(uint32_t a, uint32_t b) {
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



#define NUM_TESTS 1
//#define NUM_TESTS 9



void dump_binop_result(uint8_t result) {
  puts("Pixel\n");
  puthex(result);
  puts("\n");
}


uint8_t result_asm;
int run_vdot_test(uint32_t a, uint32_t b) {
  
  result_asm = vdot(a, b);
  dump_binop_result(result_asm);
  return 0;
}



int main(void) {
  int failures = 0;

  for (int i = 0;i < NUM_TESTS; i++) {
    uint32_t a = 7379; // 0x1CD3
    uint32_t b = 100;
    run_vdot_test(a,b);

    a = 6149; // 0x1D05
    b = 100;
    run_vdot_test(a,b);
  /*
    a = 10;
    b = 100;
    run_vdot_test(a,b);


    a = 100;
    b = 100;
    run_vdot_test(a,b);

     a = 1000;
     b = 100;
    run_vdot_test(a,b);

     a = 10000;
     b = 100;
    run_vdot_test(a,b);

     a = 100000;
     b = 100;
    run_vdot_test(a,b);
     a = 1000000;
     b = 100;
    run_vdot_test(a,b);

     a = 10000000;
     b = 100;
    run_vdot_test(a,b);

     a = 100000000;
     b = 100;
    run_vdot_test(a,b);

     a = 1000000000;
     b = 100;
    run_vdot_test(a,b);
    */
  }

  return 0;
}
