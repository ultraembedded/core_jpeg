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

module jpeg_input
(
    // Inputs
     input           clk_i
    ,input           rst_i
    ,input           inport_valid_i
    ,input  [ 31:0]  inport_data_i
    ,input  [  3:0]  inport_strb_i
    ,input           inport_last_i
    ,input           dqt_cfg_accept_i
    ,input           dht_cfg_accept_i
    ,input           data_accept_i

    // Outputs
    ,output          inport_accept_o
    ,output          img_start_o
    ,output          img_end_o
    ,output [ 15:0]  img_width_o
    ,output [ 15:0]  img_height_o
    ,output [  1:0]  img_mode_o
    ,output [  1:0]  img_dqt_table_y_o
    ,output [  1:0]  img_dqt_table_cb_o
    ,output [  1:0]  img_dqt_table_cr_o
    ,output          dqt_cfg_valid_o
    ,output [  7:0]  dqt_cfg_data_o
    ,output          dqt_cfg_last_o
    ,output          dht_cfg_valid_o
    ,output [  7:0]  dht_cfg_data_o
    ,output          dht_cfg_last_o
    ,output          data_valid_o
    ,output [  7:0]  data_data_o
    ,output          data_last_o
);



wire inport_accept_w;

//-----------------------------------------------------------------
// Input data read index
//-----------------------------------------------------------------
reg [1:0] byte_idx_q;

always @ (posedge clk_i )
if (rst_i)
    byte_idx_q <= 2'b0;
else if (inport_valid_i && inport_accept_w && inport_last_i)
    byte_idx_q <= 2'b0;
else if (inport_valid_i && inport_accept_w)
    byte_idx_q <= byte_idx_q + 2'd1;

//-----------------------------------------------------------------
// Data mux
//-----------------------------------------------------------------
reg [7:0] data_r;

always @ *
begin
    data_r = 8'b0;

    case (byte_idx_q)
    default: data_r = {8{inport_strb_i[0]}} & inport_data_i[7:0];
    2'd1:    data_r = {8{inport_strb_i[1]}} & inport_data_i[15:8];
    2'd2:    data_r = {8{inport_strb_i[2]}} & inport_data_i[23:16];
    2'd3:    data_r = {8{inport_strb_i[3]}} & inport_data_i[31:24];
    endcase
end

//-----------------------------------------------------------------
// Last data
//-----------------------------------------------------------------
reg [7:0] last_b_q;

always @ (posedge clk_i )
if (rst_i)
    last_b_q <= 8'b0;
else if (inport_valid_i && inport_accept_w)
    last_b_q <= inport_last_i ? 8'b0 : data_r;

//-----------------------------------------------------------------
// Token decoder
//-----------------------------------------------------------------
wire token_soi_w  = (last_b_q == 8'hFF && data_r == 8'hd8);
wire token_sof0_w = (last_b_q == 8'hFF && data_r == 8'hc0);
wire token_dqt_w  = (last_b_q == 8'hFF && data_r == 8'hdb);
wire token_dht_w  = (last_b_q == 8'hFF && data_r == 8'hc4);
wire token_eoi_w  = (last_b_q == 8'hFF && data_r == 8'hd9);
wire token_sos_w  = (last_b_q == 8'hFF && data_r == 8'hda);
wire token_pad_w  = (last_b_q == 8'hFF && data_r == 8'h00);

