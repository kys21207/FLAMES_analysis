#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 -g <gwas_file_name> -p <gwas_name_prefix> -f <gwas_file_path>"
    exit 1
}

# Parse command-line arguments
while getopts ":g:p:f:" opt; do
    case $opt in
        g) gwas_file_name="$OPTARG" ;;
        p) gwas_name_prefix="$OPTARG";;
        f) gwas_input_path="$OPTARG" ;;
        *) usage ;;
    esac
done

# Ensure required arguments are provided
if [ -z "$gwas_file_name" ] || [ -z "$gwas_input_path" ]; then
    usage
fi

# Create temporary folder
mkdir -p /opt/notebooks/tmp

# Copy the SuSiE result GWAS file to the tmp folder and extract it
#cp "${gwas_input_path}/${gwas_file_name}" /opt/notebooks/tmp/
#tar -xzvf /opt/notebooks/tmp/"${gwas_file_name}"

gwas_name_prefix="test"
# Directory containing the extracted SuSiE results
SUSIE_RESULTS_DIR="/opt/notebooks/susie_results"

# Validate that the results directory exists
if [ ! -d "$SUSIE_RESULTS_DIR" ]; then
    echo "Directory $SUSIE_RESULTS_DIR does not exist."
    exit 1
fi

# Find txt files matching the pattern *_credible_sets_block_*.txt in the susie_results directory
txt_files=( "${SUSIE_RESULTS_DIR}"/*_credible_sets_block_*.txt )

if [ ${#txt_files[@]} -eq 0 ]; then
    echo "No matching txt files found in ${SUSIE_RESULTS_DIR}"
    exit 1
fi

# Path to the index file to be created
index_file="/opt/notebooks/data/indexfile.txt"

# Write header to the index file
echo -e "Filename\tGenomicLocus\tAnnotfiles" > "$index_file"

# Counter for GenomicLocus (starting at 1)
counter=1

# Process each file
for file in "${txt_files[@]}"; do
    base=$(basename "$file")
    tmp_dir=$(mktemp -d)
    
    # Get the maximum CS_Number in the file (excluding header)
    max_cs=$(tail -n +2 "$file" | awk -F'\t' '{print $2}' | sort -n | uniq | tail -n 1)
    
    if [ "$max_cs" -gt 1 ]; then
        # Read the header once
        head -n 1 "$file" > "${tmp_dir}/header.txt"
        
        # Split the file by CS_Number
        for cs in $(seq 1 "$max_cs"); do
            output_file="${file%.*}.${cs}.txt"
            cat "${tmp_dir}/header.txt" > "$output_file"
            awk -F'\t' -v cs="$cs" '$2 == cs' "$file" >> "$output_file"
        done
        
        # Remove the original file after creating split files
        rm "$file"
        
        # Update the index file entries for the split files
        for cs in $(seq 1 "$max_cs"); do
            split_base="${base%.*}.${cs}.txt"
            annot_file="/opt/notebooks/output/${gwas_name_prefix}/FLAMES_${split_base}"
            echo -e "${SUSIE_RESULTS_DIR}/${split_base}\t${counter}\t${annot_file}" >> "$index_file"
        done
    else
        # If there's only one CS_Number, just add the original file to the index
        annot_file="/opt/notebooks/output/${gwas_name_prefix}/FLAMES_${base}"
        echo -e "${file}\t${counter}\t${annot_file}" >> "$index_file"
    fi
    
    rm -r "$tmp_dir"
    ((counter++))
done

echo "Index file created at ${index_file}"
echo "Processing completed at $(date -u '+%Y-%m-%d %H:%M:%S') UTC by ${USER}"
