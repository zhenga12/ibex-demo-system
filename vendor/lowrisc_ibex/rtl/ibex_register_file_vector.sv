/* RISC-V Vector register file
 * ----------------------------------------------------------------------
 * Register file with 32, 32 bit wide registers. Register 0 is fixed to 0 for masking.
 *
 * 
 *
 */

module ibex_register_file_vector (
  // Clock and Reset
    input  logic                             clk_i,
    input  logic                             rst_ni,
    
    // CSR Settings
    input  logic          [2:0]              vsew_i, //standard element length
    input  logic          [2:0]              vlmul_i, // group multiple
    
    // Write input data
    input  logic          [127:0]            v_wdata_i,
    input  logic          [4:0]              v_waddr_i,
    input  logic                             v_we_i,
    input  logic          [3:0]              v_wnum, // one-hot encoding for number of elements to write
    input  logic                             v_load_en_i, // load enable

    // Read port A
    input  logic          [4:0]              v_raddr_a_i,
    output logic          [VLEN-1:0]         v_rdata_a_o,

    // Read port B
    input  logic          [4:0]              v_raddr_b_i,
    output logic          [VLEN-1:0]         v_rdata_b_o,

    // Read port C
    input  logic          [4:0]              v_raddr_c_i,
    output logic          [VLEN-1:0]         v_rdata_c_o,

    // output data
    output logic          [128-1:0]          v_reg_o
);
  

    localparam VLEN = 32,
    localparam LEN  = 32

    localparam VLMAX  = VLEN / vsew_i * vlmul_i; 
    localparam VLMIN  = 8;

    // Vector Registers: v0 ... v31
    logic [VLEN-1:0] vregs [LEN-1:0];

    // Write Registers from Input Write Data 
    logic [VLEN-1:0] v_wdata_0;
    logic [VLEN-1:0] v_wdata_1;
    logic [VLEN-1:0] v_wdata_2;
    logic [VLEN-1:0] v_wdata_3;

    logic [4:0] v_waddr_0;
    logic [4:0] v_waddr_1;
    logic [4:0] v_waddr_2;
    logic [4:0] v_waddr_3;

    // Write enables
    logic [4-1:0] v_we_0;
    logic [4-1:0] v_we_1;
    logic [4-1:0] v_we_2;
    logic [4-1:0] v_we_3;
    // Read Registers for Output Read Data
    logic [VLEN-1:0] v_rdata_a_0;
    logic [VLEN-1:0] v_rdata_a_1;
    logic [VLEN-1:0] v_rdata_a_2;
    logic [VLEN-1:0] v_rdata_a_3;
    
    logic [VLEN-1:0] v_rdata_b_0;
    logic [VLEN-1:0] v_rdata_b_1;
    logic [VLEN-1:0] v_rdata_b_2;
    logic [VLEN-1:0] v_rdata_b_3;
    
    logic [VLEN-1:0] v_rdata_c_0;
    logic [VLEN-1:0] v_rdata_c_1;
    logic [VLEN-1:0] v_rdata_c_2;
    logic [VLEN-1:0] v_rdata_c_3;

    // Read Regiser Address
    logic [4:0] v_raddr_a_0;
    logic [4:0] v_raddr_a_1;
    logic [4:0] v_raddr_a_2;
    logic [4:0] v_raddr_a_3;

    logic [4:0] v_raddr_b_0;
    logic [4:0] v_raddr_b_1;
    logic [4:0] v_raddr_b_2;
    logic [4:0] v_raddr_b_3;

