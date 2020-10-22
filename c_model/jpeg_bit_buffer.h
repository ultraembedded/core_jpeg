#ifndef JPEG_BIT_BUFFER_H
#define JPEG_BIT_BUFFER_H

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <assert.h>

#define dprintf

#ifndef TEST_HOOKS_BITBUFFER
#define TEST_HOOKS_BITBUFFER(x)
#endif

#ifndef TEST_HOOKS_BITBUFFER_DECL
#define TEST_HOOKS_BITBUFFER_DECL
#endif

//-----------------------------------------------------------------------------
// jpeg_bit_buffer:
//-----------------------------------------------------------------------------
class jpeg_bit_buffer
{
public:
    jpeg_bit_buffer() 
    {
        m_buffer = NULL;
        reset(-1);
    }

    void reset(int max_size = -1)
    {
        if (m_buffer)
        {
            delete [] m_buffer;
            m_buffer = NULL;
        }

        if (max_size <= 0)
            m_max_size = 1 << 20;
        else
            m_max_size = max_size;

        m_buffer = new uint8_t[m_max_size];
        memset(m_buffer, 0, m_max_size);
        m_wr_offset = 0;
        m_last      = 0;
        m_rd_offset = 0;
    }

    // Push byte into stream (return false if marker found)
    bool push(uint8_t b)
    {
        uint8_t last = m_last;

        // Skip padding
        if (last == 0xFF && b == 0x00)
            ;
        // Marker found
        else if (last == 0xFF && b != 0x00)
        {
            m_wr_offset--;
            return false;
        }
        // Push byte into buffer
        else
        {
            assert(m_wr_offset < m_max_size);
            m_buffer[m_wr_offset++] = b;
        }

        m_last = b;

        return true;
    }

    // Read upto 32-bit (aligned to MSB)
    uint32_t read_word(void)
    {
        if (eof())
            return 0;

        int byte   = m_rd_offset / 8;
        int bit    = m_rd_offset % 8; // 0 - 7
        uint64_t w = 0;
        for (int x=0;x<5;x++)
        {
            w |= m_buffer[byte+x];
            w <<= 8;
        }
        w <<= bit;
        return w >> 16;
    }

    void advance(int bits)
    {
        TEST_HOOKS_BITBUFFER(bits);
        m_rd_offset += bits;
    }

    bool eof(void)
    {
        return (((m_rd_offset+7) / 8) >= m_wr_offset);
    }

    TEST_HOOKS_BITBUFFER_DECL;

private:
    uint8_t *m_buffer;
    uint8_t  m_last;
    int      m_max_size;
    int      m_wr_offset;
    int      m_rd_offset; // in bits
};

#endif
