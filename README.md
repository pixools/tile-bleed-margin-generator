# tile-bleed-margin-generator

Automatically stretch out the 1px edge of each tile in a tile sheet to compensate for tile bleed in 2D game development.

This should solve rounding errors which can cause tiles to slightly bleed into their neighbors, such as the very common "gap between tiles" problem in Unity.

## Dependencies

This script depends on ImageMagick (tested using ImageMagick 7). `convert`, `montage` and `identify` must be in your PATH.

Until someone makes a Windows version (`.cmd` or `.ps`) you should be able to run it using bash in the Windows Subsystem for Linux.

## Sample usage

    ./bleed.sh input.png output.png 16

...where `input.png` is a tile sheet with 16x16 tiles without any gap between tiles. If your tiles are not square, you can specify a tile height as a 4th argument.

The resulting `output.png` can then be used by some game engines specifying a 2px gap between tiles, and perhaps 1px offset from the top left corner for the first tile.
