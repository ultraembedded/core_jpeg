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

module jpeg_mcu_proc
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
    ,input           inport_last_i
    ,input           lookup_valid_i
    ,input  [  4:0]  lookup_width_i
    ,input  [  7:0]  lookup_value_i
    ,input           outport_blk_space_i

    // Outputs
    ,output [  5:0]  inport_pop_o
    ,output          lookup_req_o
    ,output [  1:0]  lookup_table_o
    ,output [ 15:0]  lookup_input_o
    ,output          outport_valid_o
    ,output [ 15:0]  outport_data_o
    ,output [  5:0]  outport_idx_o
    ,output [ 31:0]  outport_id_o
    ,output          outport_eob_o
);



//-----------------------------------------------------------------
// Block Type (Y, Cb, Cr)
//-----------------------------------------------------------------
wire start_block_w;
wire next_block_w;
wire end_of_image_w;

localparam JPEG_MONOCHROME  = 2'd0;
localparam JPEG_YCBCR_444   = 2'd1;
localparam JPEG_YCBCR_420   = 2'd2;
localparam JPEG_UNSUPPORTED = 2'd3;

localparam BLOCK_Y          = 2'd0;
localparam BLOCK_CB         = 2'd1;
localparam BLOCK_CR         = 2'd2;
localparam BLOCK_EOF        = 2'd3;

wire [1:0] block_type_w;

localparam DHT_TABLE_Y_DC_IDX  = 2'd0;
localparam DHT_TABLE_Y_AC_IDX  = 2'd1;
localparam DHT_TABLE_CX_DC_IDX = 2'd2;
localparam DHT_TABLE_CX_AC_IDX = 2'd3;

jpeg_mcu_id
u_id
(
     .clk_i(clk_i)
    ,.rst_i(rst_i)

    ,.img_start_i(img_start_i)
    ,.img_end_i(img_end_i)
    ,.img_width_i(img_width_i)
    ,.img_height_i(img_height_i)
    ,.img_mode_i(img_mode_i)

    ,.start_of_block_i(start_block_w)
    ,.end_of_block_i(next_block_w)

    ,.block_id_o(outport_id_o)
    ,.block_type_o(block_type_w)
    ,.end_of_image_o(end_of_image_w)
);

//-----------------------------------------------------------------
// FSM
//-----------------------------------------------------------------
localparam STATE_W           = 5;
localparam STATE_IDLE        = 5'd0;
localparam STATE_FETCH_WORD  = 5'd1;
localparam STATE_HUFF_LOOKUP = 5'd2;
localparam STATE_OUTPUT      = 5'd3;
localparam STATE_EOB         = 5'd4;
localparam STATE_EOF         = 5'd5;

reg [STATE_W-1:0] state_q;
reg [STATE_W-1:0] next_state_r;

reg [7:0]         code_bits_q;
reg [7:0]         coeff_idx_q;

