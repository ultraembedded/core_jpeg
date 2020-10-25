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

module jpeg_bitbuffer
(
    // Inputs
     input           clk_i
    ,input           rst_i
    ,input           img_start_i
    ,input           img_end_i
    ,input           inport_valid_i
    ,input  [  7:0]  inport_data_i
    ,input           inport_last_i
    ,input  [  5:0]  outport_pop_i

    // Outputs
    ,output          inport_accept_o
    ,output          outport_valid_o
    ,output [ 31:0]  outport_data_o
    ,output          outport_last_o
);



//-----------------------------------------------------------------
// Registers
//-----------------------------------------------------------------
reg [7:0] ram_q[7:0];
reg [5:0] rd_ptr_q;
reg [5:0] wr_ptr_q;
reg [6:0] count_q;
reg       drain_q;

//-----------------------------------------------------------------
// Input side FIFO
//-----------------------------------------------------------------
reg [6:0] count_r; 
always @ *
begin
    count_r = count_q;

    // Count up
    if (inport_valid_i && inport_accept_o)
        count_r = count_r + 7'd8;

    // Count down
    if (outport_valid_o && (|outport_pop_i))
        count_r = count_r - outport_pop_i;
end

always @ (posedge clk_i )
if (rst_i)
begin
    count_q   <= 7'b0;
    rd_ptr_q  <= 6'b0;
    wr_ptr_q  <= 6'b0;
    drain_q   <= 1'b0;
end
else if (img_start_i)
begin
    count_q   <= 7'b0;
    rd_ptr_q  <= 6'b0;
    wr_ptr_q  <= 6'b0;
    drain_q   <= 1'b0;
end
else
begin
    // End of image
    if (inport_last_i)
        drain_q <= 1'b1;

    // Push
    if (inport_valid_i && inport_accept_o)
    begin
        ram_q[wr_ptr_q[5:3]] <= inport_data_i;
        wr_ptr_q             <= wr_ptr_q + 6'd8;
    end

    // Pop
    if (outport_valid_o && (|outport_pop_i))
        rd_ptr_q <= rd_ptr_q + outport_pop_i;

    count_q <= count_r;
end

assign inport_accept_o = (count_q <= 7'd56);

//-------------------------------------------------------------------
// Output side FIFO
//-------------------------------------------------------------------
reg [39:0] fifo_data_r;

always @ *
begin
    fifo_data_r = 40'b0;

    case (rd_ptr_q[5:3])
    3'd0: fifo_data_r = {ram_q[0], ram_q[1], ram_q[2], ram_q[3], ram_q[4]};
    3'd1: fifo_data_r = {ram_q[1], ram_q[2], ram_q[3], ram_q[4], ram_q[5]};
    3'd2: fifo_data_r = {ram_q[2], ram_q[3], ram_q[4], ram_q[5], ram_q[6]};
    3'd3: fifo_data_r = {ram_q[3], ram_q[4], ram_q[5], ram_q[6], ram_q[7]};
    3'd4: fifo_data_r = {ram_q[4], ram_q[5], ram_q[6], ram_q[7], ram_q[0]};
    3'd5: fifo_data_r = {ram_q[5], ram_q[6], ram_q[7], ram_q[0], ram_q[1]};
    3'd6: fifo_data_r = {ram_q[6], ram_q[7], ram_q[0], ram_q[1], ram_q[2]};
    3'd7: fifo_data_r = {ram_q[7], ram_q[0], ram_q[1], ram_q[2], ram_q[3]};
    endcase
end

wire [39:0] data_shifted_w = fifo_data_r << rd_ptr_q[2:0];

assign outport_valid_o  = (count_q >= 7'd32) || (drain_q && count_q != 7'd0);
assign outport_data_o   = data_shifted_w[39:8];
assign outport_last_o   = 1'b0;


`ifdef verilator
function get_valid; /*verilator public*/
begin
    get_valid = inport_valid_i && inport_accept_o;
end
endfunction
function [7:0] get_data; /*verilator public*/
begin
    get_data = inport_data_i;
end
endfunction
`endif




endmodule