// Unsupported
wire token_sof2_w = (last_b_q == 8'hFF && data_r == 8'hc2);
wire token_dri_w  = (last_b_q == 8'hFF && data_r == 8'hdd);
wire token_rst_w  = (last_b_q == 8'hFF && data_r >= 8'hd0 && data_r <= 8'hd7);
wire token_app_w  = (last_b_q == 8'hFF && data_r >= 8'he0 && data_r <= 8'hef);
wire token_com_w  = (last_b_q == 8'hFF && data_r == 8'hfe);

//-----------------------------------------------------------------
// FSM
//-----------------------------------------------------------------
localparam STATE_W           = 5;
localparam STATE_IDLE        = 5'd0;
localparam STATE_ACTIVE      = 5'd1;
localparam STATE_UXP_LENH    = 5'd2;
localparam STATE_UXP_LENL    = 5'd3;
localparam STATE_UXP_DATA    = 5'd4;
localparam STATE_DQT_LENH    = 5'd5;
localparam STATE_DQT_LENL    = 5'd6;
localparam STATE_DQT_DATA    = 5'd7;
localparam STATE_DHT_LENH    = 5'd8;
localparam STATE_DHT_LENL    = 5'd9;
localparam STATE_DHT_DATA    = 5'd10;
localparam STATE_IMG_LENH    = 5'd11;
localparam STATE_IMG_LENL    = 5'd12;
localparam STATE_IMG_SOS     = 5'd13;
localparam STATE_IMG_DATA    = 5'd14;
localparam STATE_SOF_LENH    = 5'd15;
localparam STATE_SOF_LENL    = 5'd16;
localparam STATE_SOF_DATA    = 5'd17;

reg [STATE_W-1:0] state_q;
reg [15:0]        length_q;

reg [STATE_W-1:0] next_state_r;
always @ *
begin
    next_state_r = state_q;

    case (state_q)
    //-------------------------------------------------------------
    // IDLE - waiting for SOI
    //-------------------------------------------------------------
    STATE_IDLE :
    begin
        if (token_soi_w)
            next_state_r = STATE_ACTIVE;
    end
    //-------------------------------------------------------------
    // ACTIVE - waiting for various image markers
    //-------------------------------------------------------------
    STATE_ACTIVE :
    begin
        if (token_eoi_w)
            next_state_r = STATE_IDLE;
        else if (token_dqt_w)
            next_state_r = STATE_DQT_LENH;
        else if (token_dht_w)
            next_state_r = STATE_DHT_LENH;
        else if (token_sos_w)
            next_state_r = STATE_IMG_LENH;
        else if (token_sof0_w)
            next_state_r = STATE_SOF_LENH;
        // Unsupported
        else if (token_sof2_w ||
                 token_dri_w ||
                 token_rst_w ||
                 token_app_w ||
                 token_com_w)
            next_state_r = STATE_UXP_LENH;

    end
    //-------------------------------------------------------------
    // IMG
    //-------------------------------------------------------------
    STATE_IMG_LENH :
    begin
        if (inport_valid_i)
            next_state_r = STATE_IMG_LENL;
    end
    STATE_IMG_LENL :
    begin
        if (inport_valid_i)
            next_state_r = STATE_IMG_SOS;
    end
    STATE_IMG_SOS :
    begin
        if (inport_valid_i && length_q <= 16'd1)
            next_state_r = STATE_IMG_DATA;
    end
    STATE_IMG_DATA :
    begin
        if (token_eoi_w)
            next_state_r = STATE_IDLE;
    end
    //-------------------------------------------------------------
    // DQT
    //-------------------------------------------------------------
    STATE_DQT_LENH :
    begin
        if (inport_valid_i)
            next_state_r = STATE_DQT_LENL;
    end
    STATE_DQT_LENL :
    begin
        if (inport_valid_i)
            next_state_r = STATE_DQT_DATA;
    end
    STATE_DQT_DATA :
    begin
        if (inport_valid_i && inport_accept_w && length_q <= 16'd1)
            next_state_r = STATE_ACTIVE;
    end
    //-------------------------------------------------------------
    // SOF
    //-------------------------------------------------------------
    STATE_SOF_LENH :
    begin
        if (inport_valid_i)
            next_state_r = STATE_SOF_LENL;
    end
    STATE_SOF_LENL :
    begin
        if (inport_valid_i)
            next_state_r = STATE_SOF_DATA;
    end
    STATE_SOF_DATA :
    begin
        if (inport_valid_i && inport_accept_w && length_q <= 16'd1)
            next_state_r = STATE_ACTIVE;
    end
    //-------------------------------------------------------------
    // DHT
    //-------------------------------------------------------------
    STATE_DHT_LENH :
    begin
        if (inport_valid_i)
            next_state_r = STATE_DHT_LENL;
    end
    STATE_DHT_LENL :
    begin
        if (inport_valid_i)
            next_state_r = STATE_DHT_DATA;
    end
    STATE_DHT_DATA :
    begin
        if (inport_valid_i && inport_accept_w && length_q <= 16'd1)
            next_state_r = STATE_ACTIVE;
    end
    //-------------------------------------------------------------
    // Unsupported sections - skip
    //-------------------------------------------------------------
    STATE_UXP_LENH :
    begin
        if (inport_valid_i)
            next_state_r = STATE_UXP_LENL;
    end
    STATE_UXP_LENL :
    begin
        if (inport_valid_i)
            next_state_r = STATE_UXP_DATA;
    end
    STATE_UXP_DATA :
    begin
        if (inport_valid_i && inport_accept_w && length_q <= 16'd1)
            next_state_r = STATE_ACTIVE;
    end
    default:
        ;
    endcase

    // End of data stream
    if (inport_valid_i && inport_last_i && inport_accept_w)
        next_state_r = STATE_IDLE;
end

always @ (posedge clk_i )
if (rst_i)
    state_q <= STATE_IDLE;
else
    state_q <= next_state_r;

//-----------------------------------------------------------------
// Length
//-----------------------------------------------------------------
always @ (posedge clk_i )
if (rst_i)
    length_q <= 16'b0;
else if (state_q == STATE_UXP_LENH || state_q == STATE_DQT_LENH || 
         state_q == STATE_DHT_LENH || state_q == STATE_IMG_LENH ||
         state_q == STATE_SOF_LENH)
    length_q <= {data_r, 8'b0};
else if (state_q == STATE_UXP_LENL || state_q == STATE_DQT_LENL ||
         state_q == STATE_DHT_LENL || state_q == STATE_IMG_LENL ||
         state_q == STATE_SOF_LENL)
    length_q <= {8'b0, data_r} - 16'd2;
else if ((state_q == STATE_UXP_DATA || 
          state_q == STATE_DQT_DATA ||
          state_q == STATE_DHT_DATA ||
          state_q == STATE_SOF_DATA ||
          state_q == STATE_IMG_SOS) && inport_valid_i && inport_accept_w)
    length_q <= length_q - 16'd1;

//-----------------------------------------------------------------
// DQT
//-----------------------------------------------------------------
assign dqt_cfg_valid_o = (state_q == STATE_DQT_DATA) && inport_valid_i;
assign dqt_cfg_data_o  = data_r;
assign dqt_cfg_last_o  = inport_last_i || (length_q == 16'd1);

//-----------------------------------------------------------------
// DQT
//-----------------------------------------------------------------
assign dht_cfg_valid_o = (state_q == STATE_DHT_DATA) && inport_valid_i;
assign dht_cfg_data_o  = data_r;
assign dht_cfg_last_o  = inport_last_i || (length_q == 16'd1);

//-----------------------------------------------------------------
// Image data
//-----------------------------------------------------------------
reg       data_valid_q;
reg [7:0] data_data_q;
reg       data_last_q;

always @ (posedge clk_i )
if (rst_i)
    data_valid_q <= 1'b0;
else if (inport_valid_i && data_accept_i)
    data_valid_q <= (state_q == STATE_IMG_DATA) && (inport_valid_i && ~token_pad_w && ~token_eoi_w);
else if (state_q != STATE_IMG_DATA)
    data_valid_q <= 1'b0;

always @ (posedge clk_i )
if (rst_i)
    data_data_q <= 8'b0;
else if (inport_valid_i && data_accept_i)
    data_data_q <= data_r;

assign data_valid_o = data_valid_q && inport_valid_i && !token_eoi_w;
assign data_data_o  = data_data_q;

// NOTE: Last is delayed by one cycles (not qualified by data_valid_o)
assign data_last_o  = data_valid_q && inport_valid_i && token_eoi_w;

//-----------------------------------------------------------------
// Handshaking
//-----------------------------------------------------------------
wire last_byte_w = (byte_idx_q == 2'd3) || inport_last_i;

assign inport_accept_w =  (state_q == STATE_DQT_DATA && dqt_cfg_accept_i) ||
                          (state_q == STATE_DHT_DATA && dht_cfg_accept_i) ||
                          (state_q == STATE_IMG_DATA && (data_accept_i || token_pad_w)) ||
                          (state_q != STATE_DQT_DATA && 
                           state_q != STATE_DHT_DATA && 
                           state_q != STATE_IMG_DATA);

assign inport_accept_o = last_byte_w && inport_accept_w;

//-----------------------------------------------------------------
// Capture Index
//-----------------------------------------------------------------
reg [5:0] idx_q;

always @ (posedge clk_i )
if (rst_i)
    idx_q <= 6'b0;
else if (inport_valid_i && inport_accept_w && state_q == STATE_SOF_DATA)
    idx_q <= idx_q + 6'd1;
else if (state_q == STATE_SOF_LENH)
    idx_q <= 6'b0;

//-----------------------------------------------------------------
// SOF capture
//-----------------------------------------------------------------
reg [7:0] img_precision_q;

always @ (posedge clk_i )
if (rst_i)
    img_precision_q <= 8'b0;
else if (token_sof0_w)
    img_precision_q <= 8'b0;
else if (state_q == STATE_SOF_DATA && idx_q == 6'd0)
    img_precision_q <= data_r;

reg [15:0] img_height_q;

always @ (posedge clk_i )
if (rst_i)
    img_height_q <= 16'b0;
else if (token_sof0_w)
    img_height_q <= 16'b0;
else if (state_q == STATE_SOF_DATA && idx_q == 6'd1)
    img_height_q <= {data_r, 8'b0};
else if (state_q == STATE_SOF_DATA && idx_q == 6'd2)
    img_height_q <= {img_height_q[15:8], data_r};

assign img_height_o = img_height_q;

reg [15:0] img_width_q;

always @ (posedge clk_i )
if (rst_i)
    img_width_q <= 16'b0;
else if (token_sof0_w)
    img_width_q <= 16'b0;
else if (state_q == STATE_SOF_DATA && idx_q == 6'd3)
    img_width_q <= {data_r, 8'b0};
else if (state_q == STATE_SOF_DATA && idx_q == 6'd4)
    img_width_q <= {img_width_q[15:8], data_r};

assign img_width_o  = img_width_q;

reg [7:0] img_num_comp_q;

always @ (posedge clk_i )
if (rst_i)
    img_num_comp_q <= 8'b0;
else if (token_sof0_w)
    img_num_comp_q <= 8'b0;
else if (state_q == STATE_SOF_DATA && idx_q == 6'd5)
    img_num_comp_q <= data_r;

reg [7:0] img_y_factor_q;

always @ (posedge clk_i )
if (rst_i)
    img_y_factor_q <= 8'b0;
else if (token_sof0_w)
    img_y_factor_q <= 8'b0;
else if (state_q == STATE_SOF_DATA && idx_q == 6'd7)
    img_y_factor_q <= data_r;

reg [1:0] img_y_dqt_table_q;

always @ (posedge clk_i )
if (rst_i)
    img_y_dqt_table_q <= 2'b0;
else if (token_sof0_w)
    img_y_dqt_table_q <= 2'b0;
else if (state_q == STATE_SOF_DATA && idx_q == 6'd8)
    img_y_dqt_table_q <= data_r[1:0];

reg [7:0] img_cb_factor_q;

always @ (posedge clk_i )
if (rst_i)
    img_cb_factor_q <= 8'b0;
else if (token_sof0_w)
    img_cb_factor_q <= 8'b0;
else if (state_q == STATE_SOF_DATA && idx_q == 6'd10)
    img_cb_factor_q <= data_r;

reg [1:0] img_cb_dqt_table_q;

always @ (posedge clk_i )
if (rst_i)
    img_cb_dqt_table_q <= 2'b0;
else if (token_sof0_w)
    img_cb_dqt_table_q <= 2'b0;
else if (state_q == STATE_SOF_DATA && idx_q == 6'd11)
    img_cb_dqt_table_q <= data_r[1:0];

reg [7:0] img_cr_factor_q;

always @ (posedge clk_i )
if (rst_i)
    img_cr_factor_q <= 8'b0;
else if (token_sof0_w)
    img_cr_factor_q <= 8'b0;
else if (state_q == STATE_SOF_DATA && idx_q == 6'd13)
    img_cr_factor_q <= data_r;

reg [1:0] img_cr_dqt_table_q;

always @ (posedge clk_i )
if (rst_i)
    img_cr_dqt_table_q <= 2'b0;
else if (token_sof0_w)
    img_cr_dqt_table_q <= 2'b0;
else if (state_q == STATE_SOF_DATA && idx_q == 6'd14)
    img_cr_dqt_table_q <= data_r[1:0];

assign img_dqt_table_y_o  = img_y_dqt_table_q;
assign img_dqt_table_cb_o = img_cb_dqt_table_q;
assign img_dqt_table_cr_o = img_cr_dqt_table_q;

wire [3:0] y_horiz_factor_w  = img_y_factor_q[7:4];
wire [3:0] y_vert_factor_w   = img_y_factor_q[3:0];
wire [3:0] cb_horiz_factor_w = img_cb_factor_q[7:4];
wire [3:0] cb_vert_factor_w  = img_cb_factor_q[3:0];
wire [3:0] cr_horiz_factor_w = img_cr_factor_q[7:4];
wire [3:0] cr_vert_factor_w  = img_cr_factor_q[3:0];

localparam JPEG_MONOCHROME  = 2'd0;
localparam JPEG_YCBCR_444   = 2'd1;
localparam JPEG_YCBCR_420   = 2'd2;
localparam JPEG_UNSUPPORTED = 2'd3;

reg [1:0] img_mode_q;

always @ (posedge clk_i )
if (rst_i)
    img_mode_q <= JPEG_UNSUPPORTED;
else if (token_sof0_w)
    img_mode_q <= JPEG_UNSUPPORTED;
else if (state_q == STATE_SOF_DATA && next_state_r == STATE_ACTIVE)
begin
    // Single component (Y)
    if (img_num_comp_q == 8'd1)
        img_mode_q <= JPEG_MONOCHROME;
    // Colour image (YCbCr)
    else if (img_num_comp_q == 8'd3)
    begin
        if (y_horiz_factor_w  == 4'd1 && y_vert_factor_w  == 4'd1 &&
            cb_horiz_factor_w == 4'd1 && cb_vert_factor_w == 4'd1 &&
            cr_horiz_factor_w == 4'd1 && cr_vert_factor_w == 4'd1)
            img_mode_q <= JPEG_YCBCR_444;
        else if (y_horiz_factor_w  == 4'd2 && y_vert_factor_w  == 4'd2 &&
                 cb_horiz_factor_w == 4'd1 && cb_vert_factor_w == 4'd1 &&
                 cr_horiz_factor_w == 4'd1 && cr_vert_factor_w == 4'd1)
            img_mode_q <= JPEG_YCBCR_420;
    end
end

reg eof_q;

always @ (posedge clk_i )
if (rst_i)
    eof_q <= 1'b1;
else if (state_q == STATE_IDLE && token_soi_w)
    eof_q <= 1'b0;
else if (img_end_o)
    eof_q <= 1'b1;

reg start_q;

always @ (posedge clk_i )
if (rst_i)
    start_q <= 1'b0;
else if (inport_valid_i & token_sos_w)
    start_q <= 1'b0;
else if (state_q == STATE_IDLE && token_soi_w)
    start_q <= 1'b1;    

assign img_start_o = start_q;
assign img_end_o   = eof_q | (inport_valid_i & token_eoi_w);
assign img_mode_o  = img_mode_q;


endmodule
