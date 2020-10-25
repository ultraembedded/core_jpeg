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

module jpeg_output_cx_ram
(
    // Inputs
     input           clk_i
    ,input           rst_i
    ,input  [  5:0]  wr_idx_i
    ,input  [ 31:0]  data_in_i
    ,input           push_i
    ,input           mode420_i
    ,input           pop_i
    ,input           flush_i

    // Outputs
    ,output [ 31:0]  data_out_o
    ,output          valid_o
    ,output [ 31:0]  level_o
);



//-----------------------------------------------------------------
// Registers
//-----------------------------------------------------------------
reg [7:0]   rd_ptr_q;
reg [7:0]   wr_ptr_q;

//-----------------------------------------------------------------
// Write Side
//-----------------------------------------------------------------
wire [7:0] write_next_w = wr_ptr_q + 8'd1;

always @ (posedge clk_i )
if (rst_i)
    wr_ptr_q <= 8'b0;
else if (flush_i)
    wr_ptr_q <= 8'b0;
// Push
else if (push_i)
    wr_ptr_q <= write_next_w;

//-----------------------------------------------------------------
// Read Side
//-----------------------------------------------------------------
wire read_ok_w = (level_o > 32'd1);
reg  rd_q;

always @ (posedge clk_i )
if (rst_i)
    rd_q <= 1'b0;
else if (flush_i)
    rd_q <= 1'b0;
else
    rd_q <= read_ok_w;

wire [7:0] rd_ptr_next_w = rd_ptr_q + 8'd1;

always @ (posedge clk_i )
if (rst_i)
    rd_ptr_q <= 8'b0;
else if (flush_i)
    rd_ptr_q <= 8'b0;
else if (read_ok_w && ((!valid_o) || (valid_o && pop_i)))
    rd_ptr_q <= rd_ptr_next_w;

//-------------------------------------------------------------------
// Chroma subsampling (420) sample addressing
//-------------------------------------------------------------------
reg [7:0] cx_idx_q;

reg [5:0] cx_rd_ptr_r;

always @ *
begin
    case (cx_idx_q)
    8'd0: cx_rd_ptr_r = 6'd0;
    8'd1: cx_rd_ptr_r = 6'd1;
    8'd2: cx_rd_ptr_r = 6'd1;
    8'd3: cx_rd_ptr_r = 6'd2;
    8'd4: cx_rd_ptr_r = 6'd2;
    8'd5: cx_rd_ptr_r = 6'd3;
    8'd6: cx_rd_ptr_r = 6'd3;
    8'd7: cx_rd_ptr_r = 6'd0;
    8'd8: cx_rd_ptr_r = 6'd0;
    8'd9: cx_rd_ptr_r = 6'd1;
    8'd10: cx_rd_ptr_r = 6'd1;
    8'd11: cx_rd_ptr_r = 6'd2;
    8'd12: cx_rd_ptr_r = 6'd2;
    8'd13: cx_rd_ptr_r = 6'd3;
    8'd14: cx_rd_ptr_r = 6'd3;
    8'd15: cx_rd_ptr_r = 6'd8;
    8'd16: cx_rd_ptr_r = 6'd8;
    8'd17: cx_rd_ptr_r = 6'd9;
    8'd18: cx_rd_ptr_r = 6'd9;
    8'd19: cx_rd_ptr_r = 6'd10;
    8'd20: cx_rd_ptr_r = 6'd10;
    8'd21: cx_rd_ptr_r = 6'd11;
    8'd22: cx_rd_ptr_r = 6'd11;
    8'd23: cx_rd_ptr_r = 6'd8;
    8'd24: cx_rd_ptr_r = 6'd8;
    8'd25: cx_rd_ptr_r = 6'd9;
    8'd26: cx_rd_ptr_r = 6'd9;
    8'd27: cx_rd_ptr_r = 6'd10;
    8'd28: cx_rd_ptr_r = 6'd10;
    8'd29: cx_rd_ptr_r = 6'd11;
    8'd30: cx_rd_ptr_r = 6'd11;
    8'd31: cx_rd_ptr_r = 6'd16;
    8'd32: cx_rd_ptr_r = 6'd16;
    8'd33: cx_rd_ptr_r = 6'd17;
    8'd34: cx_rd_ptr_r = 6'd17;
    8'd35: cx_rd_ptr_r = 6'd18;
    8'd36: cx_rd_ptr_r = 6'd18;
    8'd37: cx_rd_ptr_r = 6'd19;
    8'd38: cx_rd_ptr_r = 6'd19;
    8'd39: cx_rd_ptr_r = 6'd16;
    8'd40: cx_rd_ptr_r = 6'd16;
    8'd41: cx_rd_ptr_r = 6'd17;
    8'd42: cx_rd_ptr_r = 6'd17;
    8'd43: cx_rd_ptr_r = 6'd18;
    8'd44: cx_rd_ptr_r = 6'd18;
    8'd45: cx_rd_ptr_r = 6'd19;
    8'd46: cx_rd_ptr_r = 6'd19;
    8'd47: cx_rd_ptr_r = 6'd24;
    8'd48: cx_rd_ptr_r = 6'd24;
    8'd49: cx_rd_ptr_r = 6'd25;
    8'd50: cx_rd_ptr_r = 6'd25;
    8'd51: cx_rd_ptr_r = 6'd26;
    8'd52: cx_rd_ptr_r = 6'd26;
    8'd53: cx_rd_ptr_r = 6'd27;
    8'd54: cx_rd_ptr_r = 6'd27;
    8'd55: cx_rd_ptr_r = 6'd24;
    8'd56: cx_rd_ptr_r = 6'd24;
    8'd57: cx_rd_ptr_r = 6'd25;
    8'd58: cx_rd_ptr_r = 6'd25;
    8'd59: cx_rd_ptr_r = 6'd26;
    8'd60: cx_rd_ptr_r = 6'd26;
    8'd61: cx_rd_ptr_r = 6'd27;
    8'd62: cx_rd_ptr_r = 6'd27;
    8'd63: cx_rd_ptr_r = 6'd4;
    8'd64: cx_rd_ptr_r = 6'd4;
    8'd65: cx_rd_ptr_r = 6'd5;
    8'd66: cx_rd_ptr_r = 6'd5;
    8'd67: cx_rd_ptr_r = 6'd6;
    8'd68: cx_rd_ptr_r = 6'd6;
    8'd69: cx_rd_ptr_r = 6'd7;
    8'd70: cx_rd_ptr_r = 6'd7;
    8'd71: cx_rd_ptr_r = 6'd4;
    8'd72: cx_rd_ptr_r = 6'd4;
    8'd73: cx_rd_ptr_r = 6'd5;
    8'd74: cx_rd_ptr_r = 6'd5;
    8'd75: cx_rd_ptr_r = 6'd6;
    8'd76: cx_rd_ptr_r = 6'd6;
    8'd77: cx_rd_ptr_r = 6'd7;
    8'd78: cx_rd_ptr_r = 6'd7;
    8'd79: cx_rd_ptr_r = 6'd12;
    8'd80: cx_rd_ptr_r = 6'd12;
    8'd81: cx_rd_ptr_r = 6'd13;
    8'd82: cx_rd_ptr_r = 6'd13;
    8'd83: cx_rd_ptr_r = 6'd14;
    8'd84: cx_rd_ptr_r = 6'd14;
    8'd85: cx_rd_ptr_r = 6'd15;
    8'd86: cx_rd_ptr_r = 6'd15;
    8'd87: cx_rd_ptr_r = 6'd12;
    8'd88: cx_rd_ptr_r = 6'd12;
    8'd89: cx_rd_ptr_r = 6'd13;
    8'd90: cx_rd_ptr_r = 6'd13;
    8'd91: cx_rd_ptr_r = 6'd14;
    8'd92: cx_rd_ptr_r = 6'd14;
    8'd93: cx_rd_ptr_r = 6'd15;
    8'd94: cx_rd_ptr_r = 6'd15;
    8'd95: cx_rd_ptr_r = 6'd20;
    8'd96: cx_rd_ptr_r = 6'd20;
    8'd97: cx_rd_ptr_r = 6'd21;
    8'd98: cx_rd_ptr_r = 6'd21;
    8'd99: cx_rd_ptr_r = 6'd22;
    8'd100: cx_rd_ptr_r = 6'd22;
    8'd101: cx_rd_ptr_r = 6'd23;
    8'd102: cx_rd_ptr_r = 6'd23;
    8'd103: cx_rd_ptr_r = 6'd20;
    8'd104: cx_rd_ptr_r = 6'd20;
    8'd105: cx_rd_ptr_r = 6'd21;
    8'd106: cx_rd_ptr_r = 6'd21;
    8'd107: cx_rd_ptr_r = 6'd22;
    8'd108: cx_rd_ptr_r = 6'd22;
    8'd109: cx_rd_ptr_r = 6'd23;
    8'd110: cx_rd_ptr_r = 6'd23;
    8'd111: cx_rd_ptr_r = 6'd28;
    8'd112: cx_rd_ptr_r = 6'd28;
    8'd113: cx_rd_ptr_r = 6'd29;
    8'd114: cx_rd_ptr_r = 6'd29;
    8'd115: cx_rd_ptr_r = 6'd30;
    8'd116: cx_rd_ptr_r = 6'd30;
    8'd117: cx_rd_ptr_r = 6'd31;
    8'd118: cx_rd_ptr_r = 6'd31;
    8'd119: cx_rd_ptr_r = 6'd28;
    8'd120: cx_rd_ptr_r = 6'd28;
    8'd121: cx_rd_ptr_r = 6'd29;
    8'd122: cx_rd_ptr_r = 6'd29;
    8'd123: cx_rd_ptr_r = 6'd30;
    8'd124: cx_rd_ptr_r = 6'd30;
    8'd125: cx_rd_ptr_r = 6'd31;
    8'd126: cx_rd_ptr_r = 6'd31;
    8'd127: cx_rd_ptr_r = 6'd32;
    8'd128: cx_rd_ptr_r = 6'd32;
    8'd129: cx_rd_ptr_r = 6'd33;
    8'd130: cx_rd_ptr_r = 6'd33;
    8'd131: cx_rd_ptr_r = 6'd34;
    8'd132: cx_rd_ptr_r = 6'd34;
    8'd133: cx_rd_ptr_r = 6'd35;
    8'd134: cx_rd_ptr_r = 6'd35;
    8'd135: cx_rd_ptr_r = 6'd32;
    8'd136: cx_rd_ptr_r = 6'd32;
    8'd137: cx_rd_ptr_r = 6'd33;
    8'd138: cx_rd_ptr_r = 6'd33;
    8'd139: cx_rd_ptr_r = 6'd34;
    8'd140: cx_rd_ptr_r = 6'd34;
    8'd141: cx_rd_ptr_r = 6'd35;
    8'd142: cx_rd_ptr_r = 6'd35;
    8'd143: cx_rd_ptr_r = 6'd40;
    8'd144: cx_rd_ptr_r = 6'd40;
    8'd145: cx_rd_ptr_r = 6'd41;
    8'd146: cx_rd_ptr_r = 6'd41;
    8'd147: cx_rd_ptr_r = 6'd42;
    8'd148: cx_rd_ptr_r = 6'd42;
    8'd149: cx_rd_ptr_r = 6'd43;
    8'd150: cx_rd_ptr_r = 6'd43;
    8'd151: cx_rd_ptr_r = 6'd40;
    8'd152: cx_rd_ptr_r = 6'd40;
    8'd153: cx_rd_ptr_r = 6'd41;
    8'd154: cx_rd_ptr_r = 6'd41;
    8'd155: cx_rd_ptr_r = 6'd42;
    8'd156: cx_rd_ptr_r = 6'd42;
    8'd157: cx_rd_ptr_r = 6'd43;
    8'd158: cx_rd_ptr_r = 6'd43;
    8'd159: cx_rd_ptr_r = 6'd48;
    8'd160: cx_rd_ptr_r = 6'd48;
    8'd161: cx_rd_ptr_r = 6'd49;
    8'd162: cx_rd_ptr_r = 6'd49;
    8'd163: cx_rd_ptr_r = 6'd50;
    8'd164: cx_rd_ptr_r = 6'd50;
    8'd165: cx_rd_ptr_r = 6'd51;
    8'd166: cx_rd_ptr_r = 6'd51;
    8'd167: cx_rd_ptr_r = 6'd48;
    8'd168: cx_rd_ptr_r = 6'd48;
    8'd169: cx_rd_ptr_r = 6'd49;
    8'd170: cx_rd_ptr_r = 6'd49;
    8'd171: cx_rd_ptr_r = 6'd50;
    8'd172: cx_rd_ptr_r = 6'd50;
    8'd173: cx_rd_ptr_r = 6'd51;
    8'd174: cx_rd_ptr_r = 6'd51;
    8'd175: cx_rd_ptr_r = 6'd56;
    8'd176: cx_rd_ptr_r = 6'd56;
    8'd177: cx_rd_ptr_r = 6'd57;
    8'd178: cx_rd_ptr_r = 6'd57;
    8'd179: cx_rd_ptr_r = 6'd58;
    8'd180: cx_rd_ptr_r = 6'd58;
    8'd181: cx_rd_ptr_r = 6'd59;
    8'd182: cx_rd_ptr_r = 6'd59;
    8'd183: cx_rd_ptr_r = 6'd56;
    8'd184: cx_rd_ptr_r = 6'd56;
    8'd185: cx_rd_ptr_r = 6'd57;
    8'd186: cx_rd_ptr_r = 6'd57;
    8'd187: cx_rd_ptr_r = 6'd58;
    8'd188: cx_rd_ptr_r = 6'd58;
    8'd189: cx_rd_ptr_r = 6'd59;
    8'd190: cx_rd_ptr_r = 6'd59;
    8'd191: cx_rd_ptr_r = 6'd36;
    8'd192: cx_rd_ptr_r = 6'd36;
    8'd193: cx_rd_ptr_r = 6'd37;
    8'd194: cx_rd_ptr_r = 6'd37;
    8'd195: cx_rd_ptr_r = 6'd38;
    8'd196: cx_rd_ptr_r = 6'd38;
    8'd197: cx_rd_ptr_r = 6'd39;
    8'd198: cx_rd_ptr_r = 6'd39;
    8'd199: cx_rd_ptr_r = 6'd36;
    8'd200: cx_rd_ptr_r = 6'd36;
    8'd201: cx_rd_ptr_r = 6'd37;
    8'd202: cx_rd_ptr_r = 6'd37;
    8'd203: cx_rd_ptr_r = 6'd38;
    8'd204: cx_rd_ptr_r = 6'd38;
    8'd205: cx_rd_ptr_r = 6'd39;
    8'd206: cx_rd_ptr_r = 6'd39;
    8'd207: cx_rd_ptr_r = 6'd44;
    8'd208: cx_rd_ptr_r = 6'd44;
    8'd209: cx_rd_ptr_r = 6'd45;
    8'd210: cx_rd_ptr_r = 6'd45;
    8'd211: cx_rd_ptr_r = 6'd46;
    8'd212: cx_rd_ptr_r = 6'd46;
    8'd213: cx_rd_ptr_r = 6'd47;
    8'd214: cx_rd_ptr_r = 6'd47;
    8'd215: cx_rd_ptr_r = 6'd44;
    8'd216: cx_rd_ptr_r = 6'd44;
    8'd217: cx_rd_ptr_r = 6'd45;
    8'd218: cx_rd_ptr_r = 6'd45;
    8'd219: cx_rd_ptr_r = 6'd46;
    8'd220: cx_rd_ptr_r = 6'd46;
    8'd221: cx_rd_ptr_r = 6'd47;
    8'd222: cx_rd_ptr_r = 6'd47;
    8'd223: cx_rd_ptr_r = 6'd52;
    8'd224: cx_rd_ptr_r = 6'd52;
    8'd225: cx_rd_ptr_r = 6'd53;
    8'd226: cx_rd_ptr_r = 6'd53;
    8'd227: cx_rd_ptr_r = 6'd54;
    8'd228: cx_rd_ptr_r = 6'd54;
    8'd229: cx_rd_ptr_r = 6'd55;
    8'd230: cx_rd_ptr_r = 6'd55;
    8'd231: cx_rd_ptr_r = 6'd52;
    8'd232: cx_rd_ptr_r = 6'd52;
    8'd233: cx_rd_ptr_r = 6'd53;
    8'd234: cx_rd_ptr_r = 6'd53;
    8'd235: cx_rd_ptr_r = 6'd54;
    8'd236: cx_rd_ptr_r = 6'd54;
    8'd237: cx_rd_ptr_r = 6'd55;
    8'd238: cx_rd_ptr_r = 6'd55;
    8'd239: cx_rd_ptr_r = 6'd60;
    8'd240: cx_rd_ptr_r = 6'd60;
    8'd241: cx_rd_ptr_r = 6'd61;
    8'd242: cx_rd_ptr_r = 6'd61;
    8'd243: cx_rd_ptr_r = 6'd62;
    8'd244: cx_rd_ptr_r = 6'd62;
    8'd245: cx_rd_ptr_r = 6'd63;
    8'd246: cx_rd_ptr_r = 6'd63;
    8'd247: cx_rd_ptr_r = 6'd60;
    8'd248: cx_rd_ptr_r = 6'd60;
    8'd249: cx_rd_ptr_r = 6'd61;
    8'd250: cx_rd_ptr_r = 6'd61;
    8'd251: cx_rd_ptr_r = 6'd62;
    8'd252: cx_rd_ptr_r = 6'd62;
    8'd253: cx_rd_ptr_r = 6'd63;
    8'd254: cx_rd_ptr_r = 6'd63;
    default: cx_rd_ptr_r = 6'd0;
    endcase
end

always @ (posedge clk_i )
if (rst_i)
    cx_idx_q    <= 8'b0;
else if (flush_i)
    cx_idx_q    <= 8'b0;
else if (read_ok_w && ((!valid_o) || (valid_o && pop_i)))
    cx_idx_q    <= cx_idx_q + 8'd1;

reg [1:0] cx_half_q;

always @ (posedge clk_i )
if (rst_i)
    cx_half_q    <= 2'b0;
else if (flush_i)
    cx_half_q    <= 2'b0;
else if (read_ok_w && ((!valid_o) || (valid_o && pop_i)) && cx_idx_q == 8'd255)
    cx_half_q    <= cx_half_q + 2'd1;

reg [5:0] cx_rd_ptr_q;

always @ (posedge clk_i )
if (rst_i)
    cx_rd_ptr_q <= 6'b0;
else if (read_ok_w && ((!valid_o) || (valid_o && pop_i)))
    cx_rd_ptr_q <= cx_rd_ptr_r;

wire [7:0] rd_addr_w = mode420_i ? {cx_half_q, cx_rd_ptr_q} : rd_ptr_q;

//-------------------------------------------------------------------
// Read Skid Buffer
//-------------------------------------------------------------------
reg                rd_skid_q;
reg [31:0] rd_skid_data_q;

always @ (posedge clk_i )
if (rst_i)
begin
    rd_skid_q <= 1'b0;
    rd_skid_data_q <= 32'b0;
end
else if (flush_i)
begin
    rd_skid_q <= 1'b0;
    rd_skid_data_q <= 32'b0;
end
else if (valid_o && !pop_i)
begin
    rd_skid_q      <= 1'b1;
    rd_skid_data_q <= data_out_o;
end
else
begin
    rd_skid_q      <= 1'b0;
    rd_skid_data_q <= 32'b0;
end

//-------------------------------------------------------------------
// Combinatorial
//-------------------------------------------------------------------
assign valid_o       = rd_skid_q | rd_q;

//-------------------------------------------------------------------
// Dual port RAM
//-------------------------------------------------------------------
wire [31:0] data_out_w;

jpeg_output_cx_ram_ram_dp_256_8
u_ram
(
    // Inputs
    .clk0_i(clk_i),
    .rst0_i(rst_i),
    .clk1_i(clk_i),
    .rst1_i(rst_i),

    // Write side
    .addr0_i({wr_ptr_q[7:6], wr_idx_i}),
    .wr0_i(push_i),
    .data0_i(data_in_i),
    .data0_o(),

    // Read side
    .addr1_i(rd_addr_w),
    .data1_i(32'b0),
    .wr1_i(1'b0),
    .data1_o(data_out_w)
);

assign data_out_o = rd_skid_q ? rd_skid_data_q : data_out_w;


//-------------------------------------------------------------------
// Level
//-------------------------------------------------------------------
reg [31:0]  count_q;
reg [31:0]  count_r;

always @ *
begin
    count_r = count_q;

    if (pop_i && valid_o)
        count_r = count_r - 32'd1;

    if (push_i)
        count_r = count_r + (mode420_i ? 32'd4 : 32'd1);
end

always @ (posedge clk_i )
if (rst_i)
    count_q   <= 32'b0;
else if (flush_i)
    count_q   <= 32'b0;
else
    count_q <= count_r;

assign level_o = count_q;

endmodule

//-------------------------------------------------------------------
// Dual port RAM
//-------------------------------------------------------------------
module jpeg_output_cx_ram_ram_dp_256_8
(
    // Inputs
     input           clk0_i
    ,input           rst0_i
    ,input  [ 7:0]  addr0_i
    ,input  [ 31:0]  data0_i
    ,input           wr0_i
    ,input           clk1_i
    ,input           rst1_i
    ,input  [ 7:0]  addr1_i
    ,input  [ 31:0]  data1_i
    ,input           wr1_i

    // Outputs
    ,output [ 31:0]  data0_o
    ,output [ 31:0]  data1_o
);

/* verilator lint_off MULTIDRIVEN */
reg [31:0]   ram [255:0] /*verilator public*/;
/* verilator lint_on MULTIDRIVEN */

reg [31:0] ram_read0_q;
reg [31:0] ram_read1_q;

// Synchronous write
always @ (posedge clk0_i)
begin
    if (wr0_i)
        ram[addr0_i] <= data0_i;

    ram_read0_q <= ram[addr0_i];
end

always @ (posedge clk1_i)
begin
    if (wr1_i)
        ram[addr1_i] <= data1_i;

    ram_read1_q <= ram[addr1_i];
end

assign data0_o = ram_read0_q;
assign data1_o = ram_read1_q;



endmodule
