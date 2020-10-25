//-----------------------------------------------------------------
//                      Baseline JPEG Decoder
//                             V0.1
//                       Ultra-Embedded.com
//                        Copyright 2020
//
//                   admin@ultra-embedded.com
//-----------------------------------------------------------------
//                      License: Apache 2.0
// This IP can be freely used in commercial projects, however you may
// want access to unreleased materials such as verification environments,
// or test vectors, as well as changes to the IP for integration purposes.
// If this is the case, contact the above address.
// I am interested to hear how and where this IP is used, so please get
// in touch!
//-----------------------------------------------------------------
// Copyright 2020 Ultra-Embedded.com
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//     http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//-----------------------------------------------------------------

module jpeg_output
(
    // Inputs
     input           clk_i
    ,input           rst_i
    ,input           img_start_i
    ,input           img_end_i
    ,input  [ 15:0]  img_width_i
    ,input  [ 15:0]  img_height_i
    ,input  [  1:0]  img_mode_i
    ,input           inport_valid_i
    ,input  [ 31:0]  inport_data_i
    ,input  [  5:0]  inport_idx_i
    ,input  [ 31:0]  inport_id_i
    ,input           outport_accept_i

    // Outputs
    ,output          inport_accept_o
    ,output          outport_valid_o
    ,output [ 15:0]  outport_width_o
    ,output [ 15:0]  outport_height_o
    ,output [ 15:0]  outport_pixel_x_o
    ,output [ 15:0]  outport_pixel_y_o
    ,output [  7:0]  outport_pixel_r_o
    ,output [  7:0]  outport_pixel_g_o
    ,output [  7:0]  outport_pixel_b_o
    ,output          idle_o
);



localparam BLOCK_Y          = 2'd0;
localparam BLOCK_CB         = 2'd1;
localparam BLOCK_CR         = 2'd2;
localparam BLOCK_EOF        = 2'd3;

localparam JPEG_MONOCHROME  = 2'd0;
localparam JPEG_YCBCR_444   = 2'd1;
localparam JPEG_YCBCR_420   = 2'd2;
localparam JPEG_UNSUPPORTED = 2'd3;

reg valid_r;
wire output_space_w = (!outport_valid_o || outport_accept_i);

//-----------------------------------------------------------------
// FIFO: Y
//-----------------------------------------------------------------
wire               y_valid_w;
wire signed [31:0] y_value_w;
wire               y_pop_w;
wire [31:0]        y_level_w;

jpeg_output_y_ram
u_ram_y
(
     .clk_i(clk_i)
    ,.rst_i(rst_i)

    ,.flush_i(img_start_i)
    ,.level_o(y_level_w)

    ,.push_i(inport_valid_i && (inport_id_i[31:30] == BLOCK_Y || inport_id_i[31:30] == BLOCK_EOF))
    ,.wr_idx_i(inport_idx_i)
    ,.data_in_i(inport_data_i)

    ,.valid_o(y_valid_w)
    ,.data_out_o(y_value_w)
    ,.pop_i(y_pop_w)
);

//-----------------------------------------------------------------
// FIFO: Cb
//-----------------------------------------------------------------
wire               cb_valid_w;
wire signed [31:0] cb_value_w;
wire               cb_pop_w;
wire [31:0]        cb_level_w;

jpeg_output_cx_ram
u_ram_cb
(
     .clk_i(clk_i)
    ,.rst_i(rst_i)

    ,.flush_i(img_start_i)
    ,.level_o(cb_level_w)
    ,.mode420_i(img_mode_i == JPEG_YCBCR_420)

    ,.push_i(inport_valid_i && (inport_id_i[31:30] == BLOCK_CB || inport_id_i[31:30] == BLOCK_EOF))
    ,.wr_idx_i(inport_idx_i)
    ,.data_in_i(inport_data_i)

    ,.valid_o(cb_valid_w)
    ,.data_out_o(cb_value_w)
    ,.pop_i(cb_pop_w)
);

