#!/bin/bash

# Alexander Gofton, CSIRO, 2020

# Help info - read on 1st usage.
help_message="""usage=$(basename $0) -b blast_file.blast -s sequence_file.fasta -o output.blast

This script will add the sequence of the query to the last column of a blast outfmt6 file.
Assumes query ID is in the 1st column.
Sequences must be in fasta file.
Assumes fasta file does not have sequences wrapped across multiple lines (multiline fasta).
        If fasta does have multiline sequences, use following to make single line fasta.
        > sed -i ':a; $!N; /^>/!s/\n\([^>]\)/\1/; ta; P; D' file.fasta
Output will be identicle to the input with the addition of the sequence in the last column.
"""
###############################################################################################
# Command line arguments
while getopts hb:s:o: option
do
        case "${option}"
        in
                h) echo "${help_message}"
                    echo ""
                        exit;;
                b) blast_file=${OPTARG};;
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
#############################################################################################
# 1. Generate list of seqIDs

uniq_prefix=${RANDOM}

seqIDs_tmp=${uniq_prefix}_seqIDs.tmp
seqs_tmp=${uniq_prefix}_seqs.tmp

awk -F "\t" '{print $1}' ${blast_file} > ${seqIDs_tmp}

# 2. Use list of seqIDs to extract sequences
while read -r line
do
        grep -A 1 -wF ${line} ${seq_file} | grep -v "^>" >> ${seqs_tmp}
done<${seqIDs_tmp}

        # cleanup as you go!
        rm ${seqIDs_tmp}

# 3. Checking original blast file & new sequence file contain the same number of rows.
orig=$(cat ${blast_file} | wc -l)
new=$(cat ${seqs_tmp} | wc -l)

if [ ${orig} -eq ${new} ]
then
        echo ""
        echo "Number of rows match ..."
        echo ""
else
        echo "Error: number of rows in original blast file do not match number of sequences generated."
        exit 1
fi

# 4. Append sequence to the last column of the blast file.
paste -d'\t' ${blast_file} ${seqs_tmp} > ${out_file}

        #cleanup as you go!
        rm ${seqs_tmp}

echo "Script finished, sequences appended to ${out_file}."
