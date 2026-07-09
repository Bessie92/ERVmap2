#!/bin/bash

## ERVmap2 main script
## Run from the directory containing input FASTQ files.

## ~Expected file naming~
##   Single-end: *_SS.fastq.gz
##   Paired-end: *_R1.fastq.gz and *_R2.fastq.gz

#========
# MODIFY
#========

# ERVmap2 root dir
ERVMAP2="/path/to/ERVmap2"

# Final output dir
OUTPUT_DIR="/path/to/output"

# Tools
STAR="STAR"
SAMTOOLS="samtools"
R="Rscript"

# STAR genome index
GENOME_DIR="/path/to/STAR/genome/index"

# Number of STAR threads
THREADS=16

# LIBRARY PREPARATION TYPE
# Choose:
#   rev = reverse-stranded library prep
#   fwd = forward-stranded library prep

LIBRARY_PREP="rev"

#====================
# END OF MODIFICATION
#====================

mkdir -p "$OUTPUT_DIR"

# Define strandness script
if [ "$LIBRARY_PREP" = "rev" ]; then
    MERGE_SCRIPT="$ERVMAP2/scripts/clean_merge_stranded_erv.r"
elif [ "$LIBRARY_PREP" = "fwd" ]; then
    MERGE_SCRIPT="$ERVMAP2/scripts/clean_merge_stranded_erv_fwd_strand.r"
else
    echo "Error: LIBRARY_PREP must be 'rev' or 'fwd'"
    exit 1
fi

# Define alignment script
ALIGN_SCRIPT="$ERVMAP2/scripts/ERVmap2_alignment_Unique.sh"

process_file() {
    local sample="$1"
    local sub_dir="$2"
    shift 2

    echo "Running sample: $sample"

    if [ "$#" -eq 1 ]; then
        "$ALIGN_SCRIPT" \
            -read1 "$1" \
            -sub_dir "$sub_dir" \
            -star "$STAR" \
            -genome_dir "$GENOME_DIR" \
            -threads "$THREADS"

    elif [ "$#" -eq 2 ]; then
        "$ALIGN_SCRIPT" \
            -read1 "$1" \
            -read2 "$2" \
            -sub_dir "$sub_dir" \
            -star "$STAR" \
            -genome_dir "$GENOME_DIR" \
            -threads "$THREADS"

    else
        echo "Input error for sample: $sample"
        exit 1
    fi

    echo "Filtering BAM..."

    "$SAMTOOLS" view -h -F4 "$sub_dir/Aligned.sortedByCoord.out.bam" | \
        "$SAMTOOLS" view -b -h - > "$sub_dir/filtered.bam"

    "$SAMTOOLS" index "$sub_dir/filtered.bam"

    echo "Separating gene and ERV counts..."

    (head -n 4 "$sub_dir/ReadsPerGene.out.tab" && \
        tail -n +5 "$sub_dir/ReadsPerGene.out.tab" | grep "^ENSG") \
        > "$sub_dir/${sample}.gene"

    (head -n 4 "$sub_dir/ReadsPerGene.out.tab" && \
        tail -n +5 "$sub_dir/ReadsPerGene.out.tab" | grep -v "^ENSG") \
        > "$sub_dir/${sample}.erv"

    echo "Finished $sample"
    echo
}

##################
# SINGLE-END
for fq in *_SS.fastq.gz; do
    [ -e "$fq" ] || continue

    sample="${fq%_SS.fastq.gz}"
    read1="$(readlink -f "$fq")"

    SUB_DIR="$OUTPUT_DIR/$sample"
    mkdir -p "$SUB_DIR"

    process_file "$sample" "$SUB_DIR" "$read1"
done

# PAIRED-END
for r1_file in *_R1.fastq.gz; do
    [ -e "$r1_file" ] || continue

    sample="${r1_file%_R1.fastq.gz}"

    read1="$(readlink -f "${sample}_R1.fastq.gz")"
    read2="$(readlink -f "${sample}_R2.fastq.gz")"

    SUB_DIR="$OUTPUT_DIR/$sample"
    mkdir -p "$SUB_DIR"

    process_file "$sample" "$SUB_DIR" "$read1" "$read2"
done

# MERGE ALL COUNTS
echo "Merging counts across all samples..."
"$R" "$MERGE_SCRIPT" "$OUTPUT_DIR" "$OUTPUT_DIR"

echo "All runs completed."
