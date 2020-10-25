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
module jpeg_dht_std_cx_ac
(
     input  [ 15:0]  lookup_input_i
    ,output [  4:0]  lookup_width_o
    ,output [  7:0]  lookup_value_o
);

//-----------------------------------------------------------------
// Cx AC Table (standard)
//-----------------------------------------------------------------
reg [7:0] cx_ac_value_r;
reg [4:0] cx_ac_width_r;

always @ *
begin
    cx_ac_value_r = 8'b0;
    cx_ac_width_r = 5'b0;

    if (lookup_input_i[15:14] == 2'h0)
    begin
         cx_ac_value_r = 8'h00;
         cx_ac_width_r = 5'd2;
    end
    else if (lookup_input_i[15:14] == 2'h1)
    begin
         cx_ac_value_r = 8'h01;
         cx_ac_width_r = 5'd2;
    end
    else if (lookup_input_i[15:13] == 3'h4)
    begin
         cx_ac_value_r = 8'h02;
         cx_ac_width_r = 5'd3;
    end
    else if (lookup_input_i[15:12] == 4'ha)
    begin
         cx_ac_value_r = 8'h03;
         cx_ac_width_r = 5'd4;
    end
    else if (lookup_input_i[15:12] == 4'hb)
    begin
         cx_ac_value_r = 8'h11;
         cx_ac_width_r = 5'd4;
    end
    else if (lookup_input_i[15:11] == 5'h18)
    begin
         cx_ac_value_r = 8'h04;
         cx_ac_width_r = 5'd5;
    end
    else if (lookup_input_i[15:11] == 5'h19)
    begin
         cx_ac_value_r = 8'h05;
         cx_ac_width_r = 5'd5;
    end
    else if (lookup_input_i[15:11] == 5'h1a)
    begin
         cx_ac_value_r = 8'h21;
         cx_ac_width_r = 5'd5;
    end
    else if (lookup_input_i[15:11] == 5'h1b)
    begin
         cx_ac_value_r = 8'h31;
         cx_ac_width_r = 5'd5;
    end
    else if (lookup_input_i[15:10] == 6'h38)
    begin
         cx_ac_value_r = 8'h06;
         cx_ac_width_r = 5'd6;
    end
    else if (lookup_input_i[15:10] == 6'h39)
    begin
         cx_ac_value_r = 8'h12;
         cx_ac_width_r = 5'd6;
    end
    else if (lookup_input_i[15:10] == 6'h3a)
    begin
         cx_ac_value_r = 8'h41;
         cx_ac_width_r = 5'd6;
    end
    else if (lookup_input_i[15:10] == 6'h3b)
    begin
         cx_ac_value_r = 8'h51;
         cx_ac_width_r = 5'd6;
    end
    else if (lookup_input_i[15:9] == 7'h78)
    begin
         cx_ac_value_r = 8'h07;
         cx_ac_width_r = 5'd7;
    end
    else if (lookup_input_i[15:9] == 7'h79)
    begin
         cx_ac_value_r = 8'h61;
         cx_ac_width_r = 5'd7;
    end
    else if (lookup_input_i[15:9] == 7'h7a)
    begin
         cx_ac_value_r = 8'h71;
         cx_ac_width_r = 5'd7;
    end
    else if (lookup_input_i[15:8] == 8'hf6)
    begin
         cx_ac_value_r = 8'h13;
         cx_ac_width_r = 5'd8;
    end
    else if (lookup_input_i[15:8] == 8'hf7)
    begin
         cx_ac_value_r = 8'h22;
         cx_ac_width_r = 5'd8;
    end
    else if (lookup_input_i[15:8] == 8'hf8)
    begin
         cx_ac_value_r = 8'h32;
         cx_ac_width_r = 5'd8;
    end
    else if (lookup_input_i[15:8] == 8'hf9)
    begin
         cx_ac_value_r = 8'h81;
         cx_ac_width_r = 5'd8;
    end
    else if (lookup_input_i[15:7] == 9'h1f4)
    begin
         cx_ac_value_r = 8'h08;
         cx_ac_width_r = 5'd9;
    end
    else if (lookup_input_i[15:7] == 9'h1f5)
    begin
         cx_ac_value_r = 8'h14;
         cx_ac_width_r = 5'd9;
    end
    else if (lookup_input_i[15:7] == 9'h1f6)
    begin
         cx_ac_value_r = 8'h42;
         cx_ac_width_r = 5'd9;
    end
    else if (lookup_input_i[15:7] == 9'h1f7)
    begin
         cx_ac_value_r = 8'h91;
         cx_ac_width_r = 5'd9;
    end
    else if (lookup_input_i[15:7] == 9'h1f8)
    begin
         cx_ac_value_r = 8'ha1;
         cx_ac_width_r = 5'd9;
    end
    else if (lookup_input_i[15:7] == 9'h1f9)
    begin
         cx_ac_value_r = 8'hb1;
         cx_ac_width_r = 5'd9;
    end
    else if (lookup_input_i[15:7] == 9'h1fa)
    begin
         cx_ac_value_r = 8'hc1;
         cx_ac_width_r = 5'd9;
    end
    else if (lookup_input_i[15:6] == 10'h3f6)
    begin
         cx_ac_value_r = 8'h09;
         cx_ac_width_r = 5'd10;
    end
    else if (lookup_input_i[15:6] == 10'h3f7)
    begin
         cx_ac_value_r = 8'h23;
         cx_ac_width_r = 5'd10;
    end
    else if (lookup_input_i[15:6] == 10'h3f8)
    begin
         cx_ac_value_r = 8'h33;
         cx_ac_width_r = 5'd10;
    end
    else if (lookup_input_i[15:6] == 10'h3f9)
    begin
         cx_ac_value_r = 8'h52;
         cx_ac_width_r = 5'd10;
    end
    else if (lookup_input_i[15:6] == 10'h3fa)
    begin
         cx_ac_value_r = 8'hf0;
         cx_ac_width_r = 5'd10;
    end
    else if (lookup_input_i[15:5] == 11'h7f6)
    begin
         cx_ac_value_r = 8'h15;
         cx_ac_width_r = 5'd11;
    end
    else if (lookup_input_i[15:5] == 11'h7f7)
    begin
         cx_ac_value_r = 8'h62;
         cx_ac_width_r = 5'd11;
    end
    else if (lookup_input_i[15:5] == 11'h7f8)
    begin
         cx_ac_value_r = 8'h72;
         cx_ac_width_r = 5'd11;
    end
    else if (lookup_input_i[15:5] == 11'h7f9)
    begin
         cx_ac_value_r = 8'hd1;
         cx_ac_width_r = 5'd11;
    end
    else if (lookup_input_i[15:4] == 12'hff4)
    begin
         cx_ac_value_r = 8'h0a;
         cx_ac_width_r = 5'd12;
    end
    else if (lookup_input_i[15:4] == 12'hff5)
    begin
         cx_ac_value_r = 8'h16;
         cx_ac_width_r = 5'd12;
    end
    else if (lookup_input_i[15:4] == 12'hff6)
    begin
         cx_ac_value_r = 8'h24;
         cx_ac_width_r = 5'd12;
    end
    else if (lookup_input_i[15:4] == 12'hff7)
    begin
         cx_ac_value_r = 8'h34;
         cx_ac_width_r = 5'd12;
    end
    else if (lookup_input_i[15:2] == 14'h3fe0)
    begin
         cx_ac_value_r = 8'he1;
         cx_ac_width_r = 5'd14;
    end
    else if (lookup_input_i[15:1] == 15'h7fc2)
    begin
         cx_ac_value_r = 8'h25;
         cx_ac_width_r = 5'd15;
    end
    else if (lookup_input_i[15:1] == 15'h7fc3)
    begin
         cx_ac_value_r = 8'hf1;
         cx_ac_width_r = 5'd15;
    end
    else if (lookup_input_i[15:0] == 16'hff88)
    begin
         cx_ac_value_r = 8'h17;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff89)
    begin
         cx_ac_value_r = 8'h18;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff8a)
    begin
         cx_ac_value_r = 8'h19;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff8b)
    begin
         cx_ac_value_r = 8'h1a;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff8c)
    begin
         cx_ac_value_r = 8'h26;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff8d)
    begin
         cx_ac_value_r = 8'h27;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff8e)
    begin
         cx_ac_value_r = 8'h28;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff8f)
    begin
         cx_ac_value_r = 8'h29;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff90)
    begin
         cx_ac_value_r = 8'h2a;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff91)
    begin
         cx_ac_value_r = 8'h35;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff92)
    begin
         cx_ac_value_r = 8'h36;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff93)
    begin
         cx_ac_value_r = 8'h37;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff94)
    begin
         cx_ac_value_r = 8'h38;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff95)
    begin
         cx_ac_value_r = 8'h39;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff96)
    begin
         cx_ac_value_r = 8'h3a;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff97)
    begin
         cx_ac_value_r = 8'h43;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff98)
    begin
         cx_ac_value_r = 8'h44;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff99)
    begin
         cx_ac_value_r = 8'h45;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff9a)
    begin
         cx_ac_value_r = 8'h46;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff9b)
    begin
         cx_ac_value_r = 8'h47;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff9c)
    begin
         cx_ac_value_r = 8'h48;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff9d)
    begin
         cx_ac_value_r = 8'h49;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff9e)
    begin
         cx_ac_value_r = 8'h4a;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff9f)
    begin
         cx_ac_value_r = 8'h53;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffa0)
    begin
         cx_ac_value_r = 8'h54;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffa1)
    begin
         cx_ac_value_r = 8'h55;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffa2)
    begin
         cx_ac_value_r = 8'h56;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffa3)
    begin
         cx_ac_value_r = 8'h57;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffa4)
    begin
         cx_ac_value_r = 8'h58;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffa5)
    begin
         cx_ac_value_r = 8'h59;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffa6)
    begin
         cx_ac_value_r = 8'h5a;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffa7)
    begin
         cx_ac_value_r = 8'h63;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffa8)
    begin
         cx_ac_value_r = 8'h64;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffa9)
    begin
         cx_ac_value_r = 8'h65;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffaa)
    begin
         cx_ac_value_r = 8'h66;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffab)
    begin
         cx_ac_value_r = 8'h67;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffac)
    begin
         cx_ac_value_r = 8'h68;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffad)
    begin
         cx_ac_value_r = 8'h69;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffae)
    begin
         cx_ac_value_r = 8'h6a;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffaf)
    begin
         cx_ac_value_r = 8'h73;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffb0)
    begin
         cx_ac_value_r = 8'h74;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffb1)
    begin
         cx_ac_value_r = 8'h75;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffb2)
    begin
         cx_ac_value_r = 8'h76;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffb3)
    begin
         cx_ac_value_r = 8'h77;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffb4)
    begin
         cx_ac_value_r = 8'h78;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffb5)
    begin
         cx_ac_value_r = 8'h79;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffb6)
    begin
         cx_ac_value_r = 8'h7a;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffb7)
    begin
         cx_ac_value_r = 8'h82;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffb8)
    begin
         cx_ac_value_r = 8'h83;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffb9)
    begin
         cx_ac_value_r = 8'h84;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffba)
    begin
         cx_ac_value_r = 8'h85;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffbb)
    begin
         cx_ac_value_r = 8'h86;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffbc)
    begin
         cx_ac_value_r = 8'h87;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffbd)
    begin
         cx_ac_value_r = 8'h88;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffbe)
    begin
         cx_ac_value_r = 8'h89;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffbf)
    begin
         cx_ac_value_r = 8'h8a;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffc0)
    begin
         cx_ac_value_r = 8'h92;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffc1)
    begin
         cx_ac_value_r = 8'h93;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffc2)
    begin
         cx_ac_value_r = 8'h94;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffc3)
    begin
         cx_ac_value_r = 8'h95;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffc4)
    begin
         cx_ac_value_r = 8'h96;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffc5)
    begin
         cx_ac_value_r = 8'h97;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffc6)
    begin
         cx_ac_value_r = 8'h98;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffc7)
    begin
         cx_ac_value_r = 8'h99;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffc8)
    begin
         cx_ac_value_r = 8'h9a;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffc9)
    begin
         cx_ac_value_r = 8'ha2;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffca)
    begin
         cx_ac_value_r = 8'ha3;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffcb)
    begin
         cx_ac_value_r = 8'ha4;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffcc)
    begin
         cx_ac_value_r = 8'ha5;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffcd)
    begin
         cx_ac_value_r = 8'ha6;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffce)
    begin
         cx_ac_value_r = 8'ha7;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffcf)
    begin
         cx_ac_value_r = 8'ha8;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffd0)
    begin
         cx_ac_value_r = 8'ha9;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffd1)
    begin
         cx_ac_value_r = 8'haa;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffd2)
    begin
         cx_ac_value_r = 8'hb2;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffd3)
    begin
         cx_ac_value_r = 8'hb3;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffd4)
    begin
         cx_ac_value_r = 8'hb4;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffd5)
    begin
         cx_ac_value_r = 8'hb5;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffd6)
    begin
         cx_ac_value_r = 8'hb6;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffd7)
    begin
         cx_ac_value_r = 8'hb7;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffd8)
    begin
         cx_ac_value_r = 8'hb8;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffd9)
    begin
         cx_ac_value_r = 8'hb9;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffda)
    begin
         cx_ac_value_r = 8'hba;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffdb)
    begin
         cx_ac_value_r = 8'hc2;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffdc)
    begin
         cx_ac_value_r = 8'hc3;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffdd)
    begin
         cx_ac_value_r = 8'hc4;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffde)
    begin
         cx_ac_value_r = 8'hc5;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffdf)
    begin
         cx_ac_value_r = 8'hc6;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffe0)
    begin
         cx_ac_value_r = 8'hc7;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffe1)
    begin
         cx_ac_value_r = 8'hc8;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffe2)
    begin
         cx_ac_value_r = 8'hc9;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffe3)
    begin
         cx_ac_value_r = 8'hca;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffe4)
    begin
         cx_ac_value_r = 8'hd2;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffe5)
    begin
         cx_ac_value_r = 8'hd3;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffe6)
    begin
         cx_ac_value_r = 8'hd4;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffe7)
    begin
         cx_ac_value_r = 8'hd5;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffe8)
    begin
         cx_ac_value_r = 8'hd6;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffe9)
    begin
         cx_ac_value_r = 8'hd7;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffea)
    begin
         cx_ac_value_r = 8'hd8;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffeb)
    begin
         cx_ac_value_r = 8'hd9;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffec)
    begin
         cx_ac_value_r = 8'hda;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffed)
    begin
         cx_ac_value_r = 8'he2;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffee)
    begin
         cx_ac_value_r = 8'he3;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffef)
    begin
         cx_ac_value_r = 8'he4;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hfff0)
    begin
         cx_ac_value_r = 8'he5;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hfff1)
    begin
         cx_ac_value_r = 8'he6;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hfff2)
    begin
         cx_ac_value_r = 8'he7;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hfff3)
    begin
         cx_ac_value_r = 8'he8;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hfff4)
    begin
         cx_ac_value_r = 8'he9;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hfff5)
    begin
         cx_ac_value_r = 8'hea;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hfff6)
    begin
         cx_ac_value_r = 8'hf2;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hfff7)
    begin
         cx_ac_value_r = 8'hf3;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hfff8)
    begin
         cx_ac_value_r = 8'hf4;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hfff9)
    begin
         cx_ac_value_r = 8'hf5;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hfffa)
    begin
         cx_ac_value_r = 8'hf6;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hfffb)
    begin
         cx_ac_value_r = 8'hf7;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hfffc)
    begin
         cx_ac_value_r = 8'hf8;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hfffd)
    begin
         cx_ac_value_r = 8'hf9;
         cx_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hfffe)
    begin
         cx_ac_value_r = 8'hfa;
         cx_ac_width_r = 5'd16;
    end
end

assign lookup_width_o = cx_ac_width_r;
assign lookup_value_o = cx_ac_value_r;

endmodule
