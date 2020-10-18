#ifndef JPEG_MCU_BLOCK_H
#define JPEG_MCU_BLOCK_H

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <assert.h>

#include "jpeg_bit_buffer.h"
#include "jpeg_dht.h"

#define dprintf

//-----------------------------------------------------------------------------
// jpeg_mcu_block:
//-----------------------------------------------------------------------------
class jpeg_mcu_block
{
public:
    jpeg_mcu_block(jpeg_bit_buffer *bit_buf, jpeg_dht *dht)
    {
        m_bit_buffer = bit_buf;
        m_dht        = dht;
        reset();
    }

    void reset(void) { }

    //-----------------------------------------------------------------------------
    // decode: Run huffman entropy decoder on input stream, expand to DC + upto 
    //         63 AC samples.
    //-----------------------------------------------------------------------------
    int decode(int table_idx, int16_t &olddccoeff, int32_t *block_out)
    {
        int samples = 0;

        // Read word
        uint16_t w = m_bit_buffer->read_word();

        // Lookup DC value width
        // code = number of bits used for DC encoding
        uint8_t dc_bits = 0;
        m_bit_buffer->advance(m_dht->lookup(table_idx, w, dc_bits));

        // DC
        w = m_bit_buffer->read_word();
        m_bit_buffer->advance(dc_bits);
        w >>= (16 - dc_bits);

        int16_t dcoeff = decode_number(w, dc_bits) + olddccoeff;
        olddccoeff = dcoeff;
        block_out[samples++] = (0 << 16) | (dcoeff & 0xFFFF);

        // AC
        int l = 1;
        while (l < 64)
        {
            uint8_t code = 0;

            // Extract next token
            w = m_bit_buffer->read_word();
            m_bit_buffer->advance(m_dht->lookup(table_idx+1, w, code));

            // End of block
            if (code == 0)
            {
                dprintf("SMPL: EOB\n");
                break;
            }

            // The first part of the AC key_len is the number of leading zeros
            if (code == 0xF0)
            {
                // When the ZRL code comes, it is regarded as 15 zero data
                dprintf("SMPL: ZRL\n");
                l += 16;
                continue;
            }
            else if (code > 15)
            {
                l   += code >> 4;
                code = code & 0x0F;
            }

            int num_bits = code;

            w = m_bit_buffer->read_word();
            m_bit_buffer->advance(num_bits);
            w >>= (16 - num_bits);

            if (l < 64)
            {
                int16_t acoeff = decode_number(w, num_bits);
                block_out[samples++] = (l << 16) | (acoeff & 0xFFFF);
                l++;
            }
        }

        return samples;
    }

private:
    //-----------------------------------------------------------------------------
    // decode_number: Extract number from code / width
    //-----------------------------------------------------------------------------
    int16_t decode_number(uint16_t code, int bits)
    {   
        if (!(code & (1<<(bits-1))) && bits != 0)
        {
            code |= (~0) << bits;
            code += 1;
        }
        return code;
    }

private:
    jpeg_bit_buffer *m_bit_buffer;
    jpeg_dht *m_dht;

};

#endif
