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

module jpeg_dht
//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
#(
     parameter SUPPORT_WRITABLE_DHT = 0
)
//-----------------------------------------------------------------
// Ports
//-----------------------------------------------------------------
(
    // Inputs
     input           clk_i
    ,input           rst_i
    ,input           cfg_valid_i
    ,input  [  7:0]  cfg_data_i
    ,input           cfg_last_i
    ,input           lookup_req_i
    ,input  [  1:0]  lookup_table_i
    ,input  [ 15:0]  lookup_input_i

    // Outputs
    ,output          cfg_accept_o
    ,output          lookup_valid_o
    ,output [  4:0]  lookup_width_o
    ,output [  7:0]  lookup_value_o
);




localparam DHT_TABLE_Y_DC      = 8'h00;
localparam DHT_TABLE_Y_AC      = 8'h10;
localparam DHT_TABLE_CX_DC     = 8'h01;
localparam DHT_TABLE_CX_AC     = 8'h11;

//---------------------------------------------------------------------
// Support writable huffman tables (e.g. file contains optimised tables)
//---------------------------------------------------------------------
generate
if (SUPPORT_WRITABLE_DHT)
begin
    reg [15:0] y_dc_min_code_q[0:15];
    reg [15:0] y_dc_max_code_q[0:15];
    reg [9:0]  y_dc_ptr_q[0:15];
    reg [15:0] y_ac_min_code_q[0:15];
    reg [15:0] y_ac_max_code_q[0:15];
    reg [9:0]  y_ac_ptr_q[0:15];
    reg [15:0] cx_dc_min_code_q[0:15];
    reg [15:0] cx_dc_max_code_q[0:15];
    reg [9:0]  cx_dc_ptr_q[0:15];
    reg [15:0] cx_ac_min_code_q[0:15];
    reg [15:0] cx_ac_max_code_q[0:15];
    reg [9:0]  cx_ac_ptr_q[0:15];

    // DHT tables can be combined into one section...
    // Reset the table state machine at the end of each table
    wire cfg_last_w = cfg_last_i || (total_entries_q == idx_q && idx_q >= 12'd16);

    //-----------------------------------------------------------------
    // Capture Index
    //-----------------------------------------------------------------
    reg [11:0] idx_q;

    always @ (posedge clk_i )
    if (rst_i)
        idx_q <= 12'hFFF;
    else if (cfg_valid_i && cfg_last_w && cfg_accept_o)
        idx_q <= 12'hFFF;
    else if (cfg_valid_i && cfg_accept_o)
        idx_q <= idx_q + 12'd1;

    //-----------------------------------------------------------------
    // Table Index
    //-----------------------------------------------------------------
    reg [7:0] cfg_table_q;

    always @ (posedge clk_i )
    if (rst_i)
        cfg_table_q <= 8'b0;
    else if (cfg_valid_i && cfg_accept_o && idx_q == 12'hFFF)
        cfg_table_q <= cfg_data_i;

    //-----------------------------------------------------------------
    // Extract symbol count (temporary)
    //-----------------------------------------------------------------
    reg [7:0]  num_entries_q[0:15];
    reg [15:0] has_entries_q; // bitmap
    reg [11:0] total_entries_q;

    always @ (posedge clk_i )
    if (rst_i)
    begin
        num_entries_q[0] <= 8'b0;
        num_entries_q[1] <= 8'b0;
        num_entries_q[2] <= 8'b0;
        num_entries_q[3] <= 8'b0;
        num_entries_q[4] <= 8'b0;
        num_entries_q[5] <= 8'b0;
        num_entries_q[6] <= 8'b0;
        num_entries_q[7] <= 8'b0;
        num_entries_q[8] <= 8'b0;
        num_entries_q[9] <= 8'b0;
        num_entries_q[10] <= 8'b0;
        num_entries_q[11] <= 8'b0;
        num_entries_q[12] <= 8'b0;
        num_entries_q[13] <= 8'b0;
        num_entries_q[14] <= 8'b0;
        num_entries_q[15] <= 8'b0;
        has_entries_q   <= 16'b0;
        total_entries_q <= 12'd15;
    end
    else if (cfg_valid_i && cfg_accept_o && idx_q < 12'd16)
    begin
        num_entries_q[idx_q[3:0]] <= cfg_data_i;
        has_entries_q[idx_q[3:0]] <= (cfg_data_i != 8'b0);
        total_entries_q           <= total_entries_q + {4'b0, cfg_data_i};
    end
    // End of DHT table
    else if (cfg_valid_i && cfg_last_w && cfg_accept_o)
    begin
        num_entries_q[0] <= 8'b0;
        num_entries_q[1] <= 8'b0;
        num_entries_q[2] <= 8'b0;
        num_entries_q[3] <= 8'b0;
        num_entries_q[4] <= 8'b0;
        num_entries_q[5] <= 8'b0;
        num_entries_q[6] <= 8'b0;
        num_entries_q[7] <= 8'b0;
        num_entries_q[8] <= 8'b0;
        num_entries_q[9] <= 8'b0;
        num_entries_q[10] <= 8'b0;
        num_entries_q[11] <= 8'b0;
        num_entries_q[12] <= 8'b0;
        num_entries_q[13] <= 8'b0;
        num_entries_q[14] <= 8'b0;
        num_entries_q[15] <= 8'b0;
        has_entries_q   <= 16'b0;
        total_entries_q <= 12'd15;
    end

    //-----------------------------------------------------------------
    // Fill tables
    //-----------------------------------------------------------------
    reg [3:0]  i_q;
    reg [7:0]  j_q;
    reg [15:0] code_q;
    reg [9:0]  next_ptr_q;

    always @ (posedge clk_i )
    if (rst_i)
    begin
        y_dc_min_code_q[0] <= 16'b0;
        y_dc_max_code_q[0] <= 16'b0;
        y_dc_ptr_q[0]      <= 10'b0;
        y_dc_min_code_q[1] <= 16'b0;
        y_dc_max_code_q[1] <= 16'b0;
        y_dc_ptr_q[1]      <= 10'b0;
        y_dc_min_code_q[2] <= 16'b0;
        y_dc_max_code_q[2] <= 16'b0;
        y_dc_ptr_q[2]      <= 10'b0;
        y_dc_min_code_q[3] <= 16'b0;
        y_dc_max_code_q[3] <= 16'b0;
        y_dc_ptr_q[3]      <= 10'b0;
        y_dc_min_code_q[4] <= 16'b0;
        y_dc_max_code_q[4] <= 16'b0;
        y_dc_ptr_q[4]      <= 10'b0;
        y_dc_min_code_q[5] <= 16'b0;
        y_dc_max_code_q[5] <= 16'b0;
        y_dc_ptr_q[5]      <= 10'b0;
        y_dc_min_code_q[6] <= 16'b0;
        y_dc_max_code_q[6] <= 16'b0;
        y_dc_ptr_q[6]      <= 10'b0;
        y_dc_min_code_q[7] <= 16'b0;
        y_dc_max_code_q[7] <= 16'b0;
        y_dc_ptr_q[7]      <= 10'b0;
        y_dc_min_code_q[8] <= 16'b0;
        y_dc_max_code_q[8] <= 16'b0;
        y_dc_ptr_q[8]      <= 10'b0;
        y_dc_min_code_q[9] <= 16'b0;
        y_dc_max_code_q[9] <= 16'b0;
        y_dc_ptr_q[9]      <= 10'b0;
        y_dc_min_code_q[10] <= 16'b0;
        y_dc_max_code_q[10] <= 16'b0;
        y_dc_ptr_q[10]      <= 10'b0;
        y_dc_min_code_q[11] <= 16'b0;
        y_dc_max_code_q[11] <= 16'b0;
        y_dc_ptr_q[11]      <= 10'b0;
        y_dc_min_code_q[12] <= 16'b0;
        y_dc_max_code_q[12] <= 16'b0;
        y_dc_ptr_q[12]      <= 10'b0;
        y_dc_min_code_q[13] <= 16'b0;
        y_dc_max_code_q[13] <= 16'b0;
        y_dc_ptr_q[13]      <= 10'b0;
        y_dc_min_code_q[14] <= 16'b0;
        y_dc_max_code_q[14] <= 16'b0;
        y_dc_ptr_q[14]      <= 10'b0;
        y_dc_min_code_q[15] <= 16'b0;
        y_dc_max_code_q[15] <= 16'b0;
        y_dc_ptr_q[15]      <= 10'b0;
        y_ac_min_code_q[0] <= 16'b0;
        y_ac_max_code_q[0] <= 16'b0;
        y_ac_ptr_q[0]      <= 10'b0;
        y_ac_min_code_q[1] <= 16'b0;
        y_ac_max_code_q[1] <= 16'b0;
        y_ac_ptr_q[1]      <= 10'b0;
        y_ac_min_code_q[2] <= 16'b0;
        y_ac_max_code_q[2] <= 16'b0;
        y_ac_ptr_q[2]      <= 10'b0;
        y_ac_min_code_q[3] <= 16'b0;
        y_ac_max_code_q[3] <= 16'b0;
        y_ac_ptr_q[3]      <= 10'b0;
        y_ac_min_code_q[4] <= 16'b0;
        y_ac_max_code_q[4] <= 16'b0;
        y_ac_ptr_q[4]      <= 10'b0;
        y_ac_min_code_q[5] <= 16'b0;
        y_ac_max_code_q[5] <= 16'b0;
        y_ac_ptr_q[5]      <= 10'b0;
        y_ac_min_code_q[6] <= 16'b0;
        y_ac_max_code_q[6] <= 16'b0;
        y_ac_ptr_q[6]      <= 10'b0;
        y_ac_min_code_q[7] <= 16'b0;
        y_ac_max_code_q[7] <= 16'b0;
        y_ac_ptr_q[7]      <= 10'b0;
        y_ac_min_code_q[8] <= 16'b0;
        y_ac_max_code_q[8] <= 16'b0;
        y_ac_ptr_q[8]      <= 10'b0;
        y_ac_min_code_q[9] <= 16'b0;
        y_ac_max_code_q[9] <= 16'b0;
        y_ac_ptr_q[9]      <= 10'b0;
        y_ac_min_code_q[10] <= 16'b0;
        y_ac_max_code_q[10] <= 16'b0;
        y_ac_ptr_q[10]      <= 10'b0;
        y_ac_min_code_q[11] <= 16'b0;
        y_ac_max_code_q[11] <= 16'b0;
        y_ac_ptr_q[11]      <= 10'b0;
        y_ac_min_code_q[12] <= 16'b0;
        y_ac_max_code_q[12] <= 16'b0;
        y_ac_ptr_q[12]      <= 10'b0;
        y_ac_min_code_q[13] <= 16'b0;
        y_ac_max_code_q[13] <= 16'b0;
        y_ac_ptr_q[13]      <= 10'b0;
        y_ac_min_code_q[14] <= 16'b0;
        y_ac_max_code_q[14] <= 16'b0;
        y_ac_ptr_q[14]      <= 10'b0;
        y_ac_min_code_q[15] <= 16'b0;
        y_ac_max_code_q[15] <= 16'b0;
        y_ac_ptr_q[15]      <= 10'b0;
        cx_dc_min_code_q[0] <= 16'b0;
        cx_dc_max_code_q[0] <= 16'b0;
        cx_dc_ptr_q[0]      <= 10'b0;
        cx_dc_min_code_q[1] <= 16'b0;
        cx_dc_max_code_q[1] <= 16'b0;
        cx_dc_ptr_q[1]      <= 10'b0;
        cx_dc_min_code_q[2] <= 16'b0;
        cx_dc_max_code_q[2] <= 16'b0;
        cx_dc_ptr_q[2]      <= 10'b0;
        cx_dc_min_code_q[3] <= 16'b0;
        cx_dc_max_code_q[3] <= 16'b0;
        cx_dc_ptr_q[3]      <= 10'b0;
        cx_dc_min_code_q[4] <= 16'b0;
        cx_dc_max_code_q[4] <= 16'b0;
        cx_dc_ptr_q[4]      <= 10'b0;
        cx_dc_min_code_q[5] <= 16'b0;
        cx_dc_max_code_q[5] <= 16'b0;
        cx_dc_ptr_q[5]      <= 10'b0;
        cx_dc_min_code_q[6] <= 16'b0;
        cx_dc_max_code_q[6] <= 16'b0;
        cx_dc_ptr_q[6]      <= 10'b0;
        cx_dc_min_code_q[7] <= 16'b0;
        cx_dc_max_code_q[7] <= 16'b0;
        cx_dc_ptr_q[7]      <= 10'b0;
        cx_dc_min_code_q[8] <= 16'b0;
        cx_dc_max_code_q[8] <= 16'b0;
        cx_dc_ptr_q[8]      <= 10'b0;
        cx_dc_min_code_q[9] <= 16'b0;
        cx_dc_max_code_q[9] <= 16'b0;
        cx_dc_ptr_q[9]      <= 10'b0;
        cx_dc_min_code_q[10] <= 16'b0;
        cx_dc_max_code_q[10] <= 16'b0;
        cx_dc_ptr_q[10]      <= 10'b0;
        cx_dc_min_code_q[11] <= 16'b0;
        cx_dc_max_code_q[11] <= 16'b0;
        cx_dc_ptr_q[11]      <= 10'b0;
        cx_dc_min_code_q[12] <= 16'b0;
        cx_dc_max_code_q[12] <= 16'b0;
        cx_dc_ptr_q[12]      <= 10'b0;
        cx_dc_min_code_q[13] <= 16'b0;
        cx_dc_max_code_q[13] <= 16'b0;
        cx_dc_ptr_q[13]      <= 10'b0;
        cx_dc_min_code_q[14] <= 16'b0;
        cx_dc_max_code_q[14] <= 16'b0;
        cx_dc_ptr_q[14]      <= 10'b0;
        cx_dc_min_code_q[15] <= 16'b0;
        cx_dc_max_code_q[15] <= 16'b0;
        cx_dc_ptr_q[15]      <= 10'b0;
        cx_ac_min_code_q[0] <= 16'b0;
        cx_ac_max_code_q[0] <= 16'b0;
        cx_ac_ptr_q[0]      <= 10'b0;
        cx_ac_min_code_q[1] <= 16'b0;
        cx_ac_max_code_q[1] <= 16'b0;
        cx_ac_ptr_q[1]      <= 10'b0;
        cx_ac_min_code_q[2] <= 16'b0;
        cx_ac_max_code_q[2] <= 16'b0;
        cx_ac_ptr_q[2]      <= 10'b0;
        cx_ac_min_code_q[3] <= 16'b0;
        cx_ac_max_code_q[3] <= 16'b0;
        cx_ac_ptr_q[3]      <= 10'b0;
        cx_ac_min_code_q[4] <= 16'b0;
        cx_ac_max_code_q[4] <= 16'b0;
        cx_ac_ptr_q[4]      <= 10'b0;
        cx_ac_min_code_q[5] <= 16'b0;
        cx_ac_max_code_q[5] <= 16'b0;
        cx_ac_ptr_q[5]      <= 10'b0;
        cx_ac_min_code_q[6] <= 16'b0;
        cx_ac_max_code_q[6] <= 16'b0;
        cx_ac_ptr_q[6]      <= 10'b0;
        cx_ac_min_code_q[7] <= 16'b0;
        cx_ac_max_code_q[7] <= 16'b0;
        cx_ac_ptr_q[7]      <= 10'b0;
        cx_ac_min_code_q[8] <= 16'b0;
        cx_ac_max_code_q[8] <= 16'b0;
        cx_ac_ptr_q[8]      <= 10'b0;
        cx_ac_min_code_q[9] <= 16'b0;
        cx_ac_max_code_q[9] <= 16'b0;
        cx_ac_ptr_q[9]      <= 10'b0;
        cx_ac_min_code_q[10] <= 16'b0;
        cx_ac_max_code_q[10] <= 16'b0;
        cx_ac_ptr_q[10]      <= 10'b0;
        cx_ac_min_code_q[11] <= 16'b0;
        cx_ac_max_code_q[11] <= 16'b0;
        cx_ac_ptr_q[11]      <= 10'b0;
        cx_ac_min_code_q[12] <= 16'b0;
        cx_ac_max_code_q[12] <= 16'b0;
        cx_ac_ptr_q[12]      <= 10'b0;
        cx_ac_min_code_q[13] <= 16'b0;
        cx_ac_max_code_q[13] <= 16'b0;
        cx_ac_ptr_q[13]      <= 10'b0;
        cx_ac_min_code_q[14] <= 16'b0;
        cx_ac_max_code_q[14] <= 16'b0;
        cx_ac_ptr_q[14]      <= 10'b0;
        cx_ac_min_code_q[15] <= 16'b0;
        cx_ac_max_code_q[15] <= 16'b0;
        cx_ac_ptr_q[15]      <= 10'b0;
        j_q    <= 8'b0;
        i_q    <= 4'b0;
        code_q <= 16'b0;
    end
    else if (idx_q < 12'd16 || idx_q == 12'hFFF)
    begin
        j_q    <= 8'b0;
        i_q    <= 4'b0;
        code_q <= 16'b0;
    end
    else if (cfg_valid_i && cfg_accept_o)
    begin
        if (j_q == 8'b0)
        begin
            case (cfg_table_q)
            DHT_TABLE_Y_DC:
            begin
                y_dc_min_code_q[i_q] <= code_q;
                y_dc_max_code_q[i_q] <= code_q + {8'b0, num_entries_q[i_q]};
                y_dc_ptr_q[i_q]      <= next_ptr_q;
            end
            DHT_TABLE_Y_AC:
            begin
                y_ac_min_code_q[i_q] <= code_q;
                y_ac_max_code_q[i_q] <= code_q + {8'b0, num_entries_q[i_q]};
                y_ac_ptr_q[i_q]      <= next_ptr_q;
            end
            DHT_TABLE_CX_DC:
            begin
                cx_dc_min_code_q[i_q] <= code_q;
                cx_dc_max_code_q[i_q] <= code_q + {8'b0, num_entries_q[i_q]};
                cx_dc_ptr_q[i_q]      <= next_ptr_q;
            end
            default:
            begin
                cx_ac_min_code_q[i_q] <= code_q;
                cx_ac_max_code_q[i_q] <= code_q + {8'b0, num_entries_q[i_q]};
                cx_ac_ptr_q[i_q]      <= next_ptr_q;
            end
            endcase
        end

        if ((j_q + 8'd1) == num_entries_q[i_q])
        begin
            j_q <= 8'b0;
            i_q <= i_q + 4'd1;
            code_q <= (code_q + 16'd1) << 1;
        end
        else
        begin
            code_q <= code_q + 16'd1;
            j_q    <= j_q + 8'd1;
        end
    end
    // Increment through empty bit widths
    else if (cfg_valid_i && !cfg_accept_o)
    begin
        i_q    <= i_q + 4'd1;
        code_q <= code_q << 1;
    end

    assign cfg_accept_o = has_entries_q[i_q] || (idx_q < 12'd16) || (idx_q == 12'hFFF);

    //-----------------------------------------------------------------
    // Code table write pointer
    //-----------------------------------------------------------------
    wire alloc_entry_w = cfg_valid_i && cfg_accept_o && (idx_q >= 12'd16 && idx_q != 12'hFFF);    

    always @ (posedge clk_i )
    if (rst_i)
        next_ptr_q <= 10'b0;
    else if (alloc_entry_w)
        next_ptr_q <= next_ptr_q + 10'd1;

    //-----------------------------------------------------------------
    // Lookup: Match shortest bit sequence
    //-----------------------------------------------------------------

    reg [3:0] y_dc_width_r;
    always @ *
    begin
        y_dc_width_r = 4'b0;

        if ({15'b0, lookup_input_i[15]} < y_dc_max_code_q[0])
            y_dc_width_r = 4'd0;
        else if ({14'b0, lookup_input_i[15:14]} < y_dc_max_code_q[1])
            y_dc_width_r = 4'd1;
        else if ({13'b0, lookup_input_i[15:13]} < y_dc_max_code_q[2])
            y_dc_width_r = 4'd2;
        else if ({12'b0, lookup_input_i[15:12]} < y_dc_max_code_q[3])
            y_dc_width_r = 4'd3;
        else if ({11'b0, lookup_input_i[15:11]} < y_dc_max_code_q[4])
            y_dc_width_r = 4'd4;
        else if ({10'b0, lookup_input_i[15:10]} < y_dc_max_code_q[5])
            y_dc_width_r = 4'd5;
        else if ({9'b0, lookup_input_i[15:9]} < y_dc_max_code_q[6])
            y_dc_width_r = 4'd6;
        else if ({8'b0, lookup_input_i[15:8]} < y_dc_max_code_q[7])
            y_dc_width_r = 4'd7;
        else if ({7'b0, lookup_input_i[15:7]} < y_dc_max_code_q[8])
            y_dc_width_r = 4'd8;
        else if ({6'b0, lookup_input_i[15:6]} < y_dc_max_code_q[9])
            y_dc_width_r = 4'd9;
        else if ({5'b0, lookup_input_i[15:5]} < y_dc_max_code_q[10])
            y_dc_width_r = 4'd10;
        else if ({4'b0, lookup_input_i[15:4]} < y_dc_max_code_q[11])
            y_dc_width_r = 4'd11;
        else if ({3'b0, lookup_input_i[15:3]} < y_dc_max_code_q[12])
            y_dc_width_r = 4'd12;
        else if ({2'b0, lookup_input_i[15:2]} < y_dc_max_code_q[13])
            y_dc_width_r = 4'd13;
        else if ({1'b0, lookup_input_i[15:1]} < y_dc_max_code_q[14])
            y_dc_width_r = 4'd14;
        else
            y_dc_width_r = 4'd15;
    end

    reg [3:0] y_ac_width_r;
    always @ *
    begin
        y_ac_width_r = 4'b0;

        if ({15'b0, lookup_input_i[15]} < y_ac_max_code_q[0])
            y_ac_width_r = 4'd0;
        else if ({14'b0, lookup_input_i[15:14]} < y_ac_max_code_q[1])
            y_ac_width_r = 4'd1;
        else if ({13'b0, lookup_input_i[15:13]} < y_ac_max_code_q[2])
            y_ac_width_r = 4'd2;
        else if ({12'b0, lookup_input_i[15:12]} < y_ac_max_code_q[3])
            y_ac_width_r = 4'd3;
        else if ({11'b0, lookup_input_i[15:11]} < y_ac_max_code_q[4])
            y_ac_width_r = 4'd4;
        else if ({10'b0, lookup_input_i[15:10]} < y_ac_max_code_q[5])
            y_ac_width_r = 4'd5;
        else if ({9'b0, lookup_input_i[15:9]} < y_ac_max_code_q[6])
            y_ac_width_r = 4'd6;
        else if ({8'b0, lookup_input_i[15:8]} < y_ac_max_code_q[7])
            y_ac_width_r = 4'd7;
        else if ({7'b0, lookup_input_i[15:7]} < y_ac_max_code_q[8])
            y_ac_width_r = 4'd8;
        else if ({6'b0, lookup_input_i[15:6]} < y_ac_max_code_q[9])
            y_ac_width_r = 4'd9;
        else if ({5'b0, lookup_input_i[15:5]} < y_ac_max_code_q[10])
            y_ac_width_r = 4'd10;
        else if ({4'b0, lookup_input_i[15:4]} < y_ac_max_code_q[11])
            y_ac_width_r = 4'd11;
        else if ({3'b0, lookup_input_i[15:3]} < y_ac_max_code_q[12])
            y_ac_width_r = 4'd12;
        else if ({2'b0, lookup_input_i[15:2]} < y_ac_max_code_q[13])
            y_ac_width_r = 4'd13;
        else if ({1'b0, lookup_input_i[15:1]} < y_ac_max_code_q[14])
            y_ac_width_r = 4'd14;
        else
            y_ac_width_r = 4'd15;
    end

    reg [3:0] cx_dc_width_r;
    always @ *
    begin
        cx_dc_width_r = 4'b0;

        if ({15'b0, lookup_input_i[15]} < cx_dc_max_code_q[0])
            cx_dc_width_r = 4'd0;
        else if ({14'b0, lookup_input_i[15:14]} < cx_dc_max_code_q[1])
            cx_dc_width_r = 4'd1;
        else if ({13'b0, lookup_input_i[15:13]} < cx_dc_max_code_q[2])
            cx_dc_width_r = 4'd2;
        else if ({12'b0, lookup_input_i[15:12]} < cx_dc_max_code_q[3])
            cx_dc_width_r = 4'd3;
        else if ({11'b0, lookup_input_i[15:11]} < cx_dc_max_code_q[4])
            cx_dc_width_r = 4'd4;
        else if ({10'b0, lookup_input_i[15:10]} < cx_dc_max_code_q[5])
            cx_dc_width_r = 4'd5;
        else if ({9'b0, lookup_input_i[15:9]} < cx_dc_max_code_q[6])
            cx_dc_width_r = 4'd6;
        else if ({8'b0, lookup_input_i[15:8]} < cx_dc_max_code_q[7])
            cx_dc_width_r = 4'd7;
        else if ({7'b0, lookup_input_i[15:7]} < cx_dc_max_code_q[8])
            cx_dc_width_r = 4'd8;
        else if ({6'b0, lookup_input_i[15:6]} < cx_dc_max_code_q[9])
            cx_dc_width_r = 4'd9;
        else if ({5'b0, lookup_input_i[15:5]} < cx_dc_max_code_q[10])
            cx_dc_width_r = 4'd10;
        else if ({4'b0, lookup_input_i[15:4]} < cx_dc_max_code_q[11])
            cx_dc_width_r = 4'd11;
        else if ({3'b0, lookup_input_i[15:3]} < cx_dc_max_code_q[12])
            cx_dc_width_r = 4'd12;
        else if ({2'b0, lookup_input_i[15:2]} < cx_dc_max_code_q[13])
            cx_dc_width_r = 4'd13;
        else if ({1'b0, lookup_input_i[15:1]} < cx_dc_max_code_q[14])
            cx_dc_width_r = 4'd14;
        else
            cx_dc_width_r = 4'd15;
    end

    reg [3:0] cx_ac_width_r;
    always @ *
    begin
        cx_ac_width_r = 4'b0;

        if ({15'b0, lookup_input_i[15]} < cx_ac_max_code_q[0])
            cx_ac_width_r = 4'd0;
        else if ({14'b0, lookup_input_i[15:14]} < cx_ac_max_code_q[1])
            cx_ac_width_r = 4'd1;
        else if ({13'b0, lookup_input_i[15:13]} < cx_ac_max_code_q[2])
            cx_ac_width_r = 4'd2;
        else if ({12'b0, lookup_input_i[15:12]} < cx_ac_max_code_q[3])
            cx_ac_width_r = 4'd3;
        else if ({11'b0, lookup_input_i[15:11]} < cx_ac_max_code_q[4])
            cx_ac_width_r = 4'd4;
        else if ({10'b0, lookup_input_i[15:10]} < cx_ac_max_code_q[5])
            cx_ac_width_r = 4'd5;
        else if ({9'b0, lookup_input_i[15:9]} < cx_ac_max_code_q[6])
            cx_ac_width_r = 4'd6;
        else if ({8'b0, lookup_input_i[15:8]} < cx_ac_max_code_q[7])
            cx_ac_width_r = 4'd7;
        else if ({7'b0, lookup_input_i[15:7]} < cx_ac_max_code_q[8])
            cx_ac_width_r = 4'd8;
        else if ({6'b0, lookup_input_i[15:6]} < cx_ac_max_code_q[9])
            cx_ac_width_r = 4'd9;
        else if ({5'b0, lookup_input_i[15:5]} < cx_ac_max_code_q[10])
            cx_ac_width_r = 4'd10;
        else if ({4'b0, lookup_input_i[15:4]} < cx_ac_max_code_q[11])
            cx_ac_width_r = 4'd11;
        else if ({3'b0, lookup_input_i[15:3]} < cx_ac_max_code_q[12])
            cx_ac_width_r = 4'd12;
        else if ({2'b0, lookup_input_i[15:2]} < cx_ac_max_code_q[13])
            cx_ac_width_r = 4'd13;
        else if ({1'b0, lookup_input_i[15:1]} < cx_ac_max_code_q[14])
            cx_ac_width_r = 4'd14;
        else
            cx_ac_width_r = 4'd15;
    end

    //-----------------------------------------------------------------
    // Lookup: Register lookup width
    //-----------------------------------------------------------------
    reg [3:0]  lookup_width_r;

    always @ *
    begin
        lookup_width_r = 4'b0;

        case (lookup_table_i)
        2'd0:    lookup_width_r = y_dc_width_r;
        2'd1:    lookup_width_r = y_ac_width_r;
        2'd2:    lookup_width_r = cx_dc_width_r;
        default: lookup_width_r = cx_ac_width_r;
        endcase
    end

    reg [3:0]  lookup_width_q;

    always @ (posedge clk_i )
    if (rst_i)
        lookup_width_q <= 4'b0;
    else
        lookup_width_q <= lookup_width_r;

    reg [1:0]  lookup_table_q;

    always @ (posedge clk_i )
    if (rst_i)
        lookup_table_q <= 2'b0;
    else
        lookup_table_q <= lookup_table_i;

    //-----------------------------------------------------------------
    // Lookup: Create RAM lookup address
    //-----------------------------------------------------------------
    reg [15:0] lookup_addr_r;
    reg [15:0] input_code_r;

    always @ *
    begin
        lookup_addr_r  = 16'b0;
        input_code_r   = 16'b0;

        case (lookup_table_q)
        2'd0:
        begin
            input_code_r   = lookup_input_i >> (15 - lookup_width_q);
            lookup_addr_r  = input_code_r - y_dc_min_code_q[lookup_width_q] + {6'b0, y_dc_ptr_q[lookup_width_q]};
        end
        2'd1:
        begin
            input_code_r   = lookup_input_i >> (15 - lookup_width_q);
            lookup_addr_r  = input_code_r - y_ac_min_code_q[lookup_width_q] + {6'b0, y_ac_ptr_q[lookup_width_q]};
        end
        2'd2:
        begin
            input_code_r   = lookup_input_i >> (15 - lookup_width_q);
            lookup_addr_r  = input_code_r - cx_dc_min_code_q[lookup_width_q] + {6'b0, cx_dc_ptr_q[lookup_width_q]};
        end
        default:
        begin
            input_code_r   = lookup_input_i >> (15 - lookup_width_q);
            lookup_addr_r  = input_code_r - cx_ac_min_code_q[lookup_width_q] + {6'b0, cx_ac_ptr_q[lookup_width_q]};
        end
        endcase
    end

    //-----------------------------------------------------------------
    // RAM for storing Huffman decode values
    //-----------------------------------------------------------------
    // LUT for decode values
    reg [7:0]  ram[0:1023];

    always @ (posedge clk_i)
    begin
        if (alloc_entry_w)
            ram[next_ptr_q] <= cfg_data_i;
    end

    reg [7:0] data_value_q;

    always @ (posedge clk_i)
    begin
        data_value_q <= ram[lookup_addr_r[9:0]];
    end

    reg lookup_valid_q;
    always @ (posedge clk_i )
    if (rst_i)
        lookup_valid_q <= 1'b0;
    else
        lookup_valid_q <= lookup_req_i;

    reg lookup_valid2_q;
    always @ (posedge clk_i )
    if (rst_i)
        lookup_valid2_q <= 1'b0;
    else
        lookup_valid2_q <= lookup_valid_q;

    reg [4:0]  lookup_width2_q;

    always @ (posedge clk_i )
    if (rst_i)
        lookup_width2_q <= 5'b0;
    else
        lookup_width2_q <= {1'b0, lookup_width_q} + 5'd1;

    assign lookup_valid_o = lookup_valid2_q;
    assign lookup_value_o = data_value_q;
    assign lookup_width_o = lookup_width2_q;
end
//---------------------------------------------------------------------
// Support only standard huffman tables (from JPEG spec).
//---------------------------------------------------------------------
else
begin
    //-----------------------------------------------------------------
    // Y DC Table (standard)
    //-----------------------------------------------------------------
    wire [7:0] y_dc_value_w;
    wire [4:0] y_dc_width_w;

    jpeg_dht_std_y_dc
    u_fixed_y_dc
    (
         .lookup_input_i(lookup_input_i)
        ,.lookup_value_o(y_dc_value_w)
        ,.lookup_width_o(y_dc_width_w)
    );

    //-----------------------------------------------------------------
    // Y AC Table (standard)
    //-----------------------------------------------------------------
    wire [7:0] y_ac_value_w;
    wire [4:0] y_ac_width_w;

    jpeg_dht_std_y_ac
    u_fixed_y_ac
    (
         .lookup_input_i(lookup_input_i)
        ,.lookup_value_o(y_ac_value_w)
        ,.lookup_width_o(y_ac_width_w)
    );

    //-----------------------------------------------------------------
    // Cx DC Table (standard)
    //-----------------------------------------------------------------
    wire [7:0] cx_dc_value_w;
    wire [4:0] cx_dc_width_w;

    jpeg_dht_std_cx_dc
    u_fixed_cx_dc
    (
         .lookup_input_i(lookup_input_i)
        ,.lookup_value_o(cx_dc_value_w)
        ,.lookup_width_o(cx_dc_width_w)
    );

    //-----------------------------------------------------------------
    // Cx AC Table (standard)
    //-----------------------------------------------------------------
    wire [7:0] cx_ac_value_w;
    wire [4:0] cx_ac_width_w;

    jpeg_dht_std_cx_ac
    u_fixed_cx_ac
    (
         .lookup_input_i(lookup_input_i)
        ,.lookup_value_o(cx_ac_value_w)
        ,.lookup_width_o(cx_ac_width_w)
    );

    //-----------------------------------------------------------------
    // Lookup
    //-----------------------------------------------------------------
    reg lookup_valid_q;

    always @ (posedge clk_i )
    if (rst_i)
        lookup_valid_q <= 1'b0;
    else
        lookup_valid_q <= lookup_req_i;

    assign lookup_valid_o = lookup_valid_q;

    reg [7:0] lookup_value_q;

    always @ (posedge clk_i )
    if (rst_i)
        lookup_value_q <= 8'b0;
    else
    begin
        case (lookup_table_i)
        2'd0: lookup_value_q <= y_dc_value_w;
        2'd1: lookup_value_q <= y_ac_value_w;
        2'd2: lookup_value_q <= cx_dc_value_w;
        2'd3: lookup_value_q <= cx_ac_value_w;
        endcase
    end

    assign lookup_value_o = lookup_value_q;

    reg [4:0] lookup_width_q;

    always @ (posedge clk_i )
    if (rst_i)
        lookup_width_q <= 5'b0;
    else
    begin
        case (lookup_table_i)
        2'd0: lookup_width_q <= y_dc_width_w;
        2'd1: lookup_width_q <= y_ac_width_w;
        2'd2: lookup_width_q <= cx_dc_width_w;
        2'd3: lookup_width_q <= cx_ac_width_w;
        endcase
    end

    assign lookup_width_o = lookup_width_q;

    assign cfg_accept_o = 1'b1;
end
endgenerate


endmodule
