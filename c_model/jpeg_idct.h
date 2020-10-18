#ifndef JPEG_IDCT_H
#define JPEG_IDCT_H

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <assert.h>

//-----------------------------------------------------------------------------
// jpeg_idct:
//-----------------------------------------------------------------------------
class jpeg_idct
{
public:
    jpeg_idct() { reset(); }
    void reset(void) { }

    //-----------------------------------------------------------------------------
    // process: Perform inverse DCT on already dequantized data.
    // [Not quite sure who to attribute this implementation to...]
    //-----------------------------------------------------------------------------
    void process(int *data_in, int *data_out)
    {
        int s0,s1,s2,s3,s4,s5,s6,s7;
        int t0,t1,t2,t3,t4,t5,t6,t7;

        int working_buf[64];
        int *temp_buf = working_buf;

        // X - Rows
        for(int i=0;i<8;i++)
        {
            s0 = (data_in[0] + data_in[4])       * C4;
            s1 = (data_in[0] - data_in[4])       * C4;
            s3 = (data_in[2] * C2) + (data_in[6] * C6);
            s2 = (data_in[2] * C6) - (data_in[6] * C2);
            s7 = (data_in[1] * C1) + (data_in[7] * C7);
            s4 = (data_in[1] * C7) - (data_in[7] * C1);
            s6 = (data_in[5] * C5) + (data_in[3] * C3);
            s5 = (data_in[5] * C3) - (data_in[3] * C5);

            // Next row
            data_in += 8;

            t0 = s0 + s3;
            t3 = s0 - s3;
            t1 = s1 + s2;
            t2 = s1 - s2;
            t4 = s4 + s5;
            t5 = s4 - s5;
            t7 = s7 + s6;
            t6 = s7 - s6;

            s6 = (t5 + t6) * 181 / 256; // 1/sqrt(2)
            s5 = (t6 - t5) * 181 / 256; // 1/sqrt(2)

            *temp_buf++ = (t0 + t7) >> 11;
            *temp_buf++ = (t1 + s6) >> 11;
            *temp_buf++ = (t2 + s5) >> 11;
            *temp_buf++ = (t3 + t4) >> 11;
            *temp_buf++ = (t3 - t4) >> 11;
            *temp_buf++ = (t2 - s5) >> 11;
            *temp_buf++ = (t1 - s6) >> 11;
            *temp_buf++ = (t0 - t7) >> 11;
        }

        // Y - Columns
        temp_buf = working_buf;
        for(int i=0;i<8;i++)
        {
            s0 = (temp_buf[0] + temp_buf[32])     * C4;
            s1 = (temp_buf[0] - temp_buf[32])     * C4;
            s3 = temp_buf[16] * C2 + temp_buf[48] * C6;
            s2 = temp_buf[16] * C6 - temp_buf[48] * C2;
            s7 = temp_buf[8]  * C1 + temp_buf[56] * C7;
            s4 = temp_buf[8]  * C7 - temp_buf[56] * C1;
            s6 = temp_buf[40] * C5 + temp_buf[24] * C3;
            s5 = temp_buf[40] * C3 - temp_buf[24] * C5;

            t0 = s0 + s3;
            t1 = s1 + s2;
            t2 = s1 - s2;
            t3 = s0 - s3;
            t4 = s4 + s5;
            t5 = s4 - s5;
            t6 = s7 - s6;
            t7 = s6 + s7;

            s5 = (t6 - t5) * 181 / 256; // 1/sqrt(2)
            s6 = (t5 + t6) * 181 / 256; // 1/sqrt(2)

            data_out[0]  = ((t0 + t7) >> 15);
            data_out[56] = ((t0 - t7) >> 15);
            data_out[8]  = ((t1 + s6) >> 15);
            data_out[48] = ((t1 - s6) >> 15);
            data_out[16] = ((t2 + s5) >> 15);
            data_out[40] = ((t2 - s5) >> 15);
            data_out[24] = ((t3 + t4) >> 15);
            data_out[32] = ((t3 - t4) >> 15);
            
            temp_buf++;
            data_out++;
        }
        data_out -= 8;
    }

    static const int C1 = 4017; // cos( pi/16) x4096
    static const int C2 = 3784; // cos(2pi/16) x4096
    static const int C3 = 3406; // cos(3pi/16) x4096
    static const int C4 = 2896; // cos(4pi/16) x4096
    static const int C5 = 2276; // cos(5pi/16) x4096
    static const int C6 = 1567; // cos(6pi/16) x4096
    static const int C7 = 799;  // cos(7pi/16) x4096
};

#endif
