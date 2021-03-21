# tile-bleed-margin-generator
Automatically stretch out the 1px edge of each tile in a sprite sheet to compensate for tile bleed in 2D game development.

This script uses [ImageMagick](https://imagemagick.org/script/download.php).

## bleed.sh

Make sure your script is in the same directory as the file, open Terminal and `cd` to this folder and run (as an example):

`sh bleed.sh my-spritesheet.png 640 576 16` (`sh bleed.sh FILE_NAME WIDTH HEIGHT TILE_SIZE`)

## TODO: Improvements

Create a script to run this on all files called `*_working.png` (for example) - Loop files, get each image dimensions, run bleed.sh with that info.