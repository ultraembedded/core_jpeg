#ifndef JPEG_DQT_H
#define JPEG_DQT_H

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <assert.h>

// Zigzag table
static const int m_zigzag_table[]=
{
     0, 1, 8, 16,9, 2, 3,10,
    17,24,32,25,18,11, 4, 5,
    12,19,26,33,40,48,41,34,
    27,20,13, 6, 7,14,21,28,
    35,42,49,56,57,50,43,36,
    29,22,15,23,30,37,44,51,
    58,59,52,45,38,31,39,46,
    53,60,61,54,47,55,62,63,
    0
};

#define dprintf

//-----------------------------------------------------------------------------
// jpeg_dqt:
//-----------------------------------------------------------------------------
class jpeg_dqt
{
public:
    jpeg_dqt() { reset(); }

    //-------------------------------------------------------------------------
    // reset: Reset DQT tables
    //-------------------------------------------------------------------------
    void reset(void)
    {
        memset(&m_table_dqt[0], 0, 64 * 4);
    }

    //-------------------------------------------------------------------------
    // process: Store DQT table from input stream
    //-------------------------------------------------------------------------
    int process(uint8_t *data, int len)
    {
        uint8_t *buf = data;

        // Table number
        uint8_t  table_num = (*buf++) & 0x3;
        dprintf(" DQT: Table %d\n", table_num);

        for (int x=0;x<64;x++)
        {
            // 8-bit
            uint8_t qv = *buf++;
            dprintf(" %d: %x\n", x, qv);
            m_table_dqt[table_num][x] = qv;
        }

        return buf - data;
    }

    //-------------------------------------------------------------------------
    // lookup: DQT table entry lookup
    //-------------------------------------------------------------------------
    uint8_t lookup(int table_num, int position)
    {
        return m_table_dqt[table_num][position];
    }

    //-------------------------------------------------------------------------
    // process_samples: Multiply out samples and de-zigzag ready for IDCT
    // samples: (idx, value)
    //-------------------------------------------------------------------------
    void process_samples(int quant_table, int *sample_in, int *block_out, int count)
    {
        // Apply quantisation and zigzag
        memset(block_out, 0, sizeof(block_out[0])*64);
        for (int i=0;i<count;i++)
        {
            int16_t smpl      = (int16_t)(sample_in[i] & 0xFFFF);
            int   block_idx   = (sample_in[i] >> 16);
            dprintf("DEQ: %d: %d * %d -> %d @ %d\n", block_idx, smpl, lookup(quant_table,block_idx), smpl * lookup(quant_table,block_idx), m_zigzag_table[block_idx]);
            block_out[m_zigzag_table[block_idx]] = smpl * lookup(quant_table,block_idx);
        }
    }

private:
    uint8_t  m_table_dqt[4][64];
};

#endif
