# High throughput JPEG decoder

Github: [https://github.com/ultraembedded/core_jpeg](https://github.com/ultraembedded/core_jpeg)

This project is a JPEG decoder core for FPGA written in Verilog.

The purpose of this design was to replace a 3rd party JPEG decoder core used in my [Motion JPEG](https://en.wikipedia.org/wiki/Motion_JPEG) based [FPGA video player](https://github.com/ultraembedded/FPGAmp).  
Motion JPEG has worse compression performance than MPEG based video, but the complexity of the HW required is low enough that it can be used on low(-ish)-end FPGAs.

Video playback usually requires at least 25 frames per second, hence there is a budget of less than 40ms per JPEG frame.  
This fact drives the design choices taken for this implementation.

Clearly, the higher the resolution, the more pixels that must be produced from the JPEG decoder within that 40ms budget, so this core is designed to have high throughput in the output stages - with additional resources dedicated to the IDCT transform, and output re-ordering stages to facilitate this.

## Aims
1. Fast decode performance suitable for video playback
2. Support a minimal JPEG baseline feature set.
3. Be well tested (with verification against a reference C-model).
4. Map to FPGA resources such as BlockRAM, DSP macros wherever possible.


more to come ...
