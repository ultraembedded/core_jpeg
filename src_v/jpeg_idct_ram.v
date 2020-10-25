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

module jpeg_idct_ram
(
    // Inputs
     input           clk_i
    ,input           rst_i
    ,input           img_start_i
    ,input           img_end_i
    ,input           inport_valid_i
    ,input  [ 15:0]  inport_data_i
    ,input  [  5:0]  inport_idx_i
    ,input           inport_eob_i
    ,input           outport_ready_i

    // Outputs
    ,output          inport_accept_o
    ,output          outport_valid_o
    ,output [ 15:0]  outport_data0_o
    ,output [ 15:0]  outport_data1_o
    ,output [ 15:0]  outport_data2_o
    ,output [ 15:0]  outport_data3_o
    ,output [  2:0]  outport_idx_o
);



reg [1:0]   block_wr_q;
reg [1:0]   block_rd_q;
reg [5:0]   rd_idx_q;
reg [3:0]   rd_addr_q;

wire [5:0]  wr_ptr_w = {block_wr_q, inport_idx_i[5:3], inport_idx_i[0]};

wire [15:0] outport_data0_w;
wire [15:0] outport_data1_w;
wire [15:0] outport_data2_w;
wire [15:0] outport_data3_w;

wire wr0_w = inport_valid_i && inport_accept_o && (inport_idx_i[2:0] == 3'd0 || inport_idx_i[2:0] == 3'd1);
wire wr1_w = inport_valid_i && inport_accept_o && (inport_idx_i[2:0] == 3'd2 || inport_idx_i[2:0] == 3'd3);
wire wr2_w = inport_valid_i && inport_accept_o && (inport_idx_i[2:0] == 3'd4 || inport_idx_i[2:0] == 3'd5);
wire wr3_w = inport_valid_i && inport_accept_o && (inport_idx_i[2:0] == 3'd6 || inport_idx_i[2:0] == 3'd7);

