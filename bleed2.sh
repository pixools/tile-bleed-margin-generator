spritesheetName=$1
spritesheetWidth=$2
spritesheetHeight=$3
tileSize=$4

rowCount=$(( spritesheetHeight / tileSize ))
colCount=$(( spritesheetWidth / tileSize ))
numTiles=$(( colCount * rowCount ))
tileSizeWithPadding=$((tileSize + 2))

for (( i = 0; i < numTiles; i++ )); do
sprites+=" sprite-$i.png"
spriteBleeds+=" sprite-bleed-$i.png"
done

convert -crop "$tileSize"x"$tileSize" "$spritesheetName" sprite.png
convert $sprites -set option:distort:viewport "$tileSizeWithPadding"x"$tileSizeWithPadding"-1-1 -virtual-pixel Edge -filter point -distort SRT 0 +repage sprite-bleed.png
montage $spriteBleeds -tile "$colCount"x"$rowCount" -geometry "$tileSizeWithPadding"x"$tileSizeWithPadding"-0-0 -background none "$spritesheetName"-bleed.png
