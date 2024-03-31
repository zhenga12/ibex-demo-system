// Author : Vinay Gajjar
// Draft 0.0
// RISC_V Vector ADD, SUBTRACT Unit

// Summary of implementation steps:
// Input/Output operands and Instruction needed
// Select Element Width (SEW) required
// Output Controlled by some kind of result mux.

// Vector Addition 5 - 8/10 bit summations. Based on input 3x3 being multiplied by 3x3 Filtering matrix

module ibex_mac (
		// Input Operands on X bits
		// Do these need to be signed logic?
		
		input logic[7:0] operand_a,               
		input logic[7:0] operand_b,
		input logic[7:0] carry_in,

		//opcode from ibex
 		input logic [3:0] operator_i,

		// Output Results on 8 bits.
		output logic[15:0] result_o, 
		//output logic [31:0] carry_out;

		// EN signals for ADD/MULT
		input logic ADD_en,
		input logic SUB_en,
		input logic MULT_en,

		// VSEW
		input [1:0] vsew
		
);

logic signed [3:0]operator_i_decoded;

assign operator_i_decoded = operator_i;
/// replacement for vector_decoder for instruction opcode.
//always_comb begin
//	operator_i_decoded = 0; 
//	case(operator_i)
//	3'b000: 	operator_i_decoded = ALU_VEC_ADD;
//	3'b001:	operator_i_decoded = ALU_VEC_SUB;
//	3'b010:	operator_i_decoded = ALU_VEC_MULT;
//	3'b011:	operator_i_decoded = ALU_VEC_MULT_ACCUM;
//	default:	operator_i_decoded = ALU_VEC_ADD;
//	endcase
//
//end


////

logic signed [7:0]  multiplier_operand_b, adder_operand_a, adder_operand_b;
logic signed [8:0] multiplier_operand_a;
logic signed [15:0] multiplier_output, adder_output, MAC_output;

// simple arithmetic stage - Doesn't consider Vector and Custom Filter setup.

  always_comb begin
		adder_operand_a = operand_a;
		adder_operand_b = operand_b;
		adder_output = adder_operand_a + adder_operand_b;
	end

    // Multiplier
   always_comb begin
		multiplier_operand_a = {1'b0,operand_a};
		multiplier_operand_b = operand_b;
		multiplier_output = multiplier_operand_a * multiplier_operand_b;
	end

    // Multiply and Accumulate (MAC)
    always_comb begin
        MAC_output = (adder_operand_a * adder_operand_b) + carry_in;
    end
 

// Maybe sign extend?

/// Results Mux /// Similar to Ibex core where we can pick the values based of custom instructions.
// Can Multiply also be included within this same block??? and then we can have the mux give the outputs.. this is possible // won't work for MAC unit since you need register so always FF
// to add when required, like state machine.

always_comb begin
    result_o   = 32'b0;
    case (operator_i_decoded)
      // Adder Operations
		3'b000: result_o = adder_output[15:0];
		3'b001: result_o = adder_output[15:0];
	  // take lower half of the bits
		3'b010: result_o = multiplier_output[15:0];
		3'b011: result_o = MAC_output[15:0];
     default:result_o = adder_output;
    endcase
  end

endmodule
