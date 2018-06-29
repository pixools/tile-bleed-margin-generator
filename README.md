# tile-bleed-margin-generator
Automatically stretch out the 1px edge of each tile in a sprite sheet to compensate for tile bleed in 2D game development.

## bleed.sh

Change the script to be specific to your case.

### You'll need to figure out a few things:

1. First you need to know how big your tiles are; mine are *16x16* (`TILE_SIZE = 16`)
2. then how big your spritesheet is; mine is *640x576* (`SPRITESHEET_WIDTH = 640`, `SPRITESHEET_HEIGHT = 576`)
3. How many columns there are:
```
COLUMN_COUNT = (SPRITESHEET_WIDTH / TILE_SIZE)
```

so mine is: `(640/16)`

4. How many rows there are:

```
ROW_COUNT = (SPRITESHEET_HEIGHT / TILE_SIZE)
```

so mine is: `(576/16)`

5. How many tiles are in the spritesheet:

```
NUMBER_OF_TILES = COLUMN_COUNT * ROW_COUNT
```

so in my case I had to do: `(640/16)*(576/16)` which is 1440.

```
NUMBER_OF_TILES = 1440
```

6. You need the file name of the spritesheet too.

That's all you need. so now:

### Modify the script to your case

1. Change all instances of `16` to your `TILE_SIZE`
2. Change `spritesheet.png` to your file
3. Change all instances of `1439` to your `NUMBER_OF_TILES - 1` so in my case it was *`1439`* instead of `1440`. (This is due to indexing starting at 0)
4. Change all instances of `48` to your `TILESIZE` multiplied by 3 (`TILESIZE * 3` so mine was `16*3`)
5. Change all instances of `40` to your `COLUMN_COUNT`
6. Change all instances of `36` to your `ROW_COUNT`

Make sure your script is in the same directory as the file, open Terminal and `cd` to this folder and run:

`sh bleed.sh`

you should now have loads of files, but the only one you are interested in is:

`spritesheet-bleed.png`

## TODO: Improvements

Make all of these calculations automatic and based on arguments.