jpeg_idct_ram_dp
u_ram0
(
     .clk0_i(clk_i)
    ,.rst0_i(rst_i)
    ,.clk1_i(clk_i)
    ,.rst1_i(rst_i)

    ,.addr0_i(wr_ptr_w)
    ,.data0_i(inport_data_i)
    ,.wr0_i(wr0_w)
    ,.data0_o()

    ,.addr1_i({block_rd_q, rd_addr_q})
    ,.data1_i(16'b0)
    ,.wr1_i(1'b0)
    ,.data1_o(outport_data0_w)
);

jpeg_idct_ram_dp
u_ram1
(
     .clk0_i(clk_i)
    ,.rst0_i(rst_i)
    ,.clk1_i(clk_i)
    ,.rst1_i(rst_i)

    ,.addr0_i(wr_ptr_w)
    ,.data0_i(inport_data_i)
    ,.wr0_i(wr1_w)
    ,.data0_o()

    ,.addr1_i({block_rd_q, rd_addr_q})
    ,.data1_i(16'b0)
    ,.wr1_i(1'b0)
    ,.data1_o(outport_data1_w)
);

jpeg_idct_ram_dp
u_ram2
(
     .clk0_i(clk_i)
    ,.rst0_i(rst_i)
    ,.clk1_i(clk_i)
    ,.rst1_i(rst_i)

    ,.addr0_i(wr_ptr_w)
    ,.data0_i(inport_data_i)
    ,.wr0_i(wr2_w)
    ,.data0_o()

    ,.addr1_i({block_rd_q, rd_addr_q})
    ,.data1_i(16'b0)
    ,.wr1_i(1'b0)
    ,.data1_o(outport_data2_w)
);

jpeg_idct_ram_dp
u_ram3
(
     .clk0_i(clk_i)
    ,.rst0_i(rst_i)
    ,.clk1_i(clk_i)
    ,.rst1_i(rst_i)

    ,.addr0_i(wr_ptr_w)
    ,.data0_i(inport_data_i)
    ,.wr0_i(wr3_w)
    ,.data0_o()

    ,.addr1_i({block_rd_q, rd_addr_q})
    ,.data1_i(16'b0)
    ,.wr1_i(1'b0)
    ,.data1_o(outport_data3_w)
);

//-----------------------------------------------------------------
// Data Qualifiers
//-----------------------------------------------------------------
reg [63:0]        data_valid0_r;
reg [63:0]        data_valid0_q;

always @ *
begin
    data_valid0_r = data_valid0_q;

    // End of block read out - reset data valid state
    if (outport_valid_o && rd_idx_q[5:0] == 6'd63)
    begin
        case (block_rd_q)
        2'd0:    data_valid0_r[15:0]  = 16'b0;
        2'd1:    data_valid0_r[31:16] = 16'b0;
        2'd2:    data_valid0_r[47:32] = 16'b0;
        default: data_valid0_r[63:48] = 16'b0;
        endcase
    end

    if (wr0_w)
        data_valid0_r[wr_ptr_w] = 1'b1;
end

always @ (posedge clk_i )
if (rst_i)
    data_valid0_q <= 64'b0;
else if (img_start_i)
    data_valid0_q <= 64'b0;
else
    data_valid0_q <= data_valid0_r;

reg [63:0]        data_valid1_r;
reg [63:0]        data_valid1_q;

always @ *
begin
    data_valid1_r = data_valid1_q;

    // End of block read out - reset data valid state
    if (outport_valid_o && rd_idx_q[5:0] == 6'd63)
    begin
        case (block_rd_q)
        2'd0:    data_valid1_r[15:0]  = 16'b0;
        2'd1:    data_valid1_r[31:16] = 16'b0;
        2'd2:    data_valid1_r[47:32] = 16'b0;
        default: data_valid1_r[63:48] = 16'b0;
        endcase
    end

    if (wr1_w)
        data_valid1_r[wr_ptr_w] = 1'b1;
end

always @ (posedge clk_i )
if (rst_i)
    data_valid1_q <= 64'b0;
else if (img_start_i)
    data_valid1_q <= 64'b0;
else
    data_valid1_q <= data_valid1_r;

reg [63:0]        data_valid2_r;
reg [63:0]        data_valid2_q;

always @ *
begin
    data_valid2_r = data_valid2_q;

    // End of block read out - reset data valid state
    if (outport_valid_o && rd_idx_q[5:0] == 6'd63)
    begin
        case (block_rd_q)
        2'd0:    data_valid2_r[15:0]  = 16'b0;
        2'd1:    data_valid2_r[31:16] = 16'b0;
        2'd2:    data_valid2_r[47:32] = 16'b0;
        default: data_valid2_r[63:48] = 16'b0;
        endcase
    end

    if (wr2_w)
        data_valid2_r[wr_ptr_w] = 1'b1;
end

always @ (posedge clk_i )
if (rst_i)
    data_valid2_q <= 64'b0;
else if (img_start_i)
    data_valid2_q <= 64'b0;
else
    data_valid2_q <= data_valid2_r;

reg [63:0]        data_valid3_r;
reg [63:0]        data_valid3_q;

always @ *
begin
    data_valid3_r = data_valid3_q;

    // End of block read out - reset data valid state
    if (outport_valid_o && rd_idx_q[5:0] == 6'd63)
    begin
        case (block_rd_q)
        2'd0:    data_valid3_r[15:0]  = 16'b0;
        2'd1:    data_valid3_r[31:16] = 16'b0;
        2'd2:    data_valid3_r[47:32] = 16'b0;
        default: data_valid3_r[63:48] = 16'b0;
        endcase
    end

    if (wr3_w)
        data_valid3_r[wr_ptr_w] = 1'b1;
end

always @ (posedge clk_i )
if (rst_i)
    data_valid3_q <= 64'b0;
else if (img_start_i)
    data_valid3_q <= 64'b0;
else
    data_valid3_q <= data_valid3_r;


//-----------------------------------------------------------------
// Input Buffer
//-----------------------------------------------------------------
reg [3:0] block_ready_q;

always @ (posedge clk_i )
if (rst_i)
begin
    block_ready_q     <= 4'b0;
    block_wr_q        <= 2'b0;
    block_rd_q        <= 2'b0;
end
else if (img_start_i)
begin
    block_ready_q     <= 4'b0;
    block_wr_q        <= 2'b0;
    block_rd_q        <= 2'b0;
end
else
begin
    if (inport_eob_i && inport_accept_o)
    begin
        block_ready_q[block_wr_q] <= 1'b1;
        block_wr_q                <= block_wr_q + 2'd1;
    end

    if (outport_valid_o && rd_idx_q[5:0] == 6'd63)
    begin
        block_ready_q[block_rd_q] <= 1'b0;
        block_rd_q                <= block_rd_q + 2'd1;
    end
end

assign inport_accept_o = ~block_ready_q[block_wr_q];

//-----------------------------------------------------------------
// FSM
//-----------------------------------------------------------------
localparam STATE_W           = 2;
localparam STATE_IDLE        = 2'd0;
localparam STATE_SETUP       = 2'd1;
localparam STATE_ACTIVE      = 2'd2;

reg [STATE_W-1:0] state_q;
reg [STATE_W-1:0] next_state_r;

always @ *
begin
    next_state_r = state_q;

    case (state_q)
    STATE_IDLE:
    begin
        if (block_ready_q[block_rd_q] && outport_ready_i)
            next_state_r = STATE_SETUP;
    end
    STATE_SETUP:
    begin
        next_state_r = STATE_ACTIVE;
    end
    STATE_ACTIVE:
    begin
        if (outport_valid_o && rd_idx_q == 6'd63)
            next_state_r = STATE_IDLE;
    end
    default: ;
    endcase

    if (img_start_i)
        next_state_r = STATE_IDLE;
end

always @ (posedge clk_i )
if (rst_i)
    state_q <= STATE_IDLE;
else
    state_q <= next_state_r;

always @ (posedge clk_i )
if (rst_i)
    rd_idx_q <= 6'b0;
else if (img_start_i)
    rd_idx_q <= 6'b0;
else if (state_q == STATE_ACTIVE)
    rd_idx_q <= rd_idx_q + 6'd1;

always @ (posedge clk_i )
if (rst_i)
    rd_addr_q <= 4'b0;
else if (state_q == STATE_IDLE)
    rd_addr_q <= 4'b0;
else if (state_q == STATE_SETUP)
    rd_addr_q <= 4'd1;
else if (state_q == STATE_ACTIVE)
begin
    case (rd_idx_q[2:0])
    3'd0: rd_addr_q <= rd_addr_q - 1;
    3'd1: rd_addr_q <= rd_addr_q + 1;
    3'd2: ;
    3'd3: rd_addr_q <= rd_addr_q - 1;
    3'd4: rd_addr_q <= rd_addr_q + 1;
    3'd5: rd_addr_q <= rd_addr_q - 1;
    3'd6: rd_addr_q <= rd_addr_q + 2;
    3'd7: rd_addr_q <= rd_addr_q + 1;
    endcase
end

reg data_val0_q;
reg data_val1_q;
reg data_val2_q;
reg data_val3_q;

always @ (posedge clk_i )
if (rst_i)
begin
    data_val0_q <= 1'b0;
    data_val1_q <= 1'b0;
    data_val2_q <= 1'b0;
    data_val3_q <= 1'b0;
end
else
begin
    data_val0_q <= data_valid0_q[{block_rd_q, rd_addr_q}];
    data_val1_q <= data_valid1_q[{block_rd_q, rd_addr_q}];
    data_val2_q <= data_valid2_q[{block_rd_q, rd_addr_q}];
    data_val3_q <= data_valid3_q[{block_rd_q, rd_addr_q}];
end

assign outport_valid_o = (state_q == STATE_ACTIVE);
assign outport_idx_o   = rd_idx_q[2:0];
assign outport_data0_o = {16{data_val0_q}} & outport_data0_w;
assign outport_data1_o = {16{data_val1_q}} & outport_data1_w;
assign outport_data2_o = {16{data_val2_q}} & outport_data2_w;
assign outport_data3_o = {16{data_val3_q}} & outport_data3_w;


endmodule
