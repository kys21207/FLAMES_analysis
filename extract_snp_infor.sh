#!/bin/bash

# Input file containing the data
input_file="/opt/notebooks/cred_data/susie_results/ms_all_comers_v3_credible_sets_block_1134.txt"

# Output file to store the extracted SNP information
output_file="/opt/notebooks/cred_data/susie_results/snp_info.txt"
# Write the header to the output file
echo "GenomicLocus chr start end" > "$output_file"

# Process each line of the input file (skip the header line)
tail -n +2 "$input_file" | while IFS=$'\t' read -r block cs_number snp pip; do
  # Extract chromosome, start, and end positions from the SNP field
  chr=$(echo "$snp" | cut -d':' -f1)
  start=$(echo "$snp" | cut -d':' -f2)
  end=$(($start + 1))  # Assuming end is start + 1

  # Write the extracted information to the output file
  echo "$snp $chr $start $end" >> "$output_file"
done


echo "SNP information extracted to $output_file"
