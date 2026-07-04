# ERVmap2
ERVmap2 is an updated version of [ERVmap](https://github.com/mtokuyama/ERVmap). It quantifies proviral ERV expression from stranded single- and pair-end bulk RNA sequencing data. 

# What's new?
This updated version includes several major improvements over the original pipeline. 
- Genome alignment, ERV quantification, and cellular gene quantification are now performed using [STAR (v2.7.9)](https://academic.oup.com/bioinformatics/article/29/1/15/272537).
- Updated proviral ERV locus database (`ERVmap2.bed`)
  - strand information has been assigned to all ERV loci
  - three loci (`cORF1ofHML2`, `K-30`, `K-50`) were removed because they do not overlap with RepeatMasker LTR annotations
- Included `Clean_merge_stranded_erv.r` and `Clean_merge_stranded_erv_fwd_strand.r` to support ERV/gene quantification from different stranded library preparation protocols.
- Included `erv_overlap_summary.tsv` that summarizes ERV-overlapping and upstream genomic features in 'Homo_sapiens.GRCh38.110.gtf'.

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

# Pipeline running 
WIP

# Authors
Bessie Wang, Thomas Deckers, Eric Liu, Maria Tokuyama
**University of British Columbia, Life Science Institute**
