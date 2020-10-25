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
module jpeg_dht_std_y_ac
(
     input  [ 15:0]  lookup_input_i
    ,output [  4:0]  lookup_width_o
    ,output [  7:0]  lookup_value_o
);

//-----------------------------------------------------------------
// Y AC Table (standard)
//-----------------------------------------------------------------
reg [7:0] y_ac_value_r;
reg [4:0] y_ac_width_r;

always @ *
begin
    y_ac_value_r = 8'b0;
    y_ac_width_r = 5'b0;

    if (lookup_input_i[15:14] == 2'h0)
    begin
         y_ac_value_r = 8'h01;
         y_ac_width_r = 5'd2;
    end
    else if (lookup_input_i[15:14] == 2'h1)
    begin
         y_ac_value_r = 8'h02;
         y_ac_width_r = 5'd2;
    end
    else if (lookup_input_i[15:13] == 3'h4)
    begin
         y_ac_value_r = 8'h03;
         y_ac_width_r = 5'd3;
    end
    else if (lookup_input_i[15:12] == 4'ha)
    begin
         y_ac_value_r = 8'h00;
         y_ac_width_r = 5'd4;
    end
    else if (lookup_input_i[15:12] == 4'hb)
    begin
         y_ac_value_r = 8'h04;
         y_ac_width_r = 5'd4;
    end
    else if (lookup_input_i[15:12] == 4'hc)
    begin
         y_ac_value_r = 8'h11;
         y_ac_width_r = 5'd4;
    end
    else if (lookup_input_i[15:11] == 5'h1a)
    begin
         y_ac_value_r = 8'h05;
         y_ac_width_r = 5'd5;
    end
    else if (lookup_input_i[15:11] == 5'h1b)
    begin
         y_ac_value_r = 8'h12;
         y_ac_width_r = 5'd5;
    end
    else if (lookup_input_i[15:11] == 5'h1c)
    begin
         y_ac_value_r = 8'h21;
         y_ac_width_r = 5'd5;
    end
    else if (lookup_input_i[15:10] == 6'h3a)
    begin
         y_ac_value_r = 8'h31;
         y_ac_width_r = 5'd6;
    end
    else if (lookup_input_i[15:10] == 6'h3b)
    begin
         y_ac_value_r = 8'h41;
         y_ac_width_r = 5'd6;
    end
    else if (lookup_input_i[15:9] == 7'h78)
    begin
         y_ac_value_r = 8'h06;
         y_ac_width_r = 5'd7;
    end
    else if (lookup_input_i[15:9] == 7'h79)
    begin
         y_ac_value_r = 8'h13;
         y_ac_width_r = 5'd7;
    end
    else if (lookup_input_i[15:9] == 7'h7a)
    begin
         y_ac_value_r = 8'h51;
         y_ac_width_r = 5'd7;
    end
    else if (lookup_input_i[15:9] == 7'h7b)
    begin
         y_ac_value_r = 8'h61;
         y_ac_width_r = 5'd7;
    end
    else if (lookup_input_i[15:8] == 8'hf8)
    begin
         y_ac_value_r = 8'h07;
         y_ac_width_r = 5'd8;
    end
    else if (lookup_input_i[15:8] == 8'hf9)
    begin
         y_ac_value_r = 8'h22;
         y_ac_width_r = 5'd8;
    end
    else if (lookup_input_i[15:8] == 8'hfa)
    begin
         y_ac_value_r = 8'h71;
         y_ac_width_r = 5'd8;
    end
    else if (lookup_input_i[15:7] == 9'h1f6)
    begin
         y_ac_value_r = 8'h14;
         y_ac_width_r = 5'd9;
    end
    else if (lookup_input_i[15:7] == 9'h1f7)
    begin
         y_ac_value_r = 8'h32;
         y_ac_width_r = 5'd9;
    end
    else if (lookup_input_i[15:7] == 9'h1f8)
    begin
         y_ac_value_r = 8'h81;
         y_ac_width_r = 5'd9;
    end
    else if (lookup_input_i[15:7] == 9'h1f9)
    begin
         y_ac_value_r = 8'h91;
         y_ac_width_r = 5'd9;
    end
    else if (lookup_input_i[15:7] == 9'h1fa)
    begin
         y_ac_value_r = 8'ha1;
         y_ac_width_r = 5'd9;
    end
    else if (lookup_input_i[15:6] == 10'h3f6)
    begin
         y_ac_value_r = 8'h08;
         y_ac_width_r = 5'd10;
    end
    else if (lookup_input_i[15:6] == 10'h3f7)
    begin
         y_ac_value_r = 8'h23;
         y_ac_width_r = 5'd10;
    end
    else if (lookup_input_i[15:6] == 10'h3f8)
    begin
         y_ac_value_r = 8'h42;
         y_ac_width_r = 5'd10;
    end
    else if (lookup_input_i[15:6] == 10'h3f9)
    begin
         y_ac_value_r = 8'hb1;
         y_ac_width_r = 5'd10;
    end
    else if (lookup_input_i[15:6] == 10'h3fa)
    begin
         y_ac_value_r = 8'hc1;
         y_ac_width_r = 5'd10;
    end
    else if (lookup_input_i[15:5] == 11'h7f6)
    begin
         y_ac_value_r = 8'h15;
         y_ac_width_r = 5'd11;
    end
    else if (lookup_input_i[15:5] == 11'h7f7)
    begin
         y_ac_value_r = 8'h52;
         y_ac_width_r = 5'd11;
    end
    else if (lookup_input_i[15:5] == 11'h7f8)
    begin
         y_ac_value_r = 8'hd1;
         y_ac_width_r = 5'd11;
    end
    else if (lookup_input_i[15:5] == 11'h7f9)
    begin
         y_ac_value_r = 8'hf0;
         y_ac_width_r = 5'd11;
    end
    else if (lookup_input_i[15:4] == 12'hff4)
    begin
         y_ac_value_r = 8'h24;
         y_ac_width_r = 5'd12;
    end
    else if (lookup_input_i[15:4] == 12'hff5)
    begin
         y_ac_value_r = 8'h33;
         y_ac_width_r = 5'd12;
    end
    else if (lookup_input_i[15:4] == 12'hff6)
    begin
         y_ac_value_r = 8'h62;
         y_ac_width_r = 5'd12;
    end
    else if (lookup_input_i[15:4] == 12'hff7)
    begin
         y_ac_value_r = 8'h72;
         y_ac_width_r = 5'd12;
    end
    else if (lookup_input_i[15:1] == 15'h7fc0)
    begin
         y_ac_value_r = 8'h82;
         y_ac_width_r = 5'd15;
    end
    else if (lookup_input_i[15:0] == 16'hff82)
    begin
         y_ac_value_r = 8'h09;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff83)
    begin
         y_ac_value_r = 8'h0a;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff84)
    begin
         y_ac_value_r = 8'h16;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff85)
    begin
         y_ac_value_r = 8'h17;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff86)
    begin
         y_ac_value_r = 8'h18;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff87)
    begin
         y_ac_value_r = 8'h19;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff88)
    begin
         y_ac_value_r = 8'h1a;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff89)
    begin
         y_ac_value_r = 8'h25;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff8a)
    begin
         y_ac_value_r = 8'h26;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff8b)
    begin
         y_ac_value_r = 8'h27;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff8c)
    begin
         y_ac_value_r = 8'h28;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff8d)
    begin
         y_ac_value_r = 8'h29;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff8e)
    begin
         y_ac_value_r = 8'h2a;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff8f)
    begin
         y_ac_value_r = 8'h34;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff90)
    begin
         y_ac_value_r = 8'h35;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff91)
    begin
         y_ac_value_r = 8'h36;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff92)
    begin
         y_ac_value_r = 8'h37;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff93)
    begin
         y_ac_value_r = 8'h38;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff94)
    begin
         y_ac_value_r = 8'h39;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff95)
    begin
         y_ac_value_r = 8'h3a;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff96)
    begin
         y_ac_value_r = 8'h43;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff97)
    begin
         y_ac_value_r = 8'h44;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff98)
    begin
         y_ac_value_r = 8'h45;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff99)
    begin
         y_ac_value_r = 8'h46;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff9a)
    begin
         y_ac_value_r = 8'h47;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff9b)
    begin
         y_ac_value_r = 8'h48;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff9c)
    begin
         y_ac_value_r = 8'h49;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff9d)
    begin
         y_ac_value_r = 8'h4a;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff9e)
    begin
         y_ac_value_r = 8'h53;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hff9f)
    begin
         y_ac_value_r = 8'h54;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffa0)
    begin
         y_ac_value_r = 8'h55;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffa1)
    begin
         y_ac_value_r = 8'h56;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffa2)
    begin
         y_ac_value_r = 8'h57;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffa3)
    begin
         y_ac_value_r = 8'h58;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffa4)
    begin
         y_ac_value_r = 8'h59;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffa5)
    begin
         y_ac_value_r = 8'h5a;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffa6)
    begin
         y_ac_value_r = 8'h63;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffa7)
    begin
         y_ac_value_r = 8'h64;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffa8)
    begin
         y_ac_value_r = 8'h65;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffa9)
    begin
         y_ac_value_r = 8'h66;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffaa)
    begin
         y_ac_value_r = 8'h67;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffab)
    begin
         y_ac_value_r = 8'h68;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffac)
    begin
         y_ac_value_r = 8'h69;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffad)
    begin
         y_ac_value_r = 8'h6a;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffae)
    begin
         y_ac_value_r = 8'h73;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffaf)
    begin
         y_ac_value_r = 8'h74;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffb0)
    begin
         y_ac_value_r = 8'h75;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffb1)
    begin
         y_ac_value_r = 8'h76;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffb2)
    begin
         y_ac_value_r = 8'h77;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffb3)
    begin
         y_ac_value_r = 8'h78;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffb4)
    begin
         y_ac_value_r = 8'h79;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffb5)
    begin
         y_ac_value_r = 8'h7a;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffb6)
    begin
         y_ac_value_r = 8'h83;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffb7)
    begin
         y_ac_value_r = 8'h84;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffb8)
    begin
         y_ac_value_r = 8'h85;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffb9)
    begin
         y_ac_value_r = 8'h86;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffba)
    begin
         y_ac_value_r = 8'h87;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffbb)
    begin
         y_ac_value_r = 8'h88;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffbc)
    begin
         y_ac_value_r = 8'h89;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffbd)
    begin
         y_ac_value_r = 8'h8a;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffbe)
    begin
         y_ac_value_r = 8'h92;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffbf)
    begin
         y_ac_value_r = 8'h93;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffc0)
    begin
         y_ac_value_r = 8'h94;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffc1)
    begin
         y_ac_value_r = 8'h95;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffc2)
    begin
         y_ac_value_r = 8'h96;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffc3)
    begin
         y_ac_value_r = 8'h97;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffc4)
    begin
         y_ac_value_r = 8'h98;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffc5)
    begin
         y_ac_value_r = 8'h99;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffc6)
    begin
         y_ac_value_r = 8'h9a;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffc7)
    begin
         y_ac_value_r = 8'ha2;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffc8)
    begin
         y_ac_value_r = 8'ha3;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffc9)
    begin
         y_ac_value_r = 8'ha4;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffca)
    begin
         y_ac_value_r = 8'ha5;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffcb)
    begin
         y_ac_value_r = 8'ha6;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffcc)
    begin
         y_ac_value_r = 8'ha7;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffcd)
    begin
         y_ac_value_r = 8'ha8;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffce)
    begin
         y_ac_value_r = 8'ha9;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffcf)
    begin
         y_ac_value_r = 8'haa;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffd0)
    begin
         y_ac_value_r = 8'hb2;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffd1)
    begin
         y_ac_value_r = 8'hb3;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffd2)
    begin
         y_ac_value_r = 8'hb4;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffd3)
    begin
         y_ac_value_r = 8'hb5;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffd4)
    begin
         y_ac_value_r = 8'hb6;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffd5)
    begin
         y_ac_value_r = 8'hb7;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffd6)
    begin
         y_ac_value_r = 8'hb8;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffd7)
    begin
         y_ac_value_r = 8'hb9;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffd8)
    begin
         y_ac_value_r = 8'hba;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffd9)
    begin
         y_ac_value_r = 8'hc2;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffda)
    begin
         y_ac_value_r = 8'hc3;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffdb)
    begin
         y_ac_value_r = 8'hc4;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffdc)
    begin
         y_ac_value_r = 8'hc5;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffdd)
    begin
         y_ac_value_r = 8'hc6;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffde)
    begin
         y_ac_value_r = 8'hc7;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffdf)
    begin
         y_ac_value_r = 8'hc8;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffe0)
    begin
         y_ac_value_r = 8'hc9;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffe1)
    begin
         y_ac_value_r = 8'hca;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffe2)
    begin
         y_ac_value_r = 8'hd2;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffe3)
    begin
         y_ac_value_r = 8'hd3;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffe4)
    begin
         y_ac_value_r = 8'hd4;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffe5)
    begin
         y_ac_value_r = 8'hd5;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffe6)
    begin
         y_ac_value_r = 8'hd6;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffe7)
    begin
         y_ac_value_r = 8'hd7;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffe8)
    begin
         y_ac_value_r = 8'hd8;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffe9)
    begin
         y_ac_value_r = 8'hd9;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffea)
    begin
         y_ac_value_r = 8'hda;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffeb)
    begin
         y_ac_value_r = 8'he1;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffec)
    begin
         y_ac_value_r = 8'he2;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffed)
    begin
         y_ac_value_r = 8'he3;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffee)
    begin
         y_ac_value_r = 8'he4;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hffef)
    begin
         y_ac_value_r = 8'he5;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hfff0)
    begin
         y_ac_value_r = 8'he6;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hfff1)
    begin
         y_ac_value_r = 8'he7;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hfff2)
    begin
         y_ac_value_r = 8'he8;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hfff3)
    begin
         y_ac_value_r = 8'he9;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hfff4)
    begin
         y_ac_value_r = 8'hea;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hfff5)
    begin
         y_ac_value_r = 8'hf1;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hfff6)
    begin
         y_ac_value_r = 8'hf2;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hfff7)
    begin
         y_ac_value_r = 8'hf3;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hfff8)
    begin
         y_ac_value_r = 8'hf4;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hfff9)
    begin
         y_ac_value_r = 8'hf5;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hfffa)
    begin
         y_ac_value_r = 8'hf6;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hfffb)
    begin
         y_ac_value_r = 8'hf7;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hfffc)
    begin
         y_ac_value_r = 8'hf8;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hfffd)
    begin
         y_ac_value_r = 8'hf9;
         y_ac_width_r = 5'd16;
    end
    else if (lookup_input_i[15:0] == 16'hfffe)
    begin
         y_ac_value_r = 8'hfa;
         y_ac_width_r = 5'd16;
    end
end

assign lookup_width_o = y_ac_width_r;
assign lookup_value_o = y_ac_value_r;

endmodule
