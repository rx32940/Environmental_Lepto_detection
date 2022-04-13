#!/bin/bash
#SBATCH --partition=bahl_salv_p
#SBATCH --job-name=samstats
#SBATCH --ntasks=1                    	
#SBATCH --cpus-per-task=1      
#SBATCH --time=100:00:00
#SBATCH --mem=10G
#SBATCH --output=%x.%j.out       
#SBATCH --error=%x.%j.out        
#SBATCH --mail-user=rx32940@uga.edu
#SBATCH --mail-type=ALL


ml minimap2/2.17-GCC-8.3.0

DB="/scratch/rx32940/16S_meta/minimap2/db"
READS="/scratch/rx32940/16S_meta/data/Filtered"
MINI="/scratch/rx32940/16S_meta/minimap2"
# minimap2 -d $DB/SILVA_138.1_SSURef_NR99_tax_silva.mmi $DB/SILVA_138.1_SSURef_NR99_tax_silva.fasta
# minimap2 -ax map-ont -L $DB/SILVA_138.1_SSURef_NR99_tax_silva.mmi $READS/BC06.fastq > $MINI/sam/BC06.sam

#############SAMTOOLS stats#######################

ml SAMtools/1.10-GCC-8.3.0

mkdir -p $MINI/sam_stats

for file in $MINI/sam/*;
do
sample=$(basename $file ".sam")

samtools stats $file > $MINI/sam_stats/$sample.stats

done

##############SAM to BED#################################

# ml BEDOPS/2.4.39-foss-2019b
# ml SAMtools/1.10-GCC-8.3.0

# for sam in $MINI/sam/*sam;
# do

# sample=$(basename $sam ".sam")

# sam2bed < $sam > $MINI/bed/$sample.bed

# done