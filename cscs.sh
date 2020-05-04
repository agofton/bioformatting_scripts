#!/bin/bash

# cscs = copy script and change sample
# This script will copy an input script and change the sample name and one string (sample name etc.) according to an array set on the command line
# Usage = ./cscs.sh original_script.sh originalsample_ID new_sample_ID_1 new_sample_ID_2 ..... new_sample_ID_n
# eg. ./cscs.sh map_sample_p1.sh p1 p2 p3 p4 p5
# will copy the script map_sample_p1.sh four times resulting in:
#     map_sample_p1.sh
#     map_sample_p2.sh
#     map_sample_p3.sh
#     map_sample_p4.sh
#     map_sample_p5.sh
# and every instance of "p1" in the new files will be replces with the new sample name (p2-p5)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# set array from command line input
array=( "$@"  )
# set number of array items
n=${#array[@]}
# set vars to array items 0 and 1
orig_file=${array[0]}
orig_ID=${array[1]}

for x in "${array[@]: 2: ${n}}"
do
        # copy file and change file name
        new_file=`sed -E s/${orig_ID}/${x}/g <<< ${orig_file}`
        echo $new_file
        cp ${orig_file} ${new_file}

        # edit new file
        sed -i s/${orig_ID}/${x}/g ${new_file}
done
