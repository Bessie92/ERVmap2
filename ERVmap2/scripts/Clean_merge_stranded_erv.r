#!/arc/software/spack/opt/spack/linux-centos7-x86_64/gcc-5.4.0/r-3.6.2-3p7kfxatyhrmisok24ivjmu3guuabal5/bin/Rscript

#
# Combines ERV and Gene Counts into respective merged files
#

args <- commandArgs(TRUE)

cache_dir <- args[1]     # input: cache directory path
output_dir <- args[2]    # input: output directory path

merge_counts <- function(pattern, label) {
  files <- list.files(path=cache_dir, pattern=pattern, recursive=TRUE)
  merged_list <- list()
  
  for (f in files) {
    sample_name <- gsub("\\/.*", "", f)
    
    df <- read.table(file.path(cache_dir, f), header=FALSE, stringsAsFactors=FALSE)
    df <- df[-c(1:4), ]  # remove STAR header lines
    df <- df[, c(1, 4)]  # keep feature ID and reverse-strand count
    colnames(df) <- c(label, sample_name)
    
    merged_list[[length(merged_list) + 1]] <- df
  }
  
  merged_df <- Reduce(function(x, y) merge(x, y, by=label, all=TRUE), merged_list)
  merged_df[is.na(merged_df)] <- 0  # replace NAs with 0
  write.table(merged_df, file=file.path(output_dir, paste0("merged_", label, "s.txt")), sep="\t", row.names=FALSE, quote=FALSE)
}

merge_counts("*.gene", "gene")
merge_counts("*.erv", "erv")