// Author : Vinay Gajjar
// Draft 0.0
// RISC_V Vector ADD, SUBTRACT Unit

// Summary of implementation steps:
// Input/Output operands and Instruction needed
// Select Element Width (SEW) required
// Output Controlled by some kind of result mux.

// Vector Addition 5 - 8/10 bit summations. Based on input 3x3 being multiplied by 3x3 Filtering matrix

// This will be used for the vector operations - 8 bits * 5 = ~ 40 bits.
// input is packed and output is also packed?

//// NOTES //////
////VLEN: The Vector Register Width
//VLEN signifies the number of bits in a vector register. 
//VLEN must be greater than or equal to ELEN and must also be a power of 2. The width of the vector register is determined by VLEN, and it’s a key factor in RVV operations.

//VL: Vector Length
//VL, or Vector Length, denotes the number of elements that a specific instruction will operate on. VL must be less than or equal to VLMAX to ensure valid vector operations.

module ibex_vector_logic_unit (
		// Input Operands on 128 bits, ele size controlled by VSEW.
		input logic [127:0] vector_reg_1,               
		input logic [127:0] vector_reg_2,
		// can be used for carry in MAC block
		input logic [127:0] vector_reg_3,
		// WHY DOES AVA CORE HAVE 3 INPUT REG's?
		// VSEW
		input       [1:0]   vsew_top,
		// vector length of operations , 4 - 32 Bit buses in parallel with this architecture.
		input       [4:0]   vl_top,
		//opcode from ibex
 		input       [3:0]   operator_i_top,
		// EN signals for ADD/MULT
		input logic         ADD_en_top,
		input logic         SUB_en_top,
		input logic         MULT_en_top,
		// could come from controller
		input logic         custom_filt,
		// Output Results on 8 bits.
		output logic [7:0]  result_o_RGB, 
		output logic [7:0]  carry_out
);

// 32 BIT VECTOR INTERMEDIATE OUTPUTS FROM MAC
logic signed [15:0] MAC_output_9,MAC_output_8,MAC_output_7,MAC_output_6,MAC_output_5,MAC_output_4, MAC_output_3, MAC_output_2, MAC_output_1;
logic signed [7:0] mac_1_filter, mac_2_filter, mac_3_filter, mac_4_filter, mac_5_filter, mac_6_filter, mac_7_filter, mac_8_filter,mac_9_filter;
logic signed [15:0] result_o_RGB_imd;

always_comb
begin
	// result_o_RGB is unsigned
	result_o_RGB = result_o_RGB_imd [7:0];
	// checks for >255 of <0
	if (|result_o_RGB_imd[15:8]) result_o_RGB = 8'd255;
	if (&result_o_RGB_imd[15:8]) result_o_RGB = 8'd0;
	
end

