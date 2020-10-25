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

module jpeg_idct
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
    ,input  [ 31:0]  inport_id_i
    ,input           outport_accept_i

    // Outputs
    ,output          inport_accept_o
    ,output          outport_valid_o
    ,output [ 31:0]  outport_data_o
    ,output [  5:0]  outport_idx_o
    ,output [ 31:0]  outport_id_o
);




wire          input_valid_w;
wire [ 15:0]  input_data0_w;
wire [ 15:0]  input_data1_w;
wire [ 15:0]  input_data2_w;
wire [ 15:0]  input_data3_w;
wire [  2:0]  input_idx_w;
wire          input_ready_w;


jpeg_idct_ram
u_input
(
     .clk_i(clk_i)
    ,.rst_i(rst_i)

    ,.img_start_i(img_start_i)
    ,.img_end_i(img_end_i)

    ,.inport_valid_i(inport_valid_i)
    ,.inport_data_i(inport_data_i)
    ,.inport_idx_i(inport_idx_i)
    ,.inport_eob_i(inport_eob_i)
    ,.inport_accept_o(inport_accept_o)

    ,.outport_valid_o(input_valid_w)
    ,.outport_data0_o(input_data0_w)
    ,.outport_data1_o(input_data1_w)
    ,.outport_data2_o(input_data2_w)
    ,.outport_data3_o(input_data3_w)
    ,.outport_idx_o(input_idx_w)
    ,.outport_ready_i(outport_accept_i)
);

wire          idct_x_valid_w;
wire [ 31:0]  idct_x_data_w;
wire [  5:0]  idct_x_idx_w;
wire          idct_x_accept_w;

jpeg_idct_x
u_idct_x
(
     .clk_i(clk_i)
    ,.rst_i(rst_i)

    ,.img_start_i(img_start_i)
    ,.img_end_i(img_end_i)

    ,.inport_valid_i(input_valid_w)
    ,.inport_data0_i(input_data0_w)
    ,.inport_data1_i(input_data1_w)
    ,.inport_data2_i(input_data2_w)
    ,.inport_data3_i(input_data3_w)
    ,.inport_idx_i(input_idx_w)

    ,.outport_valid_o(idct_x_valid_w)
    ,.outport_data_o(idct_x_data_w)
    ,.outport_idx_o(idct_x_idx_w)
);

wire          transpose_valid_w;
wire [ 31:0]  transpose_data0_w;
wire [ 31:0]  transpose_data1_w;
wire [ 31:0]  transpose_data2_w;
wire [ 31:0]  transpose_data3_w;
wire [  2:0]  transpose_idx_w;
wire          transpose_ready_w = 1'b1;

jpeg_idct_transpose
u_transpose
(
     .clk_i(clk_i)
    ,.rst_i(rst_i)

    ,.img_start_i(img_start_i)
    ,.img_end_i(img_end_i)

    ,.inport_valid_i(idct_x_valid_w)
    ,.inport_data_i(idct_x_data_w)
    ,.inport_idx_i(idct_x_idx_w)
    ,.inport_accept_o(idct_x_accept_w)

    ,.outport_valid_o(transpose_valid_w)
    ,.outport_data0_o(transpose_data0_w)
    ,.outport_data1_o(transpose_data1_w)
    ,.outport_data2_o(transpose_data2_w)
    ,.outport_data3_o(transpose_data3_w)
    ,.outport_idx_o(transpose_idx_w)
    ,.outport_ready_i(transpose_ready_w)
);

jpeg_idct_y
u_idct_y
(
     .clk_i(clk_i)
    ,.rst_i(rst_i)

    ,.img_start_i(img_start_i)
    ,.img_end_i(img_end_i)

    ,.inport_valid_i(transpose_valid_w)
    ,.inport_data0_i(transpose_data0_w)
    ,.inport_data1_i(transpose_data1_w)
    ,.inport_data2_i(transpose_data2_w)
    ,.inport_data3_i(transpose_data3_w)
    ,.inport_idx_i(transpose_idx_w)

    ,.outport_valid_o(outport_valid_o)
    ,.outport_data_o(outport_data_o)
    ,.outport_idx_o(outport_idx_o)
);


jpeg_idct_fifo
#(
     .WIDTH(32)
    ,.DEPTH(8)
    ,.ADDR_W(3)
)
u_id_fifo
(
     .clk_i(clk_i)
    ,.rst_i(rst_i)

    ,.flush_i(img_start_i)

    ,.push_i(inport_eob_i)
    ,.data_in_i(inport_id_i)
    ,.accept_o()

    ,.valid_o()
    ,.data_out_o(outport_id_o)
    ,.pop_i(outport_valid_o && outport_idx_o == 6'd63)
);

`ifdef verilator
function get_valid; /*verilator public*/
begin
    get_valid = outport_valid_o;
end
endfunction
function [5:0] get_sample_idx; /*verilator public*/
begin
    get_sample_idx = outport_idx_o;
end
endfunction
function [31:0] get_sample; /*verilator public*/
begin
    get_sample = outport_data_o;
end
endfunction
`endif


endmodule
