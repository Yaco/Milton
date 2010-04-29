#!/bin/bash
# VERSION MODIFICADA POR FRANCO
#    dir2slideshow
#    Copyright 2004-2008 Scott Dylewski  <scott at dylewski.com>
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#

version='0.8.2'

changes () 
{
echo 'Changes:
0.8.2
	Write out pal option to output file if selected in dir2slideshow
	Recursive finds follow symbolic links and ignores hidden directories.
	Bug fix for spaces in filenames (thanks Ken Zutter)
	Fixed bug where .mp3 files were being treated as images (crossfade error)
	Fixed bug where other file formats would be included in the listing (thanks Mridul)
	Fixed bug where audio files were not included in output.
	Allow spaces in output files if spaces is used as filename
0.8.0 	
	Add audiobook option- looks for audio files and images & adds titles
	Allow wipe effect as default between images -w duration
	Allow decimals in crossfade duration.
	Allow two different subtitles -s or -s2
	Add random kenburns effect (-k)
	Output file is copied to screen while running
	Full paths are specified to images in output .txt file.
	Start of themes being implemented. See theme documentation.
	Add subtitle options to add path and/or filename. (Thanks Kenneth Weinert)
	Add recursive directory search. -R and -r (Thanks Kenneth Weinert)
	Removed seq calls for compatibility with FreeBSD
0.7.5 	Allow spaces in filenames.
0.7.4 	No changes
0.7.3	
	Passing -c 0 does not create crossfades.
	Added option -notitle 
	Added option to specify background color or image -b image.jpg
	Fix output of "backgound:0:black" on first line. 
	It should read "background:0::black"
0.7.2	Added option to have all subtitles the same -s
0.7.1	Reads .jpg .JPG .jpeg .png .PNG files in the specified directory
0.1.0	Change version number
0.0.1	Initial release'
}

help ()
{
echo "dir2slideshow $version"
echo "dir2slideshow is part of the dvd-slideshow set of tools."
echo 'Copyright 2004-2005 Scott Dylewski <scott at dylewski.com>'
echo 'http://freshmeat.net/dvdslideshow'
echo  '
dir2slideshow description: 
 Generates a listing of the pictures in a given directory for easy
 input to dvd-slideshow.

Usage:
dir2slideshow [-o <output_directory>] [-t time_per_picture] [-c duration]
 -n slideshow_name [-T] [-M] [-s subtitle_text] [-notitle] [-k] [-theme <themefile>] [-a <audiofile1>,<audiofile2>,...] <directory>
	
Options: 
 <directory>
	Input directory of pictures.

 -n slideshow_name
	Name of the slideshow.  This will be used in the title slide
	as well as for the output file name.
 
 [-o output_directory]
	Path to the directory where you want to output file written.
	No output directory chooses current directory.
 
 [-t time_per_picture]
	  Integer number of seconds that the picture will be visible
	  on the dvd movie. You can edit the output file to make
	  changes to specific lines. Default is 5 seconds.

 [-c duration]
	  Add a crossfade between every picture for duration seconds.
 		
 [-w duration]
	  Add a wipe effect between every picture for duration seconds.
 		
 [-T]	 Sort by the JPEG header picture taken date, then the file
	  modified date, and then the filename. Default sorts by 
	  name only

 [-M]	 Sort by the the file modified date, and then the filename.
	  Default sorts by name only.
 		
 [-s "subtitle text"]
	  Add default subtitle "subtitle_text" to every slide
	  Use "-s filename" to display filename as the subtitle.
	  Use "-s path" to display filename&path as the subtitle.

 [-s2 "subtitle text"]
	  Same as -s option, but adds subtitles to subtitle track 2
 		
 [-b background.jpg]
	  Use background.jpg as background image. Default is black.
 		
 [-notitle]	 Do not create a title slide.
 		
 [-r]	 Recursively search directories for images, 
	  creating one output file.
 		
 [-R]  (not working yet)
	  Recursively search directories for images, 
	  creating one output file for each directory.
 		
 [-k]	 Apply random kenburns effects to each slide

 [-p]	 Use PAL output video format instead of NTSC
 		
 [-theme themefile.theme]  BETA
	  Use theme themefile.theme for consistent look & feel

 [-a <audiofile1>,<audiofile2>,...]
	  Use the following audio files in the slideshow.
	  Files will be played sequentially for the duration of 
	  the slideshow. Use quotes if you have spaces in filenames.
 		
 [-B]  Use audiobook format.  This will look for individual audio files
	along with images, and also add titles.  You wil probably have to
	modify the output to your liking, but this should give you a start.
	(alpha!) do not use yet.

 -h or -help 
   Prints this help. 
'
}