//-----------------------------------------------------------------
// FIFO: Cr
//-----------------------------------------------------------------
wire               cr_valid_w;
wire signed [31:0] cr_value_w;
wire               cr_pop_w;
wire [31:0]        cr_level_w;

jpeg_output_cx_ram
u_ram_cr
(
     .clk_i(clk_i)
    ,.rst_i(rst_i)

    ,.flush_i(img_start_i)
    ,.level_o(cr_level_w)
    ,.mode420_i(img_mode_i == JPEG_YCBCR_420)

    ,.push_i(inport_valid_i && (inport_id_i[31:30] == BLOCK_CR || inport_id_i[31:30] == BLOCK_EOF))
    ,.wr_idx_i(inport_idx_i)
    ,.data_in_i(inport_data_i)

    ,.valid_o(cr_valid_w)
    ,.data_out_o(cr_value_w)
    ,.pop_i(cr_pop_w)
);

//-----------------------------------------------------------------
// FIFO: Info
//-----------------------------------------------------------------
wire        id_valid_w;
wire [31:0] id_value_w;
wire        id_pop_w;

jpeg_output_fifo
#(
     .WIDTH(32)
    ,.DEPTH(8)
    ,.ADDR_W(3)
)
u_info
(
     .clk_i(clk_i)
    ,.rst_i(rst_i)
    ,.flush_i(img_start_i)
 
    ,.push_i(inport_valid_i && (inport_id_i[31:30] == BLOCK_Y || inport_id_i[31:30] == BLOCK_EOF) && inport_idx_i == 6'd0)
    ,.data_in_i(inport_id_i)
    ,.accept_o()

    ,.valid_o(id_valid_w)
    ,.data_out_o(id_value_w)
    ,.pop_i(id_pop_w)
);

assign inport_accept_o   = (y_level_w <= 32'd384 && cr_level_w <= 32'd128) | idle_o;

//-----------------------------------------------------------------
// Block counter (0 - 63)
//-----------------------------------------------------------------
reg [5:0] idx_q;

always @ (posedge clk_i )
if (rst_i)
    idx_q <= 6'b0;
else if (img_start_i)
    idx_q <= 6'b0;
else if (valid_r && output_space_w)
    idx_q <= idx_q + 6'd1;

//-----------------------------------------------------------------
// Subsampling counter (420 chroma subsampling)
//-----------------------------------------------------------------
reg [1:0] subsmpl_q;

always @ (posedge clk_i )
if (rst_i)
    subsmpl_q <= 2'b0;
else if (img_start_i)
    subsmpl_q <= 2'b0;
else if (valid_r && output_space_w && img_mode_i == JPEG_YCBCR_420 && idx_q == 6'd63)
    subsmpl_q <= subsmpl_q + 2'd1;

//-----------------------------------------------------------------
// YUV -> RGB
//-----------------------------------------------------------------
reg active_q;

always @ (posedge clk_i )
if (rst_i)
    active_q <= 1'b0;
else if (img_start_i)
    active_q <= 1'b0;
else if (!active_q)
begin
    if (img_mode_i == JPEG_MONOCHROME)
        active_q <= (y_level_w >= 32'd64);
    else if (img_mode_i == JPEG_YCBCR_444)
        active_q <= (y_level_w >= 32'd64) && (cb_level_w >= 32'd64) && (cr_level_w >= 32'd64);
    else if (subsmpl_q != 2'b0) // 420
        active_q <= 1'b1;
    else // 420
        active_q <= (y_level_w >= 32'd256) && (cb_level_w >= 32'd256) && (cr_level_w >= 32'd256);
end
else if (valid_r && output_space_w && idx_q == 6'd63)
    active_q <= 1'b0;

reg signed [31:0] r_conv_r;
reg signed [31:0] g_conv_r;
reg signed [31:0] b_conv_r;

wire signed [31:0] cr_1_402_w = (cr_value_w * 5743) >>> 12; // cr_value_w * 1.402
wire signed [31:0] cr_0_714_w = (cr_value_w * 2925) >>> 12; // cr_value_w * 0.71414
wire signed [31:0] cb_0_344_w = (cb_value_w * 1410) >>> 12; // cb_value_w * 0.34414
wire signed [31:0] cb_1_772_w = (cb_value_w * 7258) >>> 12; // cb_value_w * 1.772

always @ *
begin
    valid_r  = active_q;
    r_conv_r = 32'b0;
    g_conv_r = 32'b0;
    b_conv_r = 32'b0;

    if (img_mode_i == JPEG_MONOCHROME)
    begin
        r_conv_r = 128 + y_value_w;
        g_conv_r = 128 + y_value_w;
        b_conv_r = 128 + y_value_w;
    end
    else// if (img_mode_i == JPEG_YCBCR_444)
    begin
        r_conv_r = 128 + y_value_w + cr_1_402_w;
        g_conv_r = 128 + y_value_w - cb_0_344_w - cr_0_714_w;
        b_conv_r = 128 + y_value_w + cb_1_772_w;
    end
end

assign y_pop_w  = output_space_w && active_q;
assign cb_pop_w = output_space_w && active_q;
assign cr_pop_w = output_space_w && active_q;
assign id_pop_w = output_space_w && (idx_q == 6'd63);

//-----------------------------------------------------------------
// Outputs
//-----------------------------------------------------------------
reg        valid_q;
reg [15:0] pixel_x_q;
reg [15:0] pixel_y_q;
reg [7:0]  pixel_r_q;
reg [7:0]  pixel_g_q;
reg [7:0]  pixel_b_q;

always @ (posedge clk_i )
if (rst_i)
    valid_q <= 1'b0;
else if (output_space_w)
    valid_q <= valid_r && (id_value_w[31:30] != BLOCK_EOF);

wire [31:0] x_start_w = {13'b0, id_value_w[15:0],3'b0};
wire [31:0] y_start_w = {15'b0, id_value_w[29:16],3'b0};

always @ (posedge clk_i )
if (rst_i)
begin
    pixel_x_q <= 16'b0;
    pixel_y_q <= 16'b0;
end
else if (output_space_w)
begin
    /* verilator lint_off WIDTH */
    pixel_x_q <= x_start_w + (idx_q % 8);
    pixel_y_q <= y_start_w + (idx_q / 8);
    /* verilator lint_on WIDTH */
end

always @ (posedge clk_i )
if (rst_i)
begin
    pixel_r_q <= 8'b0;
    pixel_g_q <= 8'b0;
    pixel_b_q <= 8'b0;
end
else if (output_space_w)
begin
    pixel_r_q <= (|r_conv_r[31:8]) ? (r_conv_r[31:24] ^ 8'hff) : r_conv_r[7:0];
    pixel_g_q <= (|g_conv_r[31:8]) ? (g_conv_r[31:24] ^ 8'hff) : g_conv_r[7:0];
    pixel_b_q <= (|b_conv_r[31:8]) ? (b_conv_r[31:24] ^ 8'hff) : b_conv_r[7:0];
end

assign outport_valid_o   = valid_q;
assign outport_pixel_x_o = pixel_x_q;
assign outport_pixel_y_o = pixel_y_q;
assign outport_width_o   = img_width_i;
assign outport_height_o  = img_height_i;
assign outport_pixel_r_o = pixel_r_q;
assign outport_pixel_g_o = pixel_g_q;
assign outport_pixel_b_o = pixel_b_q;

//-----------------------------------------------------------------
// Idle
//-----------------------------------------------------------------
reg idle_q;

always @ (posedge clk_i )
if (rst_i)
    idle_q <= 1'b1;
else if (img_start_i)
    idle_q <= 1'b0;
else if (id_valid_w && id_value_w[31:30] == BLOCK_EOF)
    idle_q <= 1'b1;

assign idle_o = idle_q;


endmodule
