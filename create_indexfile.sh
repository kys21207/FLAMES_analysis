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
cp "${gwas_input_path}/${gwas_file_name}" /opt/notebooks/tmp/
tar -xzvf /opt/notebooks/tmp/"${gwas_file_name}"

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

# Loop over each matching file and append a row in the index file
for file in "${txt_files[@]}"; do
    base=$(basename "$file")
    # Construct the corresponding annotation file path by prepending "FLAMES_"
    annot_file="/opt/notebooks/output/${gwas_name_prefix}/FLAMES_${base}"
    # Write the row to the index file. The Filename column uses the full file path from the susie_results directory.
    echo -e "${file}\t${counter}\t${annot_file}" >> "$index_file"
    ((counter++))
done

echo "Index file created at ${index_file}"
