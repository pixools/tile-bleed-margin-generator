convert -crop 16x16 spritesheet.png sprite.png
convert sprite-{0..1439}.png -set option:distort:viewport 48x48-16-16 -virtual-pixel Edge -filter point -distort SRT 0 +repage sprite-bleed.png
montage sprite-bleed-{0..1439}.png -tile 40x36 -geometry 48x48+0+0 -background none spritesheet-bleed.png
