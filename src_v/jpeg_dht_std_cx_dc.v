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
module jpeg_dht_std_cx_dc
(
     input  [ 15:0]  lookup_input_i
    ,output [  4:0]  lookup_width_o
    ,output [  7:0]  lookup_value_o
);

//-----------------------------------------------------------------
// Cx DC Table (standard)
//-----------------------------------------------------------------
reg [7:0] cx_dc_value_r;
reg [4:0] cx_dc_width_r;

always @ *
begin
    cx_dc_value_r = 8'b0;
    cx_dc_width_r = 5'b0;

    if (lookup_input_i[15:14] == 2'h0)
    begin
         cx_dc_value_r = 8'h00;
         cx_dc_width_r = 5'd2;
    end
    else if (lookup_input_i[15:14] == 2'h1)
    begin
         cx_dc_value_r = 8'h01;
         cx_dc_width_r = 5'd2;
    end
    else if (lookup_input_i[15:14] == 2'h2)
    begin
         cx_dc_value_r = 8'h02;
         cx_dc_width_r = 5'd2;
    end
    else if (lookup_input_i[15:13] == 3'h6)
    begin
         cx_dc_value_r = 8'h03;
         cx_dc_width_r = 5'd3;
    end
    else if (lookup_input_i[15:12] == 4'he)
    begin
         cx_dc_value_r = 8'h04;
         cx_dc_width_r = 5'd4;
    end
    else if (lookup_input_i[15:11] == 5'h1e)
    begin
         cx_dc_value_r = 8'h05;
         cx_dc_width_r = 5'd5;
    end
    else if (lookup_input_i[15:10] == 6'h3e)
    begin
         cx_dc_value_r = 8'h06;
         cx_dc_width_r = 5'd6;
    end
    else if (lookup_input_i[15:9] == 7'h7e)
    begin
         cx_dc_value_r = 8'h07;
         cx_dc_width_r = 5'd7;
    end
    else if (lookup_input_i[15:8] == 8'hfe)
    begin
         cx_dc_value_r = 8'h08;
         cx_dc_width_r = 5'd8;
    end
    else if (lookup_input_i[15:7] == 9'h1fe)
    begin
         cx_dc_value_r = 8'h09;
         cx_dc_width_r = 5'd9;
    end
    else if (lookup_input_i[15:6] == 10'h3fe)
    begin
         cx_dc_value_r = 8'h0a;
         cx_dc_width_r = 5'd10;
    end
    else if (lookup_input_i[15:5] == 11'h7fe)
    begin
         cx_dc_value_r = 8'h0b;
         cx_dc_width_r = 5'd11;
    end
end

assign lookup_width_o = cx_dc_width_r;
assign lookup_value_o = cx_dc_value_r;

endmodule

