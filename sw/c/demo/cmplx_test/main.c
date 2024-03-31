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
  //int failures = 0;

  for (uint32_t i = 500; i <10000; i++)
  { 
    //500 = 0x1f4 
    puts("using number (encoded as vector): ");
    puthex(i);
    puts("\n");
    run_vdot_test(i,0); //0xf4*5 - 1 = 0x4c3 -> 255
    puts("\n");
  }
  return 0;
  
  
  for (int i = 0;i < NUM_TESTS; i++) {
    uint32_t a = 1;
    uint32_t b = 0; //dummy val [5,-1,-1,-1,-1]
    run_vdot_test(a,b); //1*5 = 5
    //returns 0x5

    a = 10; //0xA
    //b =0;
    run_vdot_test(a,b); //10*5 = 50 = 0x32
    //returns 0x32

    a = 100; //0x64
    //b =0;
    run_vdot_test(a,b); //100*5 = 500 -> 255 = 0xff
    //returns 0xff

     a = 1000; //0x3 e8
     //b =0; // -1  5   = 0x485 = 1157
    run_vdot_test(a,b); 
    //returns 0x0


     a = 10000; //0x27 10
     //b =0;   // -1  5   =0x29
    run_vdot_test(a,b);//10,000*5 = 0xc350
    //returns 0x29

     a = 100000; //0x1 86 a0
     //b =0;    // -1 -1 5
    run_vdot_test(a,b); //0x299 = 665 -> 255
    //returns 0xff
    
     a = 1000000; //0xf 42 40
     //b =0;     // -1 -1 5
    run_vdot_test(a,b);//0xef = 239
    //returns 0xef

     a = 10000000; //0x98 96 80
     //b =0;      //  -1 -1 5
    run_vdot_test(a,b); //0x152 = 338 -> 255
    //returns 0xff

     a = 100000000; //0x5 F5 E1 00
     //b =0;      //  -1 -1 -1 5
    run_vdot_test(a,b); //-1*0x1db = 0xfe25
    //returns 0x25

     a = 1000000000; //0x3B 9A CA 00
     //b = 0;        //  -1 -1 -1 5
    run_vdot_test(a,b);//-1*0x19f = 0xfe61
    //returns 0x61
  }

  return 0;
}
