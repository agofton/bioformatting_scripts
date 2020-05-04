#!/bin/bash

# Alexander Gofton, CSIRO, 2020

# Help info - read on 1st usage.
help_message="""usage=$(basename $0) -f input.fasta -b results.blast -o output.seqs.blast

This script will take as input a .fasta file and a blast file in output format 6 and extract from the blast file all results for the reads in the fasta file.
This script will also append the read sequence to the last column of the output blast file to make downstread processing easier.

Input fasta sequences must be written on a single line. If fasta does have multiline sequences, use following to make single line fasta.
        > sed -i ':a; $!N; /^>/!s/\n\([^>]\)/\1/; ta; P; D' file.fasta

"""
###############################################################################################
# Command line arguments
while getopts hf:b:o: option
do
        case "${option}"
        in
                h) echo "${help_message}"
                    echo ""
                        exit;;
                f) input_fasta_file=${OPTARG};;
                b) input_blast_file=${OPTARG};;
                o) output_blast_file=${OPTARG};;
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

uniq_prefix=${RANDOM}

tmp1=${uniq_prefix}_read_seqIDs.tmp
tmp2=${uniq_prefix}_blast.tmp
tmp3=${uniq_prefix}_blast_seqIDs.tmp
tmp4=${uniq_prefix}_blast_seqs.tmp

# 1. Convert fasta file to a list of sequence IDs
grep "^>" ${input_fasta_file} | sed 's/^>//g' > ${tmp1}

# 2. Pull records from input blast file
grep -f ${tmp1} ${input_blast_file} > ${tmp2}

# 3. Pull seqIDs from new reduced blast file
awk -F "\t" '{print $1}' ${tmp2} > ${tmp3}

# 4. Use list of seqIDs to extract sequences from input fasta
while read -r line
do
        grep -A 1 -wF ${line} ${input_fasta_file} | grep -v "^>" >> ${tmp4}
done<${tmp3}

# 5. Checking  blast file & tmp sequence file contain the same number of rows.
orig=$(cat ${tmp2} | wc -l)
new=$(cat ${tmp4} | wc -l)

if [ ${orig} -eq ${new} ]
then
        echo ""
        echo "Number of rows match ..."
        echo ""
else
        echo "Error: number of rows in original blast file do not match number of sequences generated."
        exit 1
fi

# 6. Append sequence to the last column of the blast file.
paste -d'\t' ${tmp2} ${tmp4} > ${output_blast_file}

# 7. Cleanup
rm ${tmp1}
rm ${tmp2}
rm ${tmp3}
rm ${tmp4}

echo "Script finished, sequences appended to ${out_file}."