if [ $# -lt 1 ]; then
	help
	exit 1
fi

set_variables ()
{
	## check for config variables:
	config1=`echo "$1" | cut -d= -f1 | tr -d [:blank:]`
	config2=`echo "$1" | tr '\t' ' ' | cut -d= -f2 | tr -d '\047' | tr -d '\042' | awk -F' #' '{print $1}' | tr -d [:blank:]`
	[ -n "$2" -a "$2" == 1 ] && noecho=1 || noecho=0
	## check for global configuration variables:
	case "$config1" in 
		# title
#		title_font) title_font="$config2" ; [ "$noecho" -eq 0 ] && echo "title_font=$title_font" ;;
#		subtitle_font) subtitle_font="$config2" ; [ "$noecho" -eq 0 ] && echo "subtitle_font=$subtitle_font" ;;
		title_font_size) title_font_size="$config2" ; [ "$noecho" -eq 0 ] && echo "title_font_size=$title_font_size" ;;
		title_font_color) title_font_color="$config2" ; [ "$noecho" -eq 0 ] && echo "title_font_color=$title_font_color" ;;
		# top title
		toptitle_font_size) toptitle_font_size="$config2" ; [ "$noecho" -eq 0 ] && echo "toptitle_font_size=$toptitle_font_size" ;;
		toptitle_font_color) toptitle_font_color="$config2" ; [ "$noecho" -eq 0 ] && echo "toptitle_font_color=$toptitle_font_color" ;;
		toptitle_bar_height) toptitle_bar_height="$config2" ; [ "$noecho" -eq 0 ] && echo "toptitle_bar_height=$toptitle_bar_height" ;;
		toptitle_text_location_x) toptitle_text_location_x="$config2" ; [ "$noecho" -eq 0 ] && echo "toptitle_text_location_x=$toptitle_text_location_x" ;;
		toptitle_text_location_y) toptitle_text_location_y="$config2" ; [ "$noecho" -eq 0 ] && echo "toptitle_text_location_y=$toptitle_text_location_y" ;;
		# bottom title
		bottomtitle_font_size) bottomtitle_font_size="$config2" ; [ "$noecho" -eq 0 ] && echo "bottomtitle_font_size=$bottomtitle_font_size" ;;
		bottomtitle_font_color) bottomtitle_font_color="$config2" ; [ "$noecho" -eq 0 ] && echo "bottomtitle_font_color=$bottomtitle_font_color" ;;
		bottomtitle_bar_location_y) bottomtitle_bar_location_y="$config2" ; [ "$noecho" -eq 0 ] && echo "bottomtitle_bar_location_y=$bottomtitle_bar_location_y" ;;
		bottomtitle_bar_height) bottomtitle_bar_height="$config2" ; [ "$noecho" -eq 0 ] && echo "bottomtitle_bar_height=$bottomtitle_bar_height" ;;
		bottomtitle_text_location_x) bottomtitle_text_location_x="$config2" ; [ "$noecho" -eq 0 ] && echo "bottomtitle_text_location_x=$bottomtitle_text_location_x" ;;
		bottomtitle_text_location_y) bottomtitle_text_location_y="$config2" ; [ "$noecho" -eq 0 ] && echo "bottomtitle_text_location_y=$bottomtitle_text_location_y" ;;
		## dir2slideshow options:
		slideshow_background) background="$config2" ; [ "$noecho" -eq 0 ] && echo "background=$background" ;;
		title_background) title_background="$config2" ; [ "$noecho" -eq 0 ] && echo "title_background=$title_background" ;;
		crossfade) crossfade="$config2" ; [ "$noecho" -eq 0 ] && echo "crossfade=$crossfade" ;;
		wipe) wipe="$config2" ; [ "$noecho" -eq 0 ] && echo "wipe=$wipe" ;;
		kenburns) kenburns="$config2" ; [ "$noecho" -eq 0 ] && echo "kenburns=$kenburns" ;;
		pal) pal="$config2" ; [ "$noecho" -eq 0 ] && echo "pal=$pal" ;;
		slide_duration) slide_duration="$config2" ; [ "$noecho" -eq 0 ] && echo "slide_duration=$slide_duration" ;;
		title_type) title_type="$config2" ; [ "$noecho" -eq 0 ] && echo "title_type=$title_type" ;;
		slideshow_audio) audio_list="$config2" ; [ "$noecho" -eq 0 ] && echo "audio_list=$audio_list" ;;
		subtitle) subtitle="$config2" ; [ "$noecho" -eq 0 ] && echo "subtitle=$subtitle" ;;
		subtitle2) subtitle2="$config2" ; [ "$noecho" -eq 0 ] && echo "subtitle2=$subtitle2" ;;
		slideshow_end) slideshow_end[$end]="$config2" ; [ "$noecho" -eq 0 ] && echo "slideshow_end[$end]=${slideshow_end[$end]}"; end=$(($end+1)) ;;
		audiobook) audiobook="$config2" ; [ "$noecho" -eq 0 ] && echo "audiobook=$audiobook" ;;
	esac
}

full_path ()   # from Shea Martin  with fix by Ken Zutter for spaces in filenames
{
if [ -f "$1" ]; then
	DIR="$(dirname "$1")"
	DIR=$(cd "$DIR" && pwd)
	FILE="$(basename "$1")"
	RSLT=$?
	echo "$DIR/$FILE"
	return $RSLT
	
elif [ -d "$1" ]; then
	cd "$DIR" && pwd && cd $OLDPWD
	return $?

else
	echo "unknown file: $1"
	return 1
fi
}

