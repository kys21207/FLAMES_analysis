#!/bin/bash 

# Path to the directory containing GWAS files
gwas_input_path="/mnt/project/publically_available_supporting_files/gwas_public_results"
magma_score_out_path="/mnt/project/analysis_KJ/pops_analysis/magma_scores"
magma_out_path="/opt/notebooks/out"

# Function to extract the sample size from the 'N' column of a GWAS file
extract_sample_size() {
    local gwas_file=$1
    zcat "$gwas_file" | awk -F' ' 'NR==1 {for (i=1; i<=NF; i++) if ($i=="N") col=i} NR==2 {print $col}'
}

# Find all GWAS files with the .regenie.tsv.gz extension in the input path
for gwas_file in ${gwas_input_path}/*.regenie.tsv.gz; do
    # Get the file name prefix(strip the path and extention)
    gwas_name_prefix=$(basename "$gwas_file" .regenie.tsv.gz)
      
/opt/notebooks/codes/magma \
--gene-results ${magma_score_out_path}/${gwas_name_prefix}.magma.genes.raw \
--gene-covar /mnt/project/publically_available_supporting_files/FLAMES/gtex_v8_ts_avg_log2TPM.txt \
--out ${magma_out_path}/${gwas_name_prefix}

done

echo "All GWAS files processed."
