## JPEG Decoder C Model

This a simple C model of a JPEG decoder that can decode baseline JPEG images.
The purpose of this is to provide a reference to test the digital HW design against.

It supports;
* YCbCr 4:4:4 (no chroma subsampling), 4:2:0 and monochrome images.
* Conversion to a bitmap file (PPM / P6 format).
* Optimised (Huffman tables) images.

It does not support (currently);
* Progressive
* YCbCr 4:2:2 chroma subsampling
* Restart markers
* App data, COM sections, will be ignored.


### Building / Usage
```
# Build
make

# Run
./jpeg my_image.jpg bitmap.ppm
```
