# tile-bleed-margin-generator

Automatically stretch out the 1px edge of each tile in a tile sheet to compensate for tile bleed in 2D game development.

This should solve rounding errors which can cause tiles to slightly bleed into their neighbors, such as the very common "gap between tiles" problem in Unity. The script started as a fork but I added so many features that it ended up quite different from [the original](https://github.com/cjonasw/tile-bleed-margin-generator).

## Dependencies

This script was written for bash and depends on ImageMagick (tested using `ImageMagick 6.9.7-4`). The `convert`, `montage` and `identify` commands must be in your PATH.

Until someone makes a Windows version (`.cmd` or `.ps`) you should be able to run it on Windows 10 using bash in the Windows Subsystem for Linux, provided you've installed ImageMagick within your virtual linux.

## Sample usage

    ./bleed.sh input.png output.png --tile-size 16 16 --bleed 3 --input-gap 4 4 --output-gap 1 1 --input-offset 20 20 --output-offset 3 3

The script determines the number of tiles based on the size of the file. It ignores content above and the the left of the specified `--input-offset`, and any leftover space that is smaller than a tile on the bottom right. See the sample files in the repository.

## Known issues

-   Unknown options or options with the wrong number of parameters produce unclear error messages.
-   The `--help` flag doesn't work properly because the command fails on missing arguments first. Mitigated by showing the usage on missing arguments.
