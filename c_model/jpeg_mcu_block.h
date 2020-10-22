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

        for (int coeff=0;coeff<64;coeff++)
        {
            // Read 32-bit word
            uint32_t input_word = m_bit_buffer->read_word();

            // Start with upper 16-bits
            uint16_t input_data = input_word >> 16;

            // Perform huffman decode on input data (code=RLE,num_bits)
            uint8_t code   = 0;
            int code_width = m_dht->lookup(table_idx + (coeff != 0), input_data, code);
            int coef_bits  = code & 0xF;

            // Move input point past decoded data
            if (coeff == 0)
                m_bit_buffer->advance(code_width + coef_bits);
            // End of block or ZRL (no coefficient)
            else if (code == 0 || code == 0xF0)
                m_bit_buffer->advance(code_width);
            else
                m_bit_buffer->advance(code_width + coef_bits);

            // Use remaining data for actual coeffecient
            input_data = input_word >> (16 - code_width);

            // DC
            if (coeff == 0)
            {
                input_data >>= (16 - code);

                int16_t dcoeff = decode_number(input_data, coef_bits) + olddccoeff;
                olddccoeff = dcoeff;
                block_out[samples++] = (0 << 16) | (dcoeff & 0xFFFF);
            }
            // AC
            else
            {
                // End of block
                if (code == 0)
                {
                    dprintf("SMPL: EOB\n");
                    coeff = 64;
                    break;
                }

                // The first part of the AC key_len is the number of leading zeros
                if (code == 0xF0)
                {
                    // When the ZRL code comes, it is regarded as 15 zero data
                    dprintf("SMPL: ZRL\n");
                    coeff += 15; // +1 in the loop
                    continue;
                }
                else if (code > 15)
                    coeff   += code >> 4;

                input_data >>= (16 - coef_bits);

                if (coeff < 64)
                {
                    int16_t acoeff = decode_number(input_data, coef_bits);
                    block_out[samples++] = (coeff << 16) | (acoeff & 0xFFFF);
                }
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