always_comb
begin
	if (1'b1)
	case (vl_top[1:0])
		3'd0:
			result_o_RGB_imd = MAC_output_9 + MAC_output_8 + MAC_output_7 + MAC_output_6 + MAC_output_5+ MAC_output_4 + MAC_output_3 + MAC_output_2 +MAC_output_1;
		3'd1:
			result_o_RGB_imd = MAC_output_2;
		3'd2:
			result_o_RGB_imd = MAC_output_3;
		3'd3:
			result_o_RGB_imd = MAC_output_4;
		3'd4:
			result_o_RGB_imd = MAC_output_5;
		3'd5:
			result_o_RGB_imd = MAC_output_6;
		3'd6:
			result_o_RGB_imd = MAC_output_7;
		3'd7:
			result_o_RGB_imd = MAC_output_8;
		default:
			result_o_RGB_imd = MAC_output_9;
	endcase
   else result_o_RGB_imd = MAC_output_9 + MAC_output_8 + MAC_output_7 + MAC_output_6 + MAC_output_5+ MAC_output_4 + MAC_output_3 + MAC_output_2 +MAC_output_1;
	 //else result_o = {MAC_output_2, MAC_output_1};
end

// 4 - 31 Bit MAC units in parallel - Does this introduce some kind of inherent parallelism?
ibex_mac mac_1 (
		// Input Operands on X bits
		.operand_a(vector_reg_1[7:0]),               
		.operand_b(mac_1_filter),
		.carry_in(vector_reg_3[7:0]),

		.operator_i(operator_i_top),

		.result_o(MAC_output_1), 
		//.carry_out();

		.ADD_en(ADD_en_top),
		.SUB_en(SUB_en_top),
		.MULT_en(MULT_en_top),

		.vsew(vsew_top)
);
ibex_mac mac_2 (
		// Input Operands on X bits
		.operand_a(vector_reg_1[15:8]),               
		.operand_b(mac_2_filter),
		.carry_in(vector_reg_3[15:8]),

		.operator_i(operator_i_top),

		.result_o(MAC_output_2), 
		//.carry_out();

		.ADD_en(ADD_en_top),
		.SUB_en(SUB_en_top),
		.MULT_en(MULT_en_top),

		.vsew(vsew_top)
		
);
ibex_mac mac_3 (
		// Input Operands on X bits
		.operand_a(vector_reg_1[23:16]),               
		.operand_b(mac_3_filter),
		.carry_in(vector_reg_3[23:16]),

		.operator_i(operator_i_top),

		.result_o(MAC_output_3), 
		//.carry_out();

		.ADD_en(ADD_en_top),
		.SUB_en(SUB_en_top),
		.MULT_en(MULT_en_top),

		.vsew(vsew_top)
		
);
ibex_mac mac_4 (
		// Input Operands on X bits
		.operand_a(vector_reg_1[31:24]),               
		.operand_b(mac_4_filter),
		.carry_in(vector_reg_3[31:24]),

		.operator_i(operator_i_top),

		.result_o(MAC_output_4), 
		//.carry_out();

		.ADD_en(ADD_en_top),
		.SUB_en(SUB_en_top),
		.MULT_en(MULT_en_top),

		.vsew(vsew_top)
		
);
ibex_mac mac_5 (
		// Input Operands on X bits
		.operand_a(vector_reg_2[7:0]),               
		.operand_b(mac_5_filter),
		.carry_in(vector_reg_3[39:32]),

		.operator_i(operator_i_top),

		.result_o(MAC_output_5), 
		//.carry_out();

		.ADD_en(ADD_en_top),
		.SUB_en(SUB_en_top),
		.MULT_en(MULT_en_top),

		.vsew(vsew_top)
		
);
ibex_mac mac_6 (
		// Input Operands on X bits
		.operand_a(vector_reg_1[47:40]),               
		.operand_b(mac_6_filter),
		.carry_in(vector_reg_3[47:40]),

		.operator_i(operator_i_top),

		.result_o(MAC_output_6), 
		//.carry_out();

		.ADD_en(ADD_en_top),
		.SUB_en(SUB_en_top),
		.MULT_en(MULT_en_top),

		.vsew(vsew_top)
);

ibex_mac mac_7 (
		// Input Operands on X bits
		.operand_a(vector_reg_1[55:48]),               
		.operand_b(mac_7_filter),
		.carry_in(vector_reg_3[55:48]),

		.operator_i(operator_i_top),

		.result_o(MAC_output_7), 
		//.carry_out();

		.ADD_en(ADD_en_top),
		.SUB_en(SUB_en_top),
		.MULT_en(MULT_en_top),

		.vsew(vsew_top)
);

ibex_mac mac_8 (
		// Input Operands on X bits
		.operand_a(vector_reg_1[63:56]),               
		.operand_b(mac_8_filter),
		.carry_in(vector_reg_3[63:56]),

		.operator_i(operator_i_top),

		.result_o(MAC_output_8), 
		//.carry_out();

		.ADD_en(ADD_en_top),
		.SUB_en(SUB_en_top),
		.MULT_en(MULT_en_top),

		.vsew(vsew_top)
);

ibex_mac mac_9 (
		// Input Operands on X bits
		.operand_a(vector_reg_1[71:64]),               
		.operand_b(mac_9_filter),
		.carry_in(vector_reg_3[71:64]),

		.operator_i(operator_i_top),

		.result_o(MAC_output_9), 
		//.carry_out();

		.ADD_en(ADD_en_top),
		.SUB_en(SUB_en_top),
		.MULT_en(MULT_en_top),

		.vsew(vsew_top)
);



always_comb begin 
 if (custom_filt == 1'b0) begin
	mac_1_filter= vector_reg_2[7:0]; 
	mac_2_filter= vector_reg_2[15:8];
	mac_3_filter= vector_reg_2[23:16]; 
	mac_4_filter= vector_reg_2[31:24]; 
	mac_5_filter= vector_reg_2[39:32]; 
	mac_6_filter= vector_reg_2[47:40]; 
	mac_7_filter= vector_reg_2[55:48]; 
	mac_8_filter= vector_reg_2[63:56]; 
	mac_9_filter= vector_reg_2[71:64]; 
 end
 
 else begin 
	mac_1_filter= 8'd5; 
	mac_2_filter= -8'd1;
	mac_3_filter= -8'd1; 
	mac_4_filter= -8'd1;
	// updated to account for only 32 bits, top bits were being misset 
	mac_5_filter= -8'd1; 
	mac_6_filter= 8'sd0; 
	mac_7_filter= 8'sd0; 
	mac_8_filter= 8'sd0; 
	mac_9_filter= 8'sd0; 
 end
end
endmodule
