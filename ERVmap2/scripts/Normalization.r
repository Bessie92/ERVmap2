# Count normalization in R

## 1. Normalize raw cellular genes using DEseq2 and generate size factors per sample
gene_count <- read.csv("merged_genes.csv", row.names=1)

### Perform normalization using DESeq2
library(DESeq2)
conds <- factor( c(1:ncol(gene_count)))
dds <- DESeqDataSetFromMatrix(countData = as.matrix(gene_count), colData = as.matrix(conds), design = ~ 1)
dds <- estimateSizeFactors(dds)
normalizedCounts <- counts(dds, normalized=T)
write.table(normalizedCounts,
            file = "normalized_genes.csv",
            sep = ",",
            quote = FALSE,
            col.names = NA)
write.table(sizeFactors(dds), "normalized_factors.txt", sep="\t", quote=FALSE, col.names=NA)

## 2. Normalize raw ERV counts using cellular gene size factors
size_factor <- read.table("normalized_factors.txt")
colnames(size_factor) <- c("sizeFactor")
erv_count <- read.csv("merged_ervs.csv", row.names=1)

norm_erv_count <- erv_count
# Loop through each column in erv_count (each column name is a sample)
for (sampleName in colnames(erv_count)) {
  # Check if the sample name exists in the row names of size_factor
  if (sampleName %in% rownames(size_factor)) {
    # Retrieve the corresponding size factor
    sizeFactor <- size_factor[sampleName, ]
    
    # Apply the size factor to normalize ERV counts
    norm_erv_count[, sampleName] <- erv_count[, sampleName] / sizeFactor
  } else {
    warning(paste("Size factor for", sampleName, "not found!"))
  }
}
# Output the normalized ERV counts as a .csv file
write.table(norm_erv_count, "normalized_ervs.csv", sep = ",", quote=F, col.names = NA)
norm_erv_count <- read.csv("normalized_ervs.csv", row.names=1)