echo "[dir2slideshow] dir2slideshow version $version"

## setup initial variables:
LANG=POSIX
debug=0  # 1 or 0
crossfade=0
wipe=0
slide_duration=5
output_dir="."
input_dir=""
name=''
sortmethod=''
title=1
background=''
title_background=''
audiobook=0
kenburns=0
vcd=0; svcd=0
theme=''
themedir='/opt/dvd-slideshow/themes' # LSB/FHS compliant. see http://www.pathname.com/fhs/pub/fhs-2.3.html#OPTADDONAPPLICATIONSOFTWAREPACKAGES
local_themedir=~/.dvd-slideshow/themes # location of local themes directory (do not use quotes)
title_type='title'
audio_list=''
recursive_single=0
recursive_multiple=0
end=1
pal=0  # default to ntsc
sortmethod="name"  # sort by filename as default sort method

for arg
do
	case "$arg" in
	-i) shift; input_dir="$1" ; shift ;;
	-n) shift; commandline_name="$1" ; shift ;;
	-s) shift; commandline_subtitle="$1" ; shift ;;
	-s2) shift; commandline_subtitle2="$1" ; shift ;;
	-b) shift; commandline_background="$1" ; shift ;;
	-tb) shift; commandline_title_background="$1" ; shift ;;
	-notitle) commandline_title=0 ; shift ;;
	-B) commandline_audiobook=1 ; shift ;;
	-k) commandline_kenburns=1 ; shift ;;
	-r) commandline_recursive_single=1 ; shift ;;
	-R) commandline_recursive_multiple=1 ; shift ;;
	-vcd) vcd=1 ; shift ;;
	-svcd) svcd=1 ; shift ;;
	-p) commandline_pal=1 ; shift ;;  # required if -k specified.
	-n) commandline_pal=0 ; shift ;;  # required if -k specified.
	-o) shift; output_dir="$1"; shift ;;
        -t) shift; commandline_duration="$1"; shift ;; 
        -T) sortmethod="taken_date"; shift ;; 
        -M) sortmethod="modified_date"; shift ;; 
        -S) sortmethod="normal"; shift ;; 
        -c) shift; commandline_crossfade="$1"; shift ;; 
        -w) shift; commandline_wipe="$1"; shift ;; 
        -theme) shift; theme="$1"; shift ;; 
        -a) shift; commandline_audio_list="$1"; shift ;; 
	-h) help ; exit 0 ; shift ;;
	-?) help ; exit 0 ; shift ;;
	-help) help ; exit 0 ; shift ;;
	esac
done

## read in theme file:
if [ -n "$theme" ] && [ "$theme" != 'default' ] ; then
	# check if directory
	if [ -d "$theme" ] ; then
		themedir="$theme"
		themefile="`ls -1 "$theme"/*.theme 2> /dev/null | tail -n 1`"
		if [ -z "$themefile" ] ; then
			echo "[dir2slideshow] Found theme directory: $themedir"
			echo "[dir2slideshow] ERROR: theme directory does not contain a .theme file!"
			exit 1
		else
			echo "[dir2slideshow] setting theme file to $theme"
		fi
	elif [ -f "$theme" ] ; then
		themefile="`full_path "$theme"`"
		themedir="`dirname "$theme"`"
		echo "[dir2slideshow] using theme file $theme"
	else
		# check in default theme directory:
		if [ -d "$themedir"/"$theme" ] ; then
			themedir="$themedir"/"$theme"
			themefile="`ls -1 "$themedir"/*.theme 2> /dev/null | tail -n 1`"
			if [ -z "$themefile" ] ; then
				echo "[dir2slideshow] Found theme directory: $themedir"
				echo "[dir2slideshow] ERROR: theme directory does not contain a .theme file!"
				exit 1
			else
				echo "[dir2slideshow] setting theme file to $themefile"
			fi
		# check in local theme directory
		elif [ -d "$local_themedir"/"$theme" ] ; then
			themedir="$local_themedir"/"$theme"
			themefile="`ls -1 "$themedir"/*.theme 2> /dev/null | tail -n 1`"
			if [ -z "$themefile" ] ; then
				echo "[dir2slideshow] Found theme directory: $themedir"
				echo "[dir2slideshow] ERROR: theme directory does not contain a .theme file!"
				exit 1
			else
				echo "[dir2slideshow] setting theme file to $themefile"
			fi
		else
			echo "[dir2slideshow] ERROR!  Bad theme name (not found)"
			exit 1
		fi
	fi
	echo "[dir2slideshow] Reading theme file..."
	while read thisline
	do
	  set_variables "${thisline}" 1
	  it=`set_variables "${thisline}" 0`
	  if [ -n "$it" ] ; then
		echo "[dir2slideshow] Set variable $it"
	  fi
	done < "$themefile"	
fi
			
