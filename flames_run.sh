#!/bin/bash 

## git clone https://github.com/Marijn-Schipper/FLAMES.git
## modify requirements.txt
# setup env for pops analysis
#python -m venv venv
#source venv/bin/activate
#pip install -r /opt/notebooks/FLAMES/requirements.txt

#cp /mnt/project/publically_available_supporting_files/FLAMES/Annotation_data.tar.gz /opt/notebooks/
#tar -xzvf /opt/notebooks/Annotation_data.tar.gz 

# Path to the directory containing GWAS files
gwas_input_path="/mnt/project/analysis_KJ/susie_finemapping_analysis/age_onset_results"
# Path for other inputs
annot_path="/opt/notebooks/Annotation_data"
pops_pred_path="/mnt/project/analysis_KJ/pops_analysis/results"
magma_score_path="/mnt/project/analysis_KJ/pops_analysis/magma_scores"
magma_gtex_path="/mnt/project/analysis_KJ/magma_analysis/gtex_tissue"
index_path="/opt/notebooks/data"
flames_score_path="/opt/notebooks/results"

mkdir -p ${index_path}

chmod +x ./codes/create_indexfile.sh

# Find all GWAS files with the .regenie.gz extension in the input path
for gwas_file in ${gwas_input_path}/* _susie_results.tar.gz; do
    # Get the file name (strip the path)
    gwas_name_prefix=$(basename "$gwas_file" _susie_results.tar.gz)
    gwas_file_name=$(basename "$gwas_file")
  
  # generate a indexfile.txt for each gwas based on the SuSiE result
  ./codes/create_indexfile.sh -g ${gwas_file_name} -p ${gwas_name_prefix} -f ${gwas_input_path}
  
    # Run the example.sh script with the current GWAS file
python /opt/notebooks/FLAMES/FLAMES.py annotate \
-a ${annot_path}/ \
-p ${pops_pred_path}/ms_all_comers_v3.pops.preds \
-m ${magma_score_path}/ms_all_comers_v3.magma.genes.out \
-mt ${magma_gtex_path}/ms_all_comers_v3.magma.gsa.out \
-id ${index_path}/indexfile.txt \
-pc PIP \
-sc SNP \
-c95 False

mkdir -p ${flames_score_path}/${gwas_name_prefix}
python /opt/notebooks/FLAMES/FLAMES.py FLAMES \
-id ${index_path}/indexfile.txt \
-o ${flames_score_path}/${gwas_name_prefix}

rm -r /opt/notebooks/susie_results 
rm /opt/notebooks/data/* /opt/notebooks/tmp/*

done



echo "All GWAS files processed."
