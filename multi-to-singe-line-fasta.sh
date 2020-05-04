#!/bin/bash

# Alexander W. Gofton, CSIRO, 2020

help_message="Script to convert multiline fasta to single line fasta. Script will overwrite the input multiline fasta as a single line fasta.

Useage: $(basename $0) -i input.fasta"

# Command line arguments
while getopts hi: option
do
        case "${option}"
        in
                h) echo "$help_message"
                    echo ""
                    echo "$usage_message"
                        exit;;
                i) input=${OPTARG};;
                :) printf "missing argument for  -%s\n" "$OPTARG" >&2
                   echo "$usage" >&2
                   exit 1;;
           \?) printf "illegal option: -%s\n" "$OPTARG" >&2
                   echo "$usage" >&2
                   exit 1;;
        esac
done
shift $((OPTIND - 1))

###############################################################
sed -i ':a; $!N; /^>/!s/\n\([^>]\)/\1/; ta; P; D' ${input}
