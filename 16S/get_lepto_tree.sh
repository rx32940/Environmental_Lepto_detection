#!/bin/bash
#SBATCH --partition=bahl_salv_p
#SBATCH --job-name=muscleAlign
#SBATCH --ntasks=1                    	
#SBATCH --cpus-per-task=1      
#SBATCH --time=100:00:00
#SBATCH --mem=30G
#SBATCH --output=%x.%j.out       
#SBATCH --error=%x.%j.out        
#SBATCH --mail-user=rx32940@uga.edu
#SBATCH --mail-type=ALL

ml seqtk/1.2-foss-2019b
ml MUSCLE/3.8.1551-GCC-8.3.0

FASTQ="/scratch/rx32940/16S_meta/data/demultiplex"
LEPTO="/scratch/rx32940/16S_meta/16S_lepto_tree"
SAM="/scratch/rx32940/16S_meta/minimap2/sam"

SAMPLE="BC03"

# convert minimap2 mapped sam to fasta
# samtools fasta $SAM/$SAMPLE.sam > $LEPTO/samples/$SAMPLE/$SAMPLE.fasta

# # extract reads mapped to Spirochaetota phylum from fastq
# seqtk subseq $LEPTO/samples/$SAMPLE/$SAMPLE.fasta $LEPTO/samples/$SAMPLE/lepto_${SAMPLE}readID.lst > $LEPTO/samples/$SAMPLE/lepto_${SAMPLE}read.fasta

# # fix NCBI fasta headers to only keep the NCBI accession
# cut -d ' ' -f1 16S_lepto_NCBI.fasta > 16S_lepto_NCBI_header.fasta

# # combine reads mapped to Spirochaetota phylum with rest Leptospira 16S downloaded from NCBI
# cat $LEPTO/16S_lepto_NCBI_header.fasta $LEPTO/samples/$SAMPLE/lepto_${SAMPLE}read.fasta > $LEPTO/samples/$SAMPLE/combined_lepto_16S_$SAMPLE.fasta

# align all 16S sequences
muscle -in $LEPTO/samples/$SAMPLE/combined_lepto_16S_$SAMPLE.fasta -out $LEPTO/samples/$SAMPLE/${SAMPLE}_lepto_16S_aligned.fasta

# make a neighbor joining tree with all 16S files

# muscle -in $LEPTO/combined_lepto_16S.fasta -out $LEPTO/combined_lepto_16S_aligned.fasta
muscle -maketree -in $LEPTO/samples/$SAMPLE/${SAMPLE}_lepto_16S_aligned.fasta -out $LEPTO/samples/$SAMPLE/${SAMPLE}_lepto_16S.phy -cluster neighborjoining