always @ *
begin
    next_state_r = state_q;

    case (state_q)
    STATE_IDLE:
    begin
        if (end_of_image_w && outport_blk_space_i)
            next_state_r = STATE_EOF;
        else if (inport_valid_i && outport_blk_space_i)
            next_state_r = STATE_FETCH_WORD;
    end
    STATE_FETCH_WORD:
    begin
        if (coeff_idx_q >= 8'd63)
            next_state_r = STATE_EOB;
        else if (inport_valid_i)
            next_state_r = STATE_HUFF_LOOKUP;
    end
    STATE_HUFF_LOOKUP:
    begin
        if (lookup_valid_i)
            next_state_r = STATE_OUTPUT;
    end
    STATE_OUTPUT:
    begin
        next_state_r = STATE_FETCH_WORD;
    end
    STATE_EOB:
    begin
        next_state_r = STATE_IDLE;
    end
    STATE_EOF:
    begin
        if (!img_end_i)
            next_state_r = STATE_IDLE;
    end
    default : ;
    endcase

    if (img_start_i)
        next_state_r = STATE_IDLE;
end

assign start_block_w = (state_q == STATE_IDLE && next_state_r != STATE_IDLE);
assign next_block_w  = (state_q == STATE_EOB);

always @ (posedge clk_i )
if (rst_i)
    state_q <= STATE_IDLE;
else
    state_q <= next_state_r;

reg first_q;

always @ (posedge clk_i )
if (rst_i)
    first_q <= 1'b1;
else if (state_q == STATE_IDLE)
    first_q <= 1'b1;
else if (state_q == STATE_OUTPUT)
    first_q <= 1'b0;

//-----------------------------------------------------------------
// Huffman code lookup stash
//-----------------------------------------------------------------
reg [7:0] code_q;

always @ (posedge clk_i )
if (rst_i)
    code_q <= 8'b0;
else if (state_q == STATE_HUFF_LOOKUP && lookup_valid_i)
    code_q <= lookup_value_i;

//-----------------------------------------------------------------
// code[3:0] = width of symbol
//-----------------------------------------------------------------
always @ (posedge clk_i )
if (rst_i)
    code_bits_q <= 8'b0;
else if (state_q == STATE_HUFF_LOOKUP && lookup_valid_i)
    code_bits_q <= {4'b0, lookup_value_i[3:0]};

//-----------------------------------------------------------------
// Lookup width flops
//-----------------------------------------------------------------
reg [4:0] lookup_width_q;

always @ (posedge clk_i )
if (rst_i)
    lookup_width_q <= 5'b0;
else if (state_q == STATE_HUFF_LOOKUP && lookup_valid_i)
    lookup_width_q <= lookup_width_i;

//-----------------------------------------------------------------
// Data for coefficient (remainder from Huffman lookup)
//-----------------------------------------------------------------
reg [15:0] input_data_q;

wire [31:0] input_shift_w = inport_data_i >> (5'd16 - lookup_width_i);

always @ (posedge clk_i )
if (rst_i)
    input_data_q <= 16'b0;
// Use remaining data for actual coeffecient
else if (state_q == STATE_HUFF_LOOKUP && lookup_valid_i)
    input_data_q <= input_shift_w[15:0];

//-----------------------------------------------------------------
// Bit buffer pop
//-----------------------------------------------------------------
reg [5:0]  pop_bits_r;

wire [4:0] coef_bits_w = {1'b0, code_q[3:0]};

always @ *
begin
    pop_bits_r = 6'b0;

    case (state_q)
    STATE_OUTPUT:
    begin
        // DC coefficient
        if (coeff_idx_q == 8'd0)
            pop_bits_r = {1'b0, lookup_width_q} + coef_bits_w;
        // End of block or ZRL (no coefficient)
        else if (code_q == 8'b0 || code_q == 8'hF0)
            pop_bits_r = {1'b0, lookup_width_q};
        else
            pop_bits_r = {1'b0, lookup_width_q} + coef_bits_w;
    end
    default : ;
    endcase
end

assign lookup_req_o   = (state_q == STATE_FETCH_WORD) & inport_valid_i;
assign lookup_input_o = inport_data_i[31:16];
assign inport_pop_o   = pop_bits_r;

reg [1:0] lookup_table_r;
always @ *
begin
    lookup_table_r = DHT_TABLE_Y_DC_IDX;

    if (first_q) // (coeff_idx_q == 8'd0)
    begin
        if (block_type_w == BLOCK_Y)
            lookup_table_r = DHT_TABLE_Y_DC_IDX;
        else
            lookup_table_r = DHT_TABLE_CX_DC_IDX;
    end
    else
    begin
        if (block_type_w == BLOCK_Y)
            lookup_table_r = DHT_TABLE_Y_AC_IDX;
        else
            lookup_table_r = DHT_TABLE_CX_AC_IDX;
    end
end
assign lookup_table_o = lookup_table_r;

//-----------------------------------------------------------------------------
// decode_number: Extract number from code / width
//-----------------------------------------------------------------------------
function [15:0] decode_number;
    input [15:0] w;
    input [4:0]  bits;
    reg signed [15:0] code;
begin
    code = w;

    if ((code & (1<<(bits - 5'd1))) == 16'b0 && bits != 5'd0)
    begin
        code = (code | ((~0) << bits)) + 1;
    end
    decode_number = code;
end
endfunction

//-----------------------------------------------------------------
// Previous DC coeffecient
//-----------------------------------------------------------------
wire [1:0] comp_idx_w = block_type_w;

reg [15:0] prev_dc_coeff_q[3:0];
reg [15:0] dc_coeff_q;

always @ (posedge clk_i )
if (rst_i)
begin
    prev_dc_coeff_q[0] <= 16'b0;
    prev_dc_coeff_q[1] <= 16'b0;
    prev_dc_coeff_q[2] <= 16'b0;
    prev_dc_coeff_q[3] <= 16'b0; // X
end
else if (img_start_i)
begin
    prev_dc_coeff_q[0] <= 16'b0;
    prev_dc_coeff_q[1] <= 16'b0;
    prev_dc_coeff_q[2] <= 16'b0;
    prev_dc_coeff_q[3] <= 16'b0; // X
end
else if (state_q == STATE_EOB)
    prev_dc_coeff_q[comp_idx_w] <= dc_coeff_q;

//-----------------------------------------------------------------
// coeff
//-----------------------------------------------------------------
reg [15:0] coeff_r;

always @ *
begin
    if (coeff_idx_q == 8'b0)
        coeff_r = decode_number(input_data_q >> (16 - coef_bits_w), coef_bits_w) + prev_dc_coeff_q[comp_idx_w];
    else
        coeff_r = decode_number(input_data_q >> (16 - coef_bits_w), coef_bits_w);
end

//-----------------------------------------------------------------
// dc_coeff
//-----------------------------------------------------------------
always @ (posedge clk_i )
if (rst_i)
    dc_coeff_q <= 16'b0;
else if (state_q == STATE_OUTPUT && coeff_idx_q == 8'b0)
    dc_coeff_q <= coeff_r;

//-----------------------------------------------------------------
// DC / AC coeff
//-----------------------------------------------------------------
reg [15:0] coeff_q;

always @ (posedge clk_i )
if (rst_i)
    coeff_q <= 16'b0;
else if (state_q == STATE_OUTPUT)
    coeff_q <= coeff_r;

//-----------------------------------------------------------------
// Coeffecient index
//-----------------------------------------------------------------
always @ (posedge clk_i )
if (rst_i)
    coeff_idx_q <= 8'b0;
else if (state_q == STATE_EOB || img_start_i)
    coeff_idx_q <= 8'b0;
else if (state_q == STATE_FETCH_WORD && !first_q && inport_valid_i)
    coeff_idx_q <= coeff_idx_q + 8'd1;
else if (state_q == STATE_OUTPUT)
begin
    // DC
    if (coeff_idx_q == 8'b0)
        ;
    // AC
    else
    begin
        // End of block
        if (code_q == 8'b0)
            coeff_idx_q <= 8'd64;
        // ZRL - 16 zeros
        else if (code_q == 8'hF0)
            coeff_idx_q <= coeff_idx_q + 8'd15;
        // RLE number zeros (0 - 15)
        else
            coeff_idx_q <= coeff_idx_q + {4'b0, code_q[7:4]};
    end
end

//-----------------------------------------------------------------
// Output push
//-----------------------------------------------------------------
reg push_q;

always @ (posedge clk_i )
if (rst_i)
    push_q <= 1'b0;
else if (state_q == STATE_OUTPUT || state_q == STATE_EOF)
    push_q <= 1'b1;
else
    push_q <= 1'b0;

assign outport_valid_o = push_q && (coeff_idx_q < 8'd64);
assign outport_data_o  = coeff_q;
assign outport_idx_o   = coeff_idx_q[5:0];
assign outport_eob_o   = (state_q == STATE_EOB) || 
                         (state_q == STATE_EOF && push_q);

`ifdef verilator
function get_valid; /*verilator public*/
begin
    get_valid = outport_valid_o && block_type_w != BLOCK_EOF;
end
endfunction
function [5:0] get_sample_idx; /*verilator public*/
begin
    get_sample_idx = outport_idx_o;
end
endfunction
function [15:0] get_sample; /*verilator public*/
begin
    get_sample = outport_data_o;
end
endfunction

function [5:0] get_bitbuffer_pop; /*verilator public*/
begin
    get_bitbuffer_pop = inport_pop_o;
end
endfunction

function get_dht_valid; /*verilator public*/
begin
    get_dht_valid = lookup_valid_i && (state_q == STATE_HUFF_LOOKUP);
end
endfunction
function [4:0] get_dht_width; /*verilator public*/
begin
    get_dht_width = lookup_width_i;
end
endfunction
function [7:0] get_dht_value; /*verilator public*/
begin
    get_dht_value = lookup_value_i;
end
endfunction
`endif


endmodule
