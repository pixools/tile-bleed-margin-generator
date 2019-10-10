#!/bin/bash

usage() {
	cat <<-EOM
		Usage: bleed INPUT_FILE OUTPUT_FILE [OPTIONS...]
		
		Extends the edge of of every tile in a tileset by 1px to avoid issues with
		neighboring tile bleeding and gaps between rendered tiles.
		
		Tested with ImageMagick 6.9.7-4
		
		Options must appear after the positional arguments:
		  -t, --tile-size XX YY         the size of the tiles
		                                (defaults to 16x16)
		  -b, --bleed XX                how much bleeding should be produced around
		                                each generated tile
		                                (defaults to 1)
		  -g, --input-gap XX YY         the horizontal and vertical gap between
		                                tiles in the input image
		                                (defaults to 0x0)
		  -o, --input-offset XX YY      the offset of the first tile from the
		                                top left corner of the input image
		                                (defaults to 0x0)
		  -G, --output-gap XX YY        the horizontal and vertical gap to leave
		                                between tiles in the output image as
		                                transparent pixels
		                                (defaults to 0x0)
		  -O, --output-offset XX YY     the margins added to the output image
		                                (defaults to 0x0)
		  -f, --force					overwrite the output file if it exists
		  -v, --verbose                 display computations during execution
		  -h, --help                    display this help text and exit
	EOM
}


#### INITIALIZE VARIABLES

positional_args=()

input_path=
input_tile_width=16
input_tile_height=16
input_offset_x=0
input_offset_y=0
input_gap_x=0
input_gap_y=0

output_path=
output_offset_x=0
output_offset_y=0
output_gap_x=0
output_gap_y=0
output_bleed=1


#### PARSE ARGUMENTS

if [[ $# -lt 2 ]] ; then
	echo "Missing arguments."
	usage
	exit 1
fi

input_path=$1
shift
output_path=$1
shift

while [[ $# > 0 ]] ; do
	case $1 in
		-t | --tile-size )
			shift
			input_tile_width=$1
			shift
			input_tile_height=$1
			;;
		-b | --bleed )
			shift
			output_bleed=$1
			;;
		-g | --input-gap )
			shift
			input_gap_x=$1
			shift
			input_gap_y=$1
			;;
		-o | --input-offset )
			shift
			input_offset_x=$1
			shift
			input_offset_y=$1
			;;
		-G | --output-gap )
			shift
			output_gap_x=$1
			shift
			output_gap_y=$1
			;;
		-O | --output-offset )
			shift
			output_offset_x=$1
			shift
			output_offset_y=$1
			;;
		-f | --force )
			force=true
			;;
		-v | --verbose )
			verbose=true
			;;
		-fv | -vf )
			force=true
			verbose=true
			;;
		-h | --help )
			usage
			exit
			;;
		* )
			# todo: make sure --help flag is always checked
			echo "Incorrect option sequence." >&2
			usage >&2
			exit 1
	esac
	shift
done


#### VALIDATE ARGUMENTS

if [[ ! -f $input_path ]] ; then
	echo "Input file not found." >&2; exit 1
fi

if [[ -e $output_path && $force != true ]] ; then
	echo "A file with the specified output path already exists." >&2; exit 1
fi

int_regex='^[0-9]+$'
assert_int() {
	if ! [[ $2 =~ $int_regex ]] ; then
		echo "$1 must be an integer" >&2; exit 1
	fi
}
assert_coords() {
	if ! [[ $2 =~ $int_regex && $3 =~ $int_regex ]] ; then
		echo "$1 must be two integers separated by a space" >&2; exit 1
	fi
}

assert_coords "--tile-size" $input_tile_width $input_tile_height
assert_int "--bleed" $output_bleed
assert_coords "--input-gap" $input_gap_x $input_gap_y
assert_coords "--input-offset" $input_offset_x $input_offset_y
assert_coords "--output-gap" $output_gap_x $output_gap_y
assert_coords "--output-offset" $output_offset_x $output_offset_y


#### BEGIN COMPUTATION

# ENABLE VERBOSE MODE IF DESIRED
if [[ $verbose == true ]] ; then
	set -x
fi

# GET IMAGE SIZE
input_file_width=`identify -format %w $input_path`
input_file_height=`identify -format %h $input_path`

# CROP MARGINS
input_right_margin=$(( ($input_file_width + $input_gap_x - $input_offset_x) % ($input_tile_width + $input_gap_x) ))
input_bottom_margin=$(( ($input_file_height + $input_gap_y - $input_offset_y) % ($input_tile_height + $input_gap_y) ))
input_usefull_width=$(( $input_file_width - $input_offset_x - $input_right_margin ))
input_usefull_height=$(( $input_file_height - $input_offset_y - $input_bottom_margin ))
crop_margins_geometry="${input_usefull_width}x${input_usefull_height}+${input_offset_x}+${input_offset_y}"

# SLICE INTO TILES
slice_width=$(($input_tile_width + $input_gap_x))
slice_height=$(($input_tile_height + $input_gap_y))
slice_to_tiles_geometry="${slice_width}x${slice_height}"

# REMOVE TILE GAP
crop_tile_gap_geometry="${input_tile_width}x${input_tile_width}+0+0"

# ADD BLEEDING
bleeding_width=$(($input_tile_width + (2 * $output_bleed) ))
bleeding_height=$(($input_tile_height + (2 * $output_bleed) ))
distort_bleed_geometry="${bleeding_width}x${bleeding_height}-${output_bleed}-${output_bleed}"

# ADD TILE GAP
output_tile_width=$(($bleeding_width + $output_gap_x ))
output_tile_height=$(($bleeding_height + $output_gap_y ))
output_tile_geometry="${output_tile_width}x${output_tile_height}+0+0"

# MERGE TILES
columns=$(( ($input_file_width + $input_gap_x - $input_offset_x) / ($input_tile_width + $input_gap_x) ))
rows=$(( ($input_file_height + $input_gap_y - $input_offset_y) / ($input_tile_height + $input_gap_y) ))

# REMOVE LAST GAP
output_usefull_width=$(( ($output_tile_width * $columns) - $output_gap_x ))
output_usefull_height=$(( ($output_tile_height * $rows) - $output_gap_y ))
crop_extra_gap_geometry="${output_usefull_width}x${output_usefull_height}+0+0"

# ADD MARGIN
output_total_width=$(($output_usefull_width + (2 * $output_offset_x) ))
output_total_height=$(($output_usefull_height + (2 * $output_offset_y) ))
output_size_geometry="${output_total_width}x${output_total_height}"

# DISABLE VERBOSE OUTPUT
{ set +x; } 2>/dev/null


#### SUBMIT TASK TO IMAGEMAGICK

convert $input_path \
	-crop $crop_margins_geometry +repage +gravity \
	-crop $slice_to_tiles_geometry +repage \
	-crop $crop_tile_gap_geometry +repage \
	-define distort:viewport=$distort_bleed_geometry -filter point -distort SRT 0 +repage \
	-background none -extent $output_tile_geometry miff:- |
montage - -tile ${columns}x${rows} -geometry +0+0 -background none +repage miff:- |
convert - \
	-crop $crop_extra_gap_geometry +repage \
	-gravity center -background none -extent $output_size_geometry \
	$output_path