spritesheetFileName=$1
spritesheetFileType=$2
newFileSuffix=$3
spritesheetWidth=$4
spritesheetHeight=$5
tileSize=$6

rowCount=$(( spritesheetHeight / tileSize ))
columnCount=$(( spritesheetWidth / tileSize ))
numberOfTiles=$(( columnCount * rowCount ))
tileSizeWithPadding=$((tileSize + 2))

for (( i = 0; i < numberOfTiles; i++ )); do
sprites+=" ./temp/sprite-$i.png"
spriteBleeds+=" ./temp/sprite-bleed-$i.png"
done

rm -rf temp
mkdir temp
convert -crop "$tileSize"x"$tileSize" "$spritesheetFileName.$spritesheetFileType" ./temp/sprite.png
convert $sprites -set option:distort:viewport "$tileSizeWithPadding"x"$tileSizeWithPadding"-1-1 -virtual-pixel Edge -filter point -distort SRT 0 +repage ./temp/sprite-bleed.png
montage $spriteBleeds -tile "$columnCount"x"$rowCount" -geometry "$tileSizeWithPadding"x"$tileSizeWithPadding"-0-0 -background none "$spritesheetFileName$newFileSuffix.$spritesheetFileType"
rm -rf temp