## over-ride theme file with command-line options:
[ -n "$commandline_name" ] && name="$commandline_name"
[ -n "$commandline_subtitle" ] && subtitle="$commandline_subtitle"
[ -n "$commandline_subtitle2" ] && subtitle2="$commandline_subtitle2"
[ -n "$commandline_background" ] && background="$commandline_background"
[ -n "$commandline_title_background" ] && title_background="$commandline_title_background"
[ -n "$commandline_title" ] && title="$commandline_title"
[ -n "$commandline_kenburns" ] && kenburns="$commandline_kenburns"
[ -n "$commandline_pal" ] && pal="$commandline_pal"
[ -n "$commandline_duration" ] && slide_duration="$commandline_duration"
[ -n "$commandline_crossfade" ] && crossfade="$commandline_crossfade"
[ -n "$commandline_wipe" ] && wipe="$commandline_wipe"
[ -n "$commandline_audio_list" ] && audio_list="$commandline_audio_list"
[ -n "$commandline_recursive_single" ] && recursive_single="$commandline_recursive_single"
[ -n "$commandline_recursive_multiple" ] && recursive_multiple="$commandline_recursive_multiple"
[ -n "$commandline_audiobook" ] && audiobook="$commandline_audiobook"

if [ -z "$input_dir" ] ; then
	input_dir="$1"
fi
if [ -z "$input_dir" ] ; then
	echo '[dir2slideshow] Error: No input directory specified'
elif [ ! -d "$input_dir" ] ; then
	echo "[dir2slideshow] Error: Input directory is not a real directory: $input_dir"
fi

## check_rm checks to see if the file exists before it's deleted:
check_rm ()
{
	if [ -f "$1" ] ; then
		rm "$1"
	fi
}

## check for the necessary programs:
checkforprog ()
{
        it=`which "$1"`
        if [ -z "$it" ] ; then
                echo "[dir2slideshow] ERROR: $1 not found! "
                echo "[dir2slideshow] Check the dependencies and make sure everything is installed."
                exit 1
        fi
}

cleanup ()
{
	## clean up temporary files
	check_rm "$output_dir"/imagelist.txt
	check_rm "$output_dir/filelist_sorted.txt"
	check_rm "$output_dir/txtlist.txt"
	check_rm "$output_dir/audiolist.txt"
	echo "[dir2slideshow] Done!"
}

forcequit () ## function gets run when we have some sort of forcequit...
{
	## clean up temporary files
	cleanup
	exit 1
}


imagewidth ()
{
        it="`identify -format %w "$1"`"
        it="$(( $it * $sq_pixel_multiplier / 1000 ))"
        echo "$it"
}


imagewidth_sq ()
{
        it="`identify -format %w "$1"`"
        echo "$it"
}


imageheight ()
{
        it="`identify -format %h "$1"`"
        echo "$it"
}

fileecho ()
{
	echo "$*" >> "$outfile"
        echo "$*"
}


autocrop_percent ()
{
                # figure out whether to autocrop the image or not
                image_width=`imagewidth "$1"`
                image_height=`imageheight "$1"`
                ratio="$(( 1000* $image_width / $image_height ))"
                out_ratio="$(( 1000* $dvd_width / $dvd_height ))"
                if [ "$ratio" -lt "$out_ratio" ] ; then
                        # image too tall, crop top/bottom
			# calculate new height based on existing width:
			new_image_height=$(( $image_width * $dvd_height / $dvd_width ))
#			echo "new_image_height=$new_image_height"
			percent=$(( 100 * $new_image_height / $image_height ))	
                elif [ "$ratio" -gt "$out_ratio" ] ; then
                        # image too wide, crop sides
			# calculate new width based on existing height:
			new_image_width=$(( $image_height * $dvd_width / $dvd_height ))
#			echo "new_image_width=$new_image_width"
			percent=$(( 100 * $new_image_width / $image_width ))	
		else
			# no cropping of image needed!
			percent=100
                fi
#		echo "image_width=$image_width image_height=$image_height ratio=$ratio out_ratio=$out_ratio percent=$percent"
		echo "$percent"
}


trap 'forcequit' INT
trap 'forcequit' KILL
trap 'forcequit' TERM

if [ "$kenburns" != "0" ] ; then
	kenburns=1
	if [ -z "$pal" ] ; then
		echo "[dir2slideshow] WARNING: you must specify pal or ntsc"
		echo "[dir2slideshow]    with the -p 1/0 option when using -k"
		echo "[dir2slideshow]    assuming NTSC."
		pal=0
	fi
fi

if [ "$pal" == 1 ] ; then
        framerate='25'
        frames_per_sec=25000  # in ms
        if [ "$vcd" -eq 1 ] ; then
                dvd_width='352' ; dvd_height='288'
                resolution='352x288'
        elif [ "$svcd" -eq 1 ] ; then
                dvd_width='480' ; dvd_height='576'
                resolution='480x576'
        else
                dvd_width='720' ; dvd_height='576'
                resolution='720x576'
        fi
