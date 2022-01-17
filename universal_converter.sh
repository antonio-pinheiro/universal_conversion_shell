#!/bin/bash

############################################################################## 
##									    ## 
##			    Universal Converter  		  .~.	    ##
##			Created by: Antônio Pinheiro 	          /V\	    ##
##								 // \\	    ##
##		              					/(   )\	    ##
##						         	 ^`~'^      ##
##								  TUX       ##
##				                         		    ##
##   Operational Systems Compatibility: Debian / Ubuntu / and Derivatives   ##
##############################################################################
##  Project:     Universal Converter			            	    ##
##									    ##
##  File name:   universal_converter.sh 		                    ##
##									    ##
##  Description: Convert image files, song files and disk image files       ##
##	                                                                    ##
##  Date:        05/12/2021						    ##             
##  									    ##
## 									    ##
##############################################################################

#### !!! Instruction: Insert this script inside a directory to convert files !!! ####
		 #### !!! Files cannot contain blank spaces in their names !!! ####


# Load absolute path to script, dirname parameter strips the script name from the end of the path 
# and readlink resolves the name of absolute path. $0 is the relative path.
script_directory=$(dirname -- $(readlink -fn -- "$0"))


# Function that's convert image files. Formats supported are JPG and PNG.
image_converter(){
	
	local img_file=$1
	local img_without_extension=$(ls $img_file | awk -F. '{ print $1 }')
	if [[ "$_INPUT_STRING" == "png2jpg" ]]; then
		convert $img_without_extension.png $img_without_extension.jpg
	elif [[ "$_INPUT_STRING" == "jpg2png" ]]; then
		convert $img_without_extension.jpg $img_without_extension.png
	fi
}

# Function that's convert disk image files to ISO. Formats supported are IMG, NRG and MDF.
disk_image_converter(){
	
	local disk_file=$1
	local file_without_extension=$(ls $disk_file | awk -F. '{ print $1 }')
	if [[ "$_INPUT_STRING" == "nrg2iso" ]]; then
		nrg2iso $file_without_extension.nrg $file_without_extension.iso
	elif [[ "$_INPUT_STRING" == "mdf2iso" ]]; then
		mdf2iso $file_without_extension.mdf $file_without_extension.iso
	elif [[ "$_INPUT_STRING" == "img2iso" ]]; then
		ccd2iso $file_without_extension.img $file_without_extension.iso

	fi		
}

# Function that's convert audio files. Formats supported are MP3 and OGG.
audio_converter(){

	local audio_file=$1
	local audio_without_extension=$(ls $audio_file | awk -F. '{ print $1 }')
	if [[ "$_INPUT_STRING" == "mp32ogg" ]]; then
		ffmpeg -i $audio_without_extension.mp3 $audio_without_extension.ogg
	fi
}

# Function responsible for search files to convert in a directory, and call a external function to do this. 
search_directory(){
	
	echo "Choose format to convert png2jpg"
	echo "Choose format to convert jpg2png"
	echo "Choose format to convert nrg2iso"
	echo "Choose format to convert img2iso"
	echo "Choose format to convert mdf2iso"
	echo "Choose format to convert mp32ogg"
	read _INPUT_STRING
	
	
	cd $script_directory
	
	for file in *
	do	
		#Load absolute file path to work with it in conversion function.
		local file_path=$(find $script_directory -name $file)		

		if  [ -d $file_path ]; then
		 		#Enter and check if the directory exists, and scan name of the files to store them in a variable file_path.
		    	search_directory $file_path
		else
			
			if [[ "$_INPUT_STRING" == "jpg2png" ]] || [[ "$_INPUT_STRING" == "png2jpg" ]]; then
			 	#Call function to convert jpg file to png or png to jpg
				echo $file_path
			 	image_converter $file_path

			elif [[ "$_INPUT_STRING" == "mp32ogg" ]]; then
				#Call function to convert mp3 file to ogg
				echo $file_path
				audio_converter $file_path
			

			elif [[ "$_INPUT_STRING" == "img2iso" ]] || [[ "$_INPUT_STRING" == "mdf2iso" ]] || [[ "$_INPUT_STRING" == "nrg2iso" ]]; then
				#Call function to convert img file to iso
				echo $file_path
				disk_image_converter $file_path
			
			else
				
				echo "Invalid format option. Choose a valid format option to convert files"
				
			
			fi
		fi
		
	done
}

# Function to check if conversion ocurred or not.
start_function(){
	
	search_directory $script_directory
	if [ $? -eq 0 ]
	then	
		echo "Files were converted successfully"
	else
		echo "Files weren't converted - This is an ERROR message"
	fi
}

# This block checks if all dependencies are installed.
echo
echo "Check if dependencies ccd2iso, nrg2iso, mdf2iso, imagemagick and ffmpeg are installed."
echo
if dpkg -s ccd2iso mdf2iso nrg2iso ffmpeg imagemagick &> /dev/null;
then 
     echo "All dependencies are satisfied, continue with execution"
	 echo
	 sleep 1
	 start_function
	
else 
	 echo "Some dependencies need to be installed"
	 (( $(id -u) == 0 )) || { echo >&2 "You must be root to run this script"; }
	 echo
	 echo "Do you want to install these dependencies? yes or no: "
	 read answer
	 answer="$answer" | tr '[:lower:]'
	 
	 
	 if [[ $answer == "yes" ]]; then
		echo "Installing dependencies!!!"
		sudo apt-get install ccd2iso nrg2iso mdf2iso ffmpeg imagemagick
		sleep 1
		start_function

	 elif [[ $answer == "no" ]]; then
		
		sleep 1
		echo "You answered 'NO'. This script has been closed... Bye!!!"
		exit
	
	fi
fi
