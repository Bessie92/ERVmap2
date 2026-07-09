# ERVmap2
ERVmap2 is an updated version of [ERVmap](https://github.com/mtokuyama/ERVmap). It quantifies proviral ERV expression from stranded single- and pair-end bulk RNA sequencing data. 

# What's new?
This updated version includes several major improvements over the original pipeline. 
- Genome alignment, ERV quantification, and cellular gene quantification are now performed using [STAR (v2.7.9)](https://academic.oup.com/bioinformatics/article/29/1/15/272537).
- Updated proviral ERV locus database (`ERVmap2.bed`)
  - strand information has been assigned to all ERV loci
  - three loci (`cORF1ofHML2`, `K-30`, `K-50`) were removed because they do not overlap with RepeatMasker LTR annotations
- Included `Clean_merge_stranded_erv.r` and `Clean_merge_stranded_erv_fwd_strand.r` to support ERV/gene quantification from different stranded library preparation protocols.
- Included `erv_overlap_summary.tsv` that summarizes ERV-overlapping and upstream genomic features in `Homo_sapiens.GRCh38.110.gtf`.

# General workflow
<div style="background-color: white; padding: 16px; display: inline-block;">
  <img
    width="100%"
    alt="Pipeline figure"
    src="https://github.com/user-attachments/assets/de969725-2a37-43f5-8f09-082f093f2098"
  />
</div>

# Installations
## Dependencies
```
STAR-2.7.9a
samtools/1.17
r/4.4.0
```
## Included scripts
```
ERVmap2.sh
ERVmap2_alignment_Unique.sh
Clean_merge_stranded_erv.r
Clean_merge_stranded_erv_fwd_strand.r
normalize.r
```
## Reference genome files
- Hg38 primary assembly FASTA: https://www.ensembl.org/Homo_sapiens/Info/Index
- Hg38 comprehensive gene annotation (Homo_sapiens.GRCh38.110.gtf): https://hpc.nih.gov/refdb/dbview.php?id=1038
  - The [following features](https://github.com/Bessie92/ERVmap2/blob/main/ERVmap2/assets/features_removed_from_GRCh38.110.gtf) were removed from this GTF due to overlap with ERVmap2 annotations:
    - All features removed: `ERV3-1`, `ERVFRD-1`, `ERVK3-1`, `ERVV-1`, and `ERVV-2`
    - Transcript features removed: `ENST00000603053`, `ENST00000614721`, `ENST00000447535`, and `ENST00000603704`
# Pipeline running 
1. Generate a customized STAR index
   - What you need:
     - Genome FASTA file
     - Customized genome GTF file: `Homo_sapiens.GRCh38.110.gtf` with the features mentioned above removed and ERV features appended as exons
       Example: `1	ervmap	exon	896177	898458	.	-	.	gene_id "5803"; transcript_id "5803";`
  - Command:
    ```
    STAR --runThreadN 6 \
    --runMode genomeGenerate \
    --genomeDir /path/to/genomeDir \
    --genomeFastaFiles /path/to/genome/fasta \
    --sjdbGTFfile /path/to/customized.gtf \
    --sjdbOverhang 99
    ```
2. Run ERVmap2.sh from the folder containing all FASTQ files for all samples.
- This script is designed to automatically detect single- or paired-end FASTQ files, extract sample names based on the file names, create a cache directory for each sample within the specified output directory, and generate final merged ERV and gene count tables containing counts from all samples. You can use `ERVmap2/scripts/Normalization.r` to normalize the merged counts following the pipeline, or apply your own preferred normalization or transformation method.
## Output structure
  ```
  OUTPUT_DIR/
    sample1/
      Aligned.sortedByCoord.out.bam
      ReadsPerGene.out.tab
      Log.final.out
      sample1.gene
      sample1.erv
      filtered.bam
      filtered.bam.bai
    sample2/
      ...
    merged_ervs.txt
    merged_genes.txt
  ```
## Notes
- Make sure your FASTQ files are correctly formatted:
  - Single-end: `*_SS.fastq.gz`
  - Paired-end: `*_R1.fastq.gz` and `*_R2.fastq.gz`
- You need to specify the stranded library type:
  - `rev` = reverse-stranded methods, also known as first-strand methods, such as dUTP, NSR, and NNSR.
  - `fwd` = forward-stranded methods, also known as second-strand methods, such as Directional Illumina ligation and Standard SOLiD.
  - ERVmap2 can also be run on unstranded sequencing data by modifying `Clean_merge_stranded_erv.r` to select the unstranded read counts from the STAR output file `ReadsPerGene.out.tab`. However, this is not recommended, as using unstranded counts may reduce the accuracy of ERV quantification.

# Authors
Bessie Wang, Thomas Deckers, Eric Liu, Maria Tokuyama
**University of British Columbia, Life Science Institute**