else  ## NTSC
        framerate='29.97'
        frames_per_sec=29970  # in ms
        if [ "$vcd" -eq 1 ] ; then
                dvd_width='352' ; dvd_height='240'
                resolution='352x240'
        elif [ "$svcd" -eq 1 ] ; then
                dvd_width='480' ; dvd_height='480'
                resolution='480x480'
        else
                dvd_width='720' ; dvd_height='480'
                resolution='720x480'
        fi
fi
aspect_ratio="4:3"
resize_factor=`awk -vw=$dvd_width -vh=$dvd_height -var=$aspect_ratio 'BEGIN{if (ar=="4:3"){ar=4/3} else {ar=16/9};printf "%0.2f", (100/((h/w)*(ar)));exit;}'`
sq_to_dvd_pixels="${resize_factor}x100%"
sq_pixel_multiplier=$( printf %5.0f $( echo "scale=0; 10 * $resize_factor" | bc ) )


# sanity checking 
# did the user give us a valid input file to work with?
# if [ ! -d "$input_dir" ]; then
# 	# it's not a directory!
#         echo "[dir2slideshow] ERROR: Bogus input directory (-i $input_dir)!"
#         exit 1;
# fi
if [ -z "$name" ]; then
        echo "[dir2slideshow] WARNING: No slideshow name specified using -n <name>"
	name="$( dirname "$input_dir"/. )"
	name="$( echo $name | awk -F/ '{print $NF}')"
	echo "[dir2slideshow] Using slideshow name= $name"
fi

# make sure $input_dir has no trailing slash
input_dir=`echo "$input_dir" | sed -e 's/\/$//'`;

## check to make sure the "album" name is ok?
if [ -z "$output_dir" ]; then
        # no output directory specified!
        echo "[dir2slideshow] WARNING: Invalid output destination (-o $output_dir)!";
        echo "[dir2slideshow]          Using `pwd` instead.";
        output_dir="`pwd`";
fi
if [ ! -d "$output_dir" ]; then
        # I'm sure it was a simple typo.
        echo "[dir2slideshow] WARNING: Invalid output destination (-o $output_dir)!";
        echo "[dir2slideshow]          Using $input_dir instead.";
        output_dir="$input_dir";
fi
                                                                                
# make sure $output_dir has no trailing slash
output_dir=`echo "$output_dir" | sed -e 's/\/$//'`;

#outfile="$output_dir"/"`echo "$name" | sed -e 's/ /_/g'`.txt"  
outfile="$output_dir"/"$name".txt

echo "[dir2slideshow] Input directory = $input_dir"
echo "[dir2slideshow] Slideshow name = $name"
echo "[dir2slideshow] Output file = $outfile"

## now, summarize settings:
if [ 1 ] ; then
	echo [dir2slideshow] subtitle="$subtitle"
	echo [dir2slideshow] subtitle2="$subtitle2"
	echo [dir2slideshow] background="$background"
	echo [dir2slideshow] title_background="$title_background"
	echo [dir2slideshow] title="$title"
	echo [dir2slideshow] kenburns="$kenburns"
	echo [dir2slideshow] pal="$pal"
	echo [dir2slideshow] output_dir="$output_dir"
	echo [dir2slideshow] slide_duration="$slide_duration"
	echo [dir2slideshow] sortmethod="$sortmethod"
	echo [dir2slideshow] crossfade="$crossfade"
	echo [dir2slideshow] wipe="$wipe"
	echo [dir2slideshow] title_type="$title_type"
	echo [dir2slideshow] themefile="$themefile"
	echo [dir2slideshow] audio_list="$audio_list"
fi

## get the total number of pictures:
if [ "$recursive_single" == 1 ] ; then
	# need to list all images under this directory.  
	# put them all in one slideshow
	# do not display images under .thumbs or .thumbnails directories

	# first, get list of directories:
	find "$input_dir" -type d | grep --invert-match -e '\.' | sort > "$output_dir"/directory_list.txt
	check_rm "$output_dir"/imagelist.txt
	check_rm "$output_dir"/audiolist.txt
#	check_rm "$output_dir"/txtlist.txt
	while read directory
	do
		find "$directory" -maxdepth 1 -type f -prune \( -name \*.JPG -o -name \*.jpg -o -name \*.png -o -name \*.PNG -o -name \*.jpeg \) | sort >> "$output_dir"/imagelist.txt
		find "$directory" -maxdepth 1 -type f -prune \( -name \*.mp3 -o -name \*.ogg \) | sort >> "$output_dir"/audiolist.txt
#		find "$directory" -maxdepth 1 -type f \( -name \*.txt \) -exec ls -1 {} \; | sort >> "$output_dir"/txtlist.txt
	done < "$output_dir"/directory_list.txt	

	pictures=`wc -l "$output_dir"/imagelist.txt | awk '{print $1}'`
	audiofiles=`wc -l "$output_dir"/audiolist.txt | awk '{print $1}'`
#	txtfiles=`wc -l "$output_dir"/txtlist.txt | awk '{print $1}'`
	echo "[dir2slideshow] Total pictures found = $pictures"
	echo "[dir2slideshow] Total audio files found = $audiofiles"
