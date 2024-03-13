module vga_sync_demo #(
   parameter int unsigned CD = 12, // color depth
   parameter int unsigned COUNTER_BITS = 32,
   parameter int unsigned GpiWidth  = 8,
   parameter int unsigned GpoWidth  = 16,
   parameter int unsigned AddrWidth = 32,
   parameter int unsigned DataWidth = 32
   //parameter int unsigned RegAddr   = 12
   )    
   (
   input  logic clk, reset,
   // stream input
   //input  logic[CD-1:0] vga_si_rgb,
   // signals to vga monitor
   //output logic hsync, vsync,
   //output logic[CD-1:0] rgb,
   // frame counter output
   //output logic[COUNTER_BITS-1:0] hc, vc,

   //input  logic clk_i,
   //input  logic rst_ni,

   input  logic                 device_req_i,
   input  logic [AddrWidth-1:0] device_addr_i,
   input  logic [3:0]           device_be_i,
   output logic                 device_rvalid_o,
   output logic [DataWidth-1:0] device_rdata_o,
   /* verilator lint_off UNUSED */
   input  logic                 device_we_i,
   input  logic [DataWidth-1:0] device_wdata_i,
   input  logic [GpiWidth-1:0] gp_i,
/* verilator lint_on UNUSED */

  output logic [GpoWidth-1:0] gp_o

   );

   // localparam declaration
   // vga 640-by-480 sync parameters
   localparam HD = 640;  // horizontal display area
   localparam HF = 16;   // h. front porch
   localparam HB = 48;   // h. back porch
   localparam HR = 96;   // h. retrace
   localparam HT = HD+HF+HB+HR; // horizontal total (800)
   localparam VD = 480;  // vertical display area
   localparam VF = 10;   // v. front porch
   localparam VB = 33;   // v. back porch
   localparam VR = 2;    // v. retrace
   localparam VT = VD+VF+VB+VR; // vertical total (525)
   // signal delaration
   logic q_reg;
   logic tick_25M;
   logic[COUNTER_BITS-1:0] x, y;
   logic hsync_i, vsync_i, video_on_i;
   logic hsync_reg, vsync_reg;  
   /* verilator lint_off UNUSED */
   logic [CD-1:0] rgb_reg;  
   /* verilator lint_on UNUSED */
   logic[CD-1:0] vga_si_rgb = device_wdata_i[CD-1:0] & {(CD){1'b1}};
   // body 
   // mod-2 counter to generate 25M-Hz tick based on 50MHz input
   always_ff @(posedge clk)
      q_reg <= q_reg + 1;
   assign tick_25M = (q_reg == 1'b1) ? 1 : 0;
   // instantiate frame counter
   frame_counter #(.HMAX(HT), .VMAX(VT)) frame_unit
      (.clk(clk), .reset(reset), 
       .sync_clr(0), .hcount(x), .vcount(y), .inc(tick_25M), 
       .frame_start(), .frame_end());
   // horizontal sync decoding
   assign hsync_i = ((x>=(HD+HF)) && (x<=(HD+HF+HR-1))) ? 0 : 1;
   // vertical sync decoding
   assign vsync_i = ((y>=(VD+VF)) && (y<=(VD+VF+VR-1))) ? 0 : 1;
   // display on/off
   assign video_on_i = ((x < HD) && (y < VD)) ? 1: 0;
   // buffered output to vga monitor
   always_ff @(posedge clk) begin
      vsync_reg <= vsync_i;
      hsync_reg <= hsync_i;
      if (video_on_i)
         rgb_reg <= vga_si_rgb;
      else
         rgb_reg <= 0;    // black when display off 
   end


   // output 
   logic [DataWidth-1:0] vga_data = {{(DataWidth-14){1'b0}},~vsync_reg, ~hsync_reg, 12'hFFF};
   /* verilator lint_off WIDTHCONCAT */
   //logic [GpiWidth-1:0] vga_gpi = {{(GpiWidth-14){1'b0}},vsync_reg, hsync_reg, 12'hFFF};
   /* verilator lint_on WIDTHCONCAT */
   //logic [GpoWidth-1:0] vga_gpo;
   gpio #(
    .GpiWidth ( GpiWidth ),
    .GpoWidth ( GpoWidth )
  ) vga_output (
    .clk_i (clk),
    .rst_ni(reset),

    .device_req_i   (device_req_i),
    .device_addr_i  (device_addr_i),
    .device_we_i    (tick_25M),
    .device_be_i    (device_be_i),
    .device_wdata_i (vga_data),
    .device_rvalid_o(device_rvalid_o),
    .device_rdata_o (device_rdata_o),

    .gp_i , 
    .gp_o 
  );
   /*
   assign hsync = hsync_reg;
   assign vsync = vsync_reg;
   assign rgb = 12'hFFF; //pass rgb_reg values to output later
   assign hc = x;
   assign vc = y;
   */
endmodule