#ifndef JPEG_DHT_H
#define JPEG_DHT_H

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <assert.h>

#define DHT_TABLE_Y_DC      0x00
#define DHT_TABLE_Y_DC_IDX  0
#define DHT_TABLE_Y_AC      0x10
#define DHT_TABLE_Y_AC_IDX  1
#define DHT_TABLE_CX_DC     0x01
#define DHT_TABLE_CX_DC_IDX 2
#define DHT_TABLE_CX_AC     0x11
#define DHT_TABLE_CX_AC_IDX 3

#define dprintf

//-----------------------------------------------------------------------------
// jpeg_dqt:
//-----------------------------------------------------------------------------
class jpeg_dht
{
public:
    jpeg_dht() { reset(); }

    void reset(void)
    {
        for (int i=0;i<4;i++)
            memset(&m_dht_table[i], 0, sizeof(t_huffman_table));
    }

    int process(uint8_t *data, int len)
    {
        uint8_t *buf = data;
        int consumed = 0;

        // DHT tables can be combined into one section (it seems)
        while (consumed <= (len-17))
        {
            // Huffman table info, first four MSBs represent table type (0 for DC, 1 for AC), last four LSBs represent table #
            uint8_t  table_info  = *buf++;

            int table_idx = 0;
            switch (table_info)
            {
                case DHT_TABLE_Y_DC:
                    table_idx = DHT_TABLE_Y_DC_IDX;
                    break;
                case DHT_TABLE_Y_AC:
                    table_idx = DHT_TABLE_Y_AC_IDX;
                    break;
                case DHT_TABLE_CX_DC:
                    table_idx = DHT_TABLE_CX_DC_IDX;
                    break;
                case DHT_TABLE_CX_AC:
                    table_idx = DHT_TABLE_CX_AC_IDX;
                    break;
                default:
                    assert(!"ERROR: Bad JPEG");
                    break;
            }
            dprintf("DHT (Table idx %d)\n", table_idx);

            // Reset table
            memset(&m_dht_table[table_idx], 0, sizeof(m_dht_table[0]));

            // Extract symbol count
            uint8_t symb_count[16];
            for (int x=0;x<16;x++)
            {
                symb_count[x] = *buf++;
                dprintf(" bit length: %d, symbols: %d\n", x, symb_count[x]);
            }

            // Extract table values
            // Build the Huffman map of (length, code) -> value
            uint16_t code = 0;
            int entry = 0;
            for (int x=0;x<16;x++)
            {
                for (int j=0;j<symb_count[x];j++)
                {
                    uint8_t dht_val = *buf++;
                    m_dht_table[table_idx].code[entry]     = code;
                    m_dht_table[table_idx].code_len[entry] = x+1;
                    m_dht_table[table_idx].value[entry++]  = dht_val;
                    dprintf(" %d: %x -> %x\n", entry, code, dht_val);

                    code++;
                }
                code <<= 1;
            }
            m_dht_table[table_idx].entries = entry;

            consumed = buf - data;
        }

        return buf - data;
    }

    // lookup: Perform huffman lookup (starting from bit 15 of w)
    int lookup(int table_idx, uint16_t w, uint8_t &value)
    {
        for (int i=0;i<m_dht_table[table_idx].entries;i++)
        {
            int      width   = m_dht_table[table_idx].code_len[i];
            uint16_t bitmap  = m_dht_table[table_idx].code[i];
            
            
            uint16_t shift_val = w >> (16-width);
            //printf("- %d: check against %04x ", width, shift_val);
            //print_bin(shift_val, width);
            //printf(" == %04x -> %02x\n", bitmap, value);
            if (shift_val == bitmap)
            {
                value   = m_dht_table[table_idx].value[i];
                return width;
            }
        }
        return 0;
    }

private:
    typedef struct
    {
        // 16-bit (max) code
        uint16_t code[255];
        // Code length
        uint8_t  code_len[255];
        // Value to translate to
        uint8_t  value[255];
        int      entries;
    } t_huffman_table;

    t_huffman_table m_dht_table[4];
};

#endif