#	echo "[dir2slideshow] Total text files found = $txtfiles"
	## now, join the audio files and images:

elif [ "$recursive_multiple" == 1 ] ; then
	echo "[dir2slideshow] -R not supported yet"; exit 1
	# do find, then check each file if it is a directory:
else  # default case
	# ok, we need to follow links, but don't do recursive directory searching
	find "$input_dir" -maxdepth 1 \( -type f -o -type l \) \( -name \*.JPG -o -name \*.jpg -o -name \*.png -o -name \*.PNG -o -name \*.jpeg \) | sort > "$output_dir"/imagelist.txt
	find "$input_dir" -maxdepth 1 \( -type f -o -type l \) \( -name \*.mp3 -o -name \*.ogg \) | sort > "$output_dir"/audiolist.txt

	pictures=`wc -l "$output_dir"/imagelist.txt | awk '{print $1}'`
	audiofiles=`wc -l "$output_dir"/audiolist.txt | awk '{print $1}'`
#	txtfiles=`wc -l "$output_dir"/txtlist.txt | awk '{print $1}'`
	echo "[dir2slideshow] Total pictures found = $pictures"
	echo "[dir2slideshow] Total audio files found = $audiofiles"
#	echo "[dir2slideshow] Total text files found = $txtfiles"
	## now, join the audio files and images:
	if [ "$audiobook" == 1 ] ; then
		cat "$output_dir"/imagelist.txt "$output_dir"/audiolist.txt | sort > "$output_dir"/filelist.txt
		mv "$output_dir"/filelist.txt "$output_dir"/imagelist.txt
		sortmethod=''
	fi
fi

# make sure we found some images:
if [ "$pictures" -eq 0 ] ; then
	echo "[dir2slideshow] ERROR: No pictures found.  Check your settings and try again."
	exit 1
fi

## sort the pictures:

echo "[dir2slideshow] Sorting pictures..."
if [ "$sortmethod" == 'taken_date' ] ; then
	## sort by taken date:
	checkforprog jhead
	check_rm "$output_dir"/filelist_date.txt
	for (( i=1 ; i<=pictures ; i++ )) ; do
		file=`sed -n "$i"p "$output_dir"/imagelist.txt`
		taken=`jhead "$file" | grep 'Date/Time' | awk -F': ' '{print $2}'`
		modified=`jhead "$file" | grep 'File date' | awk -F': ' '{print $2}'`
		if [ -n "$taken" ] ; then
			echo "$file: $taken" >> "$output_dir"/filelist_date.txt
		else
			echo "[dir2slideshow] No picture taken date in $file."
#			echo "[dir2slideshow] Using modification date!"
			echo "$file: $modified" >> "$output_dir"/filelist_date.txt
		fi
	done	
	## sort:
	sort -k 2,3 -d "$output_dir"/filelist_date.txt > "$output_dir"/filelist_sorted.txt

elif [ "$sortmethod" == 'modified_date' ] ; then
	## sort by modified date
	check_rm "$output_dir"/filelist_date.txt
	for (( i=1 ; i<=pictures ; i++ )) ; do
		file=`sed -n "$i"p "$output_dir"/imagelist.txt`
		modified_day=`ls -l --full-time "$file" | awk '{print $6}'`
		modified_time=`ls -l --full-time "$file" | awk '{print $7}'`
#		echo "modified_day=$modified_day"
#		echo "modified_time=$modified_time"
		echo "$file: $modified_day $modified_time" >> "$output_dir"/filelist_date.txt
	done	
	## sort:
	sort -k 2,3 -d "$output_dir"/filelist_date.txt > "$output_dir"/filelist_sorted.txt
else
	## sort by name (should be done by ls -l)
	mv "$output_dir"/imagelist.txt "$output_dir"/filelist_sorted.txt	
fi
check_rm "$output_dir"/filelist_date.txt

## main loop:
# kenburns constants:
# now, it seems the kenburns effect isn't very smooth if we zoom
# and pan at the same time.  So, we'll have two different versions:
# 1. zoom only (random center and amount)
# 2. pan only (random locations and amount)
# 3. scroll? up/down for panoramas? (not yet)

min_kb_size_percent=80

echo "#########################################"
if [ -n "$background" ] && [ -f "$background" ] ; then
	background="`full_path "$background"`"
elif [ -n "$background" ] ; then # either color local file
	if [ -f "$themedir/$background" ] ; then
		background="$themedir/$background"
	fi
elif [ -z "$background" ] ; then
	background=black
fi
if [ -n "$title_background" ] && [ -f "$title_background" ] ; then
	title_background="`full_path "$title_background"`"
elif [ -n "$title_background" ] ; then # either color local file
	if [ -f "$themedir/$title_background" ] ; then
		title_background="$themedir/$title_background"
	fi
fi

check_rm "$outfile"
if [ "$pal" == "1" ] ; then
	fileecho "pal=1"
fi
if [ -n "$themefile" ] ; then
	fileecho "theme=$themefile"