// Logic to Populate Register File
    always_ff @(posedge clki, rstn_i) begin
        if(~rstn_i) begin
            vreg <= '{VLEN{'0}};
        end else begin
            if (v_we_i & (v_waddr_i != '0) begin
                // 128b input write data --> 4 groups of 32 bits
                // 4 groups of 8 bits SEW = 32b VLEN

                // group 0
                if (v_we_0[0]) vregs[v_waddr_0][VLMIN*1 - 1 -: VLMIN] <= v_wdata_0[VLMIN*1 - 1 -: VLMIN];
                if (v_we_0[1]) vregs[v_waddr_0][VLMIN*2 - 1 -: VLMIN] <= v_wdata_0[VLMIN*2 - 1 -: VLMIN];
                if (v_we_0[2]) vregs[v_waddr_0][VLMIN*3 - 1 -: VLMIN] <= v_wdata_0[VLMIN*3 - 1 -: VLMIN];
                if (v_we_0[3]) vregs[v_waddr_0][VLMIN*4 - 1 -: VLMIN] <= v_wdata_0[VLMIN*4 - 1 -: VLMIN];
                // group 1
                if (v_we_1[0]) vregs[v_waddr_1][VLMIN*1 - 1 -: VLMIN] <= v_wdata_1[VLMIN*1 - 1 -: VLMIN];
                if (v_we_1[1]) vregs[v_waddr_1][VLMIN*2 - 1 -: VLMIN] <= v_wdata_1[VLMIN*2 - 1 -: VLMIN];
                if (v_we_1[2]) vregs[v_waddr_1][VLMIN*3 - 1 -: VLMIN] <= v_wdata_1[VLMIN*3 - 1 -: VLMIN];
                if (v_we_1[3]) vregs[v_waddr_1][VLMIN*4 - 1 -: VLMIN] <= v_wdata_1[VLMIN*4 - 1 -: VLMIN];   
                // group 2
                if (v_we_2[0]) vregs[v_waddr_2][VLMIN*1 - 1 -: VLMIN] <= v_wdata_2[VLMIN*1 - 1 -: VLMIN];
                if (v_we_2[1]) vregs[v_waddr_2][VLMIN*2 - 1 -: VLMIN] <= v_wdata_2[VLMIN*2 - 1 -: VLMIN];
                if (v_we_2[2]) vregs[v_waddr_2][VLMIN*3 - 1 -: VLMIN] <= v_wdata_2[VLMIN*3 - 1 -: VLMIN];
                if (v_we_2[3]) vregs[v_waddr_2][VLMIN*4 - 1 -: VLMIN] <= v_wdata_2[VLMIN*4 - 1 -: VLMIN];
                // group 3
                if (v_we_3[0]) vregs[v_waddr_3][VLMIN*1 - 1 -: VLMIN] <= v_wdata_3[VLMIN*1 - 1 -: VLMIN];
                if (v_we_3[1]) vregs[v_waddr_3][VLMIN*2 - 1 -: VLMIN] <= v_wdata_3[VLMIN*2 - 1 -: VLMIN];
                if (v_we_3[2]) vregs[v_waddr_3][VLMIN*3 - 1 -: VLMIN] <= v_wdata_3[VLMIN*3 - 1 -: VLMIN];
                if (v_we_3[3]) vregs[v_waddr_3][VLMIN*4 - 1 -: VLMIN] <= v_wdata_3[VLMIN*4 - 1 -: VLMIN];
            end 
        end
    end

    // Determine Write Enables from VSETVLI
    always_comb begin
        v_we_0 = 'd0;
        v_we_1 = 'd0;
        v_we_2 = 'd0;
        v_we_3 = 'd0;

        if (v_load_en_i) begin
            unique case (vlmul_i)
                3'b000: begin // 1
                    case(v_waddr[1:0])
                        2'b00: v_we_0 = 'd1;
                        2'b01: v_we_1 = 'd1;
                        2'b10: v_we_2 = 'd1;
                        2'b11: v_we_3 = 'd1;
                    endcase
                end
                3'b001: begin // 2
                    if(~v_waddr[1]) begin
                        v_we_0 = 'd1;
                        v_we_1 = 'd1;    
                    end else begin
                        v_we_2 = 'd1;
                        v_we_3 = 'd1;
                    end
                end
                3'b010: begin // 4
                    v_we_0 = 'd1;
                    v_we_1 = 'd1; 
                    v_we_2 = 'd1; 
                    v_we_3 = 'd1; 
                end
            endcase         
        end else begin
            unique case(vsew_i)
                // 8b select element width
                3'b000: v_we_0 = v_wnum;
                // 16b select element width
                3'b001: begin // 16b
                    case (v_wnum)
                        4'b0001: begin // 1 elements of 16b
                            v_we_0 = 4'b0011;
                        end
                        4'b0011: begin // 2 elements of 16b
                            v_we_0 = 4'b1111;
                        end
                        4'b0111: begin // 3 elements of 16b
                            v_we_0 = 4'b1111;
                            v_we_1 = 4'b0011;
                        end
                        4'b1111: begin // 4 elemenets of 16b
                            v_we_0 = 4'b1111;
                            v_we_1 = 4'b1111;
                        end
                    endcase
                end

                // 32b select element width
                3'b010: begin
                    case(v_wnum):
                        4'b0001:
                            v_we_0 = 4'b1111;
                        4'b0011:
                            v_we_0 = 4'b1111;
                            v_we_1 = 4'b1111;
                        4'b0111:
                            v_we_0 = 4'b1111;
                            v_we_1 = 4'b1111;
                            v_we_2 = 4'b1111;
                        4'b0111:
                            v_we_0 = 4'b1111;
                            v_we_1 = 4'b1111;
                            v_we_2 = 4'b1111;
                            v_we_3 = 4'b1111;
                    endcase
                end
            endcase
        end
    end

    // Input Data Writing
    always_comb begin
        v_wdata_0 = '0;
        v_wdata_1 = '0;
        v_wdata_2 = '0;
        v_wdata_3 = '0;
    
        if(v_load_en_i) begin
            case (vlmul_i)
                2'b00: begin
                    case(v_waddr_i[1:0])
                       2'b00 : v_wdata_0 = v_wdata_i[VLEN*1-1 -: VLEN]; 
                       2'b01 : v_wdata_1 = v_wdata_i[VLEN*2-1 -: VLEN]; 
                       2'b10 : v_wdata_2 = v_wdata_i[VLEN*3-1 -: VLEN]; 
                       2'b11 : v_wdata_3 = v_wdata_i[VLEN*4-1 -: VLEN]; 
                    endcase
                end
                2'b01: begin
                    if(~v_waddr_i[1]) begin
                        v_wdata_0 = v_wdata_i[VLEN*1-1 -: VLEN];
                        v_wdata_1 = v_wdata_i[VLEN*2-1 -: VLEN];
                    end else begin
                        v_wdata_2 = v_wdata_i[VLEN*3-1 -: VLEN];
                        v_wdata_3 = v_wdata_i[VLEN*4-1-: VLEN];
                    end
                end
                2'b10: begin
                        v_wdata_0 = v_wdata_i[VLEN*1-1 -: VLEN];
                        v_wdata_1 = v_wdata_i[VLEN*2-1 -: VLEN];
                        v_wdata_2 = v_wdata_i[VLEN*3-1 -: VLEN];
                        v_wdata_3 = v_wdata_i[VLEN*4-1 -: VLEN];
                end
            endcase
        end else begin
            case (vsew_i)
                2'd0: // 8b
                    v_wdata_0 = {
                        v_wdata_i[103:96],
                        v_wdata_i[71:64],
                        v_wdata_i[39:32],
                        v_wdata_i[7:0]
                    };
                2'd1: // 16b
                begin
                    v_wdata_1 = {
                        v_wdata_i[111:96],
                        v_wdata_i[79:64]
                    };
                    v_wdata_0 = {
                        v_wdata_i[47:32],
                        v_wdata_i[15:0]
                    };
                end
                2'd2: // 32b
                begin
                    v_wdata_3 = v_wdata_i[127:96];
                    v_wdata_2 = v_wdata_i[95:64];
                    v_wdata_1 = v_wdata_i[63:32];
                    v_wdata_0 = v_wdata_i[31:0];
                end
            endcase
        end
    end
    
    // Output Data Reading
    always_comb begin
        unique case (vsew_i)
            2'b00: begin // 8b
                v_rdata_a_o = {
                    {24{1'b0}},
                    v_rdata_a_0[31:24],
                    {24{1'b0}},
                    v_rdata_a_0[23:16],
                    {24{1'b0}},
                    v_rdata_a_0[15:8],
                    {24{1'b0}},
                    v_rdata_a_0[7:0] };
    
                v_rdata_b_o = {
                    {24{1'b0}},
                    v_rdata_b_0[31:24],
                    {24{1'b0}},
                    v_rdata_b_o[23:16],
                    {24{1'b0}},
                    v_rdata_b_0[15:8],
                    {24{1'b0}},
                    v_rdata_b_0[7:0] };
    
                v_rdata_c_o = {
                    {24{1'b0}},
                    v_rdata_c_0[31:24],
                    {24{1'b0}},
                    v_rdata_c_0[23:16],
                    {24{1'b0}},
                    v_rdata_c_0[15:8],
                    {24{1'b0}},
                    v_rdata_c_0[7:0] };
            end
            2'b01: begin // 16b
                v_rdata_a_o = {
                    {16{1'b0}},
                    v_rdata_a_1[31:16],
                    {16{1'b0}},
                    v_rdata_a_1[15:0],
                    {16{1'b0}},
                    v_rdata_a_0[31:16],
                    {16{1'b0}},
                    v_rdata_a_0[15:0] };
    
                v_rdata_b_o = {
                    {16{1'b0}},
                    v_rdata_b_1[31:16],
                    {16{1'b0}},
                    v_rdata_b_1[15:0],
                    {16{1'b0}},
                    v_rdata_a_0[31:16],
                    {16{1'b0}},
                    v_rdata_b_0[15:0] };
    
                v_rdata_c_o = {
                    {16{1'b0}},
                    v_rdata_c_1[31:16],
                    {16{1'b0}},
                    v_rdata_c_1[15:0],
                    {16{1'b0}},
                    v_rdata_c_0[31:16],
                    {16{1'b0}},
                    v_rdata_c_0[15:0] };
            end
            2'b10: begin // 32b
                v_rdata_a_o = {
                    v_rdata_a_3,
                    v_rdata_a_2,
                    v_rdata_a_1,
                    v_rdata_a_0 };
                
                v_rdata_b_o = {
                    v_rdata_b_3,
                    v_rdata_b_2,
                    v_rdata_b_1,
                    v_rdata_b_0 };
    
                v_rdata_c_o = {
                    v_rdata_c_3,
                    v_rdata_c_2,
                    v_rdata_c_1,
                    v_rdata_c_0 };   
                
            end
            default: begin
                v_rdata_a_o = '0;
                v_rdata_b_o = '0;
                v_rdata_c_o = '0;
            end
        endcase
    
    end

    // Address Computation
    // TODO: figure out address computation...
    always_comb begin
        v_raddr_a_0 =  v_raddr_a;
        v_raddr_a_1 = {v_raddr_a[4:1], 1'b1};
        v_raddr_a_2 = {v_raddr_a[4:2], 1'b1, v_raddr_a[0]};
        v_raddr_a_3 = {v_raddr_a[4:2], 2'b11};

        v_raddr_b_0 =  v_raddr_b;
        v_raddr_b_1 = {v_raddr_b[4:1], 1'b1};
        v_raddr_b_2 = {v_raddr_b[4:2], 1'b1, v_raddr_b[0]};
        v_raddr_b_3 = {v_raddr_b[4:2], 2'b11};

        v_waddr_c_0 =  v_waddr_i;
        v_waddr_c_1 = {v_raddr_i[4:1], 1'b1};
        v_waddr_c_2 = {v_raddr_i[4:2], 1'b1, v_waddr_i[0]};
        v_waddr_c_3 = {v_raddr_i[4:2], 2'b11};
    
    
    end

    // REGISTER READ
    assign v_rdata_a_0 = vregs[v_raddr_a_0];
    assign v_rdata_a_1 = vregs[v_raddr_a_1];
    assign v_rdata_a_2 = vregs[v_raddr_a_2];
    assign v_rdata_a_3 = vregs[v_raddr_a_3];

    assign v_rdata_b_0 = vregs[v_raddr_b_0];
    assign v_rdata_b_1 = vregs[v_raddr_b_1];
    assign v_rdata_b_2 = vregs[v_raddr_b_2];
    assign v_rdata_b_3 = vregs[v_raddr_b_3];

    assign v_rdata_c_0 = vregs[v_waddr_0];
    assign v_rdata_c_1 = vregs[v_waddr_1];
    assign v_rdata_c_2 = vregs[v_waddr_2];
    assign v_rdata_c_3 = vregs[v_waddr_3];

endmodule // vector_register_file
