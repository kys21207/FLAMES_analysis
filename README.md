# FLAMES_analysis 
https://github.com/Marijn-Schipper/FLAMES?tab=readme-ov-file <br>
FLAMES combines SNP-to gene evidence (V2G) and bological pathway convergence using machine learning (XGBoost clasifier) to rank effctor genes. <br>
1. SNP-to-Gene Evidence: 22 different SNP-to-gene linking methods such as Chromatin interaction, eQTLs, proximity-based methods, and Fine-mapping results <br>
2. Biological pathway convergence: uses PoPS (gene co-expression, protein-protein interactions and pathway and functional annotations <br>
3. Combining XGBoost and PoPS Scores: Cg=0.725Xg+0.25Pg (Xg=XGBoost prediction score, Pg=PoPS convergence score) <br>   
## installation on DNAnexus
- Create a virtual environment <br>
python -m venv venv <br>
- Activate the virtual environment <br>
source venv/bin/activate <br>
- Install the packages using the updated requirements.txt <br>
pip install -r /opt/notebooks/FLAMES/requirements.txt <br>
