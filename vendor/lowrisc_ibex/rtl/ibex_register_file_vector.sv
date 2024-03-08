/**
 * RISC-V Vector register file
 *
 * Register file with 32, 32 bit wide registers. Register 0 is fixed to 0.
 * This register file is based on flip flops. Use this register file when
 * targeting FPGA synthesis or Verilator simulation.
 */
module ibex_register_file_vector #(
    parameter VLEN = 32,
    parameter VLMUL_MAX  = 4
) (
  // Clock and Reset
  input  logic                               clk_i,
  input  logic                               rst_ni,
  // CSR Settings
  input  logic           [2:0]               vsew,
  input  logic           [2:0]               vlmul,
  // Register Address
  input  logic           [3:0]               v0_addr,
  input  logic           [3:0]               v1_adrr,
  // load enable
  input logic                                load_en,
  // output data
  output logic           [128-1:0]           vreg0_o, 
  output logic           [128-1:0]           vreg1_o,
  output logic           [128-1:0]           vreg2_o
 );
  // VSEW
  // 000: 8
  // 001: 16
  // 010: 32
  // 011: 64
  // 0XX: reserved

  // VLMUL
  // 000: 8
  // 001: 16
  // 010: 32
  // 011: 64
  // 0XX: reserved

    // VLEN - 32b

    reg [VLEN-1:0] vreg [LEN-1:0];

// Register Writes
    always_ff @(posedge clki, rstn_i) begin
        if(!rstn_i) begin
            vreg <= '{VLEN{'0}};
        end else begin
            
        end
    end

// Determine VSEW
    always_comb begin
        case(vsew)
            3'b000: // 8b

            3'b001: // 16b

            3'b010: // 32b
    
            3'bXXX: // throw exception
            
        if (load_en) begin
            case (vlmul)
                3'b000: // 8b
                
                3'b001: // 16b
                
                3'b010: // 32b
            
        end         
    
    end




endmodule