fi
if [ "$kenburns" == "1" ] ; then
	fileecho "high_quality=1"  # force high-quality mode for slow kenburns effects?
fi

## set system variables
if [ -n "$title_background" ] ; then
	# set title background separate from slideshow background:
	fileecho "background:0::$title_background"
else
	fileecho "background:0::$background"
fi

#[ -n "$title_font" ] && fileecho "title_font=$title_font"
#[ -n "$subtitle_font" ] && fileecho "subtitle_font=$subtitle_font"

name_converted="$( echo $name | sed -e 's/_/ /g' )"
#name_converted="$name"

## if title is wanted:
if [ "$title" -eq 1 ] ; then
	[ -n "$title_font_color" ] && fileecho "title_font_color=$title_font_color"
	[ -n "$title_font_size" ] && fileecho "title_font_size=$title_font_size"
	fileecho "background:1"
	fileecho "fadein:1"
	if [ "$title_type" == 'titlebar' ] ; then
		fileecho "bottomtitle_bar_height=0" # no bottom title for now
		fileecho "titlebar:$slide_duration:$name_converted"
	else
		fileecho "title:$slide_duration:$name_converted"
	fi
	fileecho "background:0::$background" 
	fileecho "fadeout:1"
	fileecho "background:2"
fi

## write audio list to file:
# audio_list is passed via the command-line or input file
# audiolist.txt is created from the directory searching
if [ -n "$audio_list" ] ; then
	echo "$audio_list" | sed -e 's/,/\n/g' |
	while read file
	do
		if [ -f "$file" ] ; then
			audio_file="$( full_path "$file" )"
		else 
			# assume it's in the theme direcotry:
			audio_file="$themedir"/"$file"
			if [ ! -f "$audio_file" ] ; then
				echo "[dir2slideshow] ERROR! Audio file not found:"
				echo "[dir2slideshow] $file"
			fi
		fi
		fileecho "$audio_file"':1:fadein:2:fadeout:2'
	done
elif [ -f "$output_dir/audiolist.txt" ] ; then
	# command-line audio supercedes audio in directory at this point!
	while read file
	do
		if [ -f "$file" ] ; then
			audio_file="$( full_path "$file" )"
		else 
			# assume it's in the theme direcotry:
			audio_file="$themedir"/"$file"
			if [ ! -f "$audio_file" ] ; then
				echo "[dir2slideshow] ERROR! Audio file not found:"
				echo "[dir2slideshow] $file"
			fi
		fi
		fileecho "$audio_file"':1:fadein:2:fadeout:2'
	done < "$output_dir/audiolist.txt"

fi
fileecho "fadein:1"

total_lines=`wc -l "$output_dir"/filelist_sorted.txt | awk '{print $1}'`
j=0
chapter=1


# ACA TOMA LOS VALORES DE DURACION DE LOS ARCHIVOS

vuelta=0
ant=0

for x in `ls $input_dir`; do
	let vuelta=$vuelta+1
	x=`echo $x | cut -d "-" -f2 |cut -d "." -f1`
	x="$(echo $x | sed 's/0*//')"
	let valor=$x-$ant
	duracion[$vuelta]=$valor
	echo "Duracion de diapositiva $vuelta: ${duracion[$vuelta]} segundos"
	ant=$x
done

vuelta=1

for (( i=1 ; i<=total_lines ; i++ )) ; do
	file="`sed -n "$i"p "$output_dir"/filelist_sorted.txt | awk -F: '{print $1}'`"
	file="`full_path "$file"`"
	filetype=$( echo "$file" | awk -F. '{print $NF}')
	## write to file:
	if [ "$filetype" == 'mp3' ] ; then
		if [ "$audiobook" == 1 ] ; then
			fileecho "$file:1"
			book_title="$name_converted"
			fileecho "titlebar:audio:$book_title:Chapter $chapter"
			chapter=$(( $chapter + 1 ))
