# If not installed yet: 
# install.packages("BiocManager")
# BiocManager::install("Gviz")

################################### 
## 1) Load packages
###################################
# If you haven't installed Gviz:
# install.packages("BiocManager")
# BiocManager::install("Gviz")

library(Gviz)

###################################
## 2) Read in data
###################################
# Adjust these file names to match your actual paths
gene_file   <- "output/armsss_armsss_all_comers_v3/FLAMES_armsss_armsss_all_comers_v3_credible_sets_block_1034.1.txt"
scores_file <- "results/armsss_armsss_all_comers_v3/FLAMES_scores.raw"

# Read gene annotation
genes_df <- read.delim(gene_file, header=TRUE, stringsAsFactors=FALSE)

# Read FLAMES scores
scores_df <- read.delim(scores_file, header=TRUE, stringsAsFactors=FALSE)

###################################
## 3) Filter for chromosome 13 and fix naming
###################################
# If your file has chromosome as numeric (e.g., "13") but Gviz expects "chr13", then:
genes_df$chr <- paste0("chr", genes_df$chr)

# Subset for chr13
df_chr13 <- subset(genes_df, chr == "chr13")

# Convert strand from 1/-1 to +/-
df_chr13$strand_symbol <- ifelse(df_chr13$strand == 1, "+", "-")

###################################
## 4) Match FLAMES scores to the gene-file name and find the highest FLAMES_scaled
###################################
# If 'filename' in scores_df has paths, remove them
scores_df$filename_stripped <- basename(scores_df$filename)

# Filter rows in scores_df that match your gene_file name
scores_subset <- subset(scores_df, filename_stripped == basename(gene_file))

# Among those, pick the highest FLAMES_scaled row
best_row <- scores_subset[which.max(scores_subset$FLAMES_scaled), ]

# Suppose best_row has a column named "symbol" that matches your gene file,
# or it might store a gene identifier in another column—adjust as needed.
best_gene <- best_row$symbol

###################################
## 5) Build Gviz tracks
###################################
# GeneRegionTrack for all genes in chr13
grtrack <- GeneRegionTrack(
  start      = min(df_chr13$start)-10000,
  end        = max(df_chr13$end)+10000,
  rstart      = df_chr13$start,
  rend        = df_chr13$end,
  strand     = df_chr13$strand_symbol,
  chromosome = "chr13",   
  genome     = "hg38",    # or "hg19"
  symbol     = df_chr13$symbol,
  gene       = df_chr13$ensg,
  name       = "Gene Model",
  showId     = TRUE,
  transcript = df_chr13$ensg,
  collapseTranscripts = FALSE
)

# Create an AnnotationTrack for the highest FLAMES_scaled gene
highlight_info <- subset(df_chr13, symbol == best_gene)
highlight_track <- AnnotationTrack(
  start       = highlight_info$start,
  end         = highlight_info$end,
  strand      = highlight_info$strand_symbol,
  genome      = "hg38",
  chromosome  = "chr13",
  gene     = highlight_info$symbol,  
  id      = highlight_info$symbol,# label with gene name
  name        = "Highest FLAMES_scaled",
  fill        = "red",                       # color the highlight
  col         = "red",
  showFeatureId=TRUE,
  featureAnnotation= "id",
  fontcolor.item = "black"
)

# Ideogram + axis for context
itrack <- IdeogramTrack(genome="hg38", chromosome="chr13")
gtrack <- GenomeAxisTrack()


###################################
## 6) Save the final plot as .png
###################################
png("my_gviz_plot.png", width=1200, height=300)
plotTracks(
  list(itrack, gtrack, grtrack, highlight_track)
)
dev.off()
