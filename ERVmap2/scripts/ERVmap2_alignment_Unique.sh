#!/bin/bash

## ERVmap2 STAR unique-alignment

READ1=""
READ2=""
SUB_DIR=""
STAR_BIN="STAR"
GENOME_DIR=""
THREADS=16

while [[ $# -gt 0 ]]; do
    case "$1" in
        -read1)
            READ1="$2"
            shift 2
            ;;
        -read2)
            READ2="$2"
            shift 2
            ;;
        -sub_dir)
            SUB_DIR="$2"
            shift 2
            ;;
        -star)
            STAR_BIN="$2"
            shift 2
            ;;
        -genome_dir)
            GENOME_DIR="$2"
            shift 2
            ;;
        -threads)
            THREADS="$2"
            shift 2
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
done

mkdir -p "$SUB_DIR"

echo "Running STAR alignment"
echo "READ1: $READ1"

if [[ -n "$READ2" ]]; then
    echo "READ2: $READ2"
else
    echo "Single-end mode"
fi

echo "STAR: $STAR_BIN"
echo "Genome index: $GENOME_DIR"
echo "Threads: $THREADS"
echo "Output dir: $SUB_DIR"

STAR_CMD=(
    "$STAR_BIN"
    --runThreadN "$THREADS"
    --genomeDir "$GENOME_DIR"
    --readFilesIn "$READ1"
)

if [[ -n "$READ2" ]]; then
    STAR_CMD+=("$READ2")
fi

STAR_CMD+=(
    --readFilesCommand zcat
    --outFileNamePrefix "$SUB_DIR/"
    --outSAMtype BAM SortedByCoordinate
    --quantMode GeneCounts
    --outFilterMultimapNmax 1
    --outSAMmultNmax 1
    --outSJfilterReads Unique
    --outSAMstrandField intronMotif
    --outFilterMismatchNoverReadLmax 0.01
    --outSAMattributes All XS
)

echo "Command:"
printf '%q ' "${STAR_CMD[@]}"
echo

"${STAR_CMD[@]}"

echo "STAR alignment finished"