#		else
#			fileecho "$file:1"
		fi
	elif [ "$filetype" == 'txt' ] ; then
		echo "found text file"
	else
		if [ "$kenburns" == "1" ] ; then
			autocrop_size_percent=`autocrop_percent "$file"`
			if [ "$autocrop_size_percent" -lt "$min_kb_size_percent" ] ; then
				# probably a portrait image, don't do auto kenburns?
				kenburns_args=""
	#			echo "autocrop_size_percent=$autocrop_size_percent"
			else	
				# use autocrop as largest crop possible
				large_kb_size_percent="$autocrop_size_percent"
				if [ "$large_kb_size_percent" -gt "$min_kb_size_percent" ] ; then 
					delta_kb_size_percent=$(( $large_kb_size_percent - $min_kb_size_percent ))
					small_kb_size_percent=$min_kb_size_percent
				else
					delta_kb_size_percent=1
					small_kb_size_percent=$min_kb_size_percent
				fi
				# generate random start and end between these two limits:
				myrand="$RANDOM"
	#			echo "$(( $myrand % $delta_kb_size_percent ))"
				# note $(( $RANDOM % number )) gives a random number (reminder)
				# between 0 and number
				kb_start=$(( $myrand % $delta_kb_size_percent + $small_kb_size_percent ))
				
				# zoom doesn't look that smooth, so don't use it!
				# randomly choose between zoom and pan:
	#			zoom_or_pan=$(( $RANDOM % 2 ))
	#			echo "zoom_or_pan=$zoom_or_pan"
				zoom_or_pan=0
				if [ $zoom_or_pan -eq 1 ] ; then
					# do zoom
					kb_end=$(( $RANDOM % $delta_kb_size_percent + $small_kb_size_percent ))
					kenburns_args="kenburns:$kb_start%;50%,50%;$kb_end%;50%,50%"
				else	
					# do pan
					# now get horizontal and vertical movement for START:
					if [ "$autocrop_size_percent" -gt "$kb_start" ] ; then
						range=$(( $autocrop_size_percent - $kb_start ))
					else
						range=$(( $kb_start - $autocrop_size_percent ))
					fi
	#				echo "autocrop=$autocrop_size_percent range=$range"
					small_kb_percent=$(( 50 - $range/2 ))	
					kb_x_start=$(( $RANDOM % $range + $small_kb_percent ))
					kb_x_end=$(( $RANDOM % $range + $small_kb_percent ))
					kb_y_start=$(( $RANDOM % $range + $small_kb_percent ))
					kb_y_end=$(( $RANDOM % $range + $small_kb_percent ))
					xrange=$(( $kb_x_start - $kb_x_end ))
					[ "$xrange" -lt 0 ] && xrange=$(( -1 * $xrange ))
					yrange=$(( $kb_y_start - $kb_y_end ))
					[ "$yrange" -lt 0 ] && yrange=$(( -1 * $yrange ))
					# make sure values are not the same?
	#echo "trying: 	kenburns:$kb_start%;$kb_x_start%,$kb_y_start%;$kb_start%;$kb_x_end%,$kb_y_end%"
					if [ $kb_x_start -eq $kb_x_end ] && [ $kb_y_start -eq $kb_y_end ] ; then
						kenburns_args=''
					elif [ $(( $kb_x_start - $kb_x_end )) -le 1 ] && [ $(( $kb_y_start - $kb_y_end )) -le 1 ] ; then
						kenburns_args=''
					else
						kenburns_args="kenburns:$kb_start%;$kb_x_start%,$kb_y_start%;$kb_start%;$kb_x_end%,$kb_y_end%"
					fi
				fi
			fi
		else
			kenburns_args=""
		fi
		if [ -n "$subtitle" ] ; then
			if [ "$subtitle" == 'filename' ] ; then
				# use name as the subtitle
				subtitle_text="$( basename "$file" )"
			elif [ "$subtitle" == 'path' ] ; then
				# use full filename and path as subtitle (truncate?)
				subtitle_text="$file"
			else
				subtitle_text="$subtitle"
			fi
		else
			subtitle_text=''
		fi	
	
		if [ -n "$subtitle2" ] ; then
			if [ "$subtitle2" == 'filename' ] ; then
				# use name as the subtitle2
				subtitle2_text="$( basename "$file" )"
			elif [ "$subtitle2" == 'path' ] ; then
				# use full filename and path as subtitle2 (truncate?)
				subtitle2_text="$file"
			else
				subtitle2_text="$subtitle2"
			fi
		else
			subtitle2_text=''
		fi	
		if [ -n "$subtitle2_text" ] && [ -n "$kenburns_args" ] ; then
			fileecho "$file:${duracion[$vuelta]}:$subtitle_text"';'"$subtitle2_text:$kenburns_args"
		elif [ -z "$subtitle2_text" ] && [ -n "$kenburns_args" ] ; then
			fileecho "$file:${duracion[$vuelta]}:$subtitle_text:$kenburns_args"
		elif [ -n "$subtitle_text" ] && [ -z "$subtitle2_text" ] && [ -z "$kenburns_args" ] ; then
			fileecho "$file:${duracion[$vuelta]}:$subtitle_text"
		elif [ -n "$subtitle2_text" ] && [ -z "$kenburns_args" ] ; then
			fileecho "$file:${duracion[$vuelta]}:$subtitle_text"';'"$subtitle2_text"
		else
			fileecho "$file:${duracion[$vuelta]}"
		fi
		if [ "$crossfade" != "0" ] && [ "$i" -lt "$pictures" ] ; then
			fileecho "crossfade:$crossfade"
		elif [ "$wipe" != "0" ] && [ "$i" -lt "$pictures" ] ; then
			fileecho "wipe:$wipe"
		fi
		let j=$j+1
	fi  # end of if statement for different file types
	let vuelta=$vuelta+1
done
	
## fade out at end
fileecho "fadeout:1"
fileecho "background:2"
#if [ "$title" -eq 1 ] && [ -n "$title_background" ] ; then
#	# if we use a title, then fade back in to title_background?
#	fileecho "fadein:1"
#	fileecho "$title_background":3
#fi
echo "#########################################"

cleanup

echo "[dir2slideshow] Output file is $outfile"
echo
