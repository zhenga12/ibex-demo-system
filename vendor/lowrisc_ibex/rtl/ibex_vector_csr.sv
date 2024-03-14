/* ---------------------------------------------------------------------
 * RISC-V Vector CSR
 * ---------------------------------------------------------------------
 * Supporting:
 * VSEW: 8b, 16b, 32b
 * VLMUL: 1, 2, 4
 * Author: Loana Vo
 * ---------------------------------------------------------------------
 * Vector CSR:
 * 0x009    vxsat   fixed-point saturate flag
 * 0x00A    vxrm    fixed-point rounding mode (fixed to)
 * 0xC20    vl      vector length
 * 0xC21    vtype   vector data type register
 * 0xC22    vlenb   vector register length in bytes
 */

/* VSETVLI: Register Format
{reg: [
  {bits: 7,  name: 0x57, attr: 'vsetvli'},
  {bits: 5,  name: 'rd', type: 4},
  {bits: 3,  name: 7},
  {bits: 5,  name: 'rs1', type: 4},
  {bits: 11, name: 'vtypei[10:0]', type: 5},
  {bits: 1,  name: '0'},
]}
*/
/* VTYPE: Register Format
{reg: [
  {bits: 3, name: 'vlmul[2:0]'},
  {bits: 3, name: 'vsew[2:0]'},
  {bits: 1, name: 'vta'},
  {bits: 1, name: 'vma'},
  {bits: 23, name: 'reserved'},
  {bits: 1, name: 'vill'},
]}
*/
module ibex_vector_csr (
    // clock and resets
    input  logic            clk_i,
    input  logic            rstn_i,

    // vsetvli: TODO: Maybe delete?
    input  logic            vec_operator_i,
    // Register 1 input
    input  logic [31:0]     avl_i,
    // Register 2 input
    input  logic [31:0]     vtype_i,
    // csr write enable
    input  logic            vcsr_w_en_i,
    // VL 
    input  logic            vl_max_i,
    input  logic            vl_w_en_i,
    // output
    output logic [4:0]      vl_o,
    output logic [2:0]      vsew_o,
    output logic [2:0]      vlmul_o,
    output logic [4:0]      vl_next_o
);
    localparam VSAT     = 0;
    localparam VXRM     = 1;
    localparam VL       = 2;
    localparam VTYPE    = 3;
    localparam VLENB    = 4;

    logic [31:0] vcsr_r [4:0];

    logic [4:0] vl_next_int;
    logic [4:0] vl_max_int;
    logic [2:0] vlenb_int;
    
    // populate csr register
    always_ff @(posedge clk_i, negedge rstn_i)
        if (~rstn_i) begin
            vcsr_r[VSAT]  <= '0;    // vsat
            vcsr_r[VXRM]  <= '0;    // vxrm
            vcsr_r[VL]    <= '0;    // vl
            vcsr_r[VTYPE] <= '0;    // vtype
            vcsr_r[VLENB] <= 32'd4; // vlenb is read-only
        end else begin
            if (vcsr_w_en_i) begin
                // write vtype
                vcsr_r[VTYPE] <= vtype_i;
                if (~vl_w_en_i)
                    vcsr_r[VL] <= {'0 , vl_next_int};
            end
        end
    
    // Output Register Reads  
    always_comb begin
        vsew_o  = vcsr_r [VTYPE] [5:3]; // select element width
        vlmul_o = vcsr_r [VTYPE] [2:0]; // vector register group multiplier
        // compute max vl 
        if ( vl_max_i | (avl_i > vl_max_int) )
            vl_next_int = vl_max_int;
        else
            vl_next_int = avl_i[4:0];
    end

    // Intermediate loading
    assign vlenb_int    = vcsr_r[VLENB][2:0] >> vtype_i[4:2];
    assign vl_max_int   = vlenb_int         << vtype_i[1:0];

    // Output
    assign vl_o      = vcsr_r[VL][4:0];
    assign vl_next_o = vl_next_int;

endmodule

