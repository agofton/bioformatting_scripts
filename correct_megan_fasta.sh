#!/bin/bash

# Alexander Gofton, CSIRO, 2020

# Help info - read on 1st usage.
help_message="""usage=$(basename $0) -m megan_file.fasta -s sequence_file.fasta -o output.fasta

Often when exporting .fasta files from MEGAN the file is often written incorrectly, with the seq IDs printed correctly but with no sequence.
This script will take the corrupted .fasta file from megan and write a corrected one."""


###############################################################################################
# Command line arguments
while getopts hm:s:o: option
do
        case "${option}"
        in
                h) echo "${help_message}"
                    echo ""
                        exit;;
                m) megan_file=${OPTARG};;
                s) seq_file=${OPTARG};;
                o) out_file=${OPTARG};;
                :) printf "missing argument for  -%s\n" "$OPTARG" >&2
                   echo "$usage" >&2
                   exit 1;;
           \?) printf "illegal option: -%s\n" "$OPTARG" >&2
                   echo "$usage" >&2
                   exit 1;;
        esac
done
shift $((OPTIND - 1))
###############################################################################################


# 1. Convert corrupted fasta file to a list of sequence IDs

tmp1=seqIDs.${RANDOM}.tmp

grep "^>" ${megan_file} | sed 's/^>//g' > ${tmp1}

# 2. use usearch to pull seqs from the original fasta file

~/usearch9.2_linux64 -fastx_getseqs ${seq_file} -labels ${tmp1} -fastaout ${out_file}

# cleanup
rm -f ${tmp1}
