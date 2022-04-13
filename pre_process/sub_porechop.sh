#!/bin/bash
#SBATCH --partition=bahl_salv_p
#SBATCH --job-name=pistis
#SBATCH --ntasks=1                    	
#SBATCH --cpus-per-task=12      
#SBATCH --time=100:00:00
#SBATCH --mem=100G
#SBATCH --output=../%x.%j.out       
#SBATCH --error=../%x.%j.out        
#SBATCH --mail-user=rx32940@uga.edu
#SBATCH --mail-type=ALL



SOFTWARE="/scratch/rx32940/16S_meta/porechop/Porechop-0.2.4/bin"
DATA="/scratch/rx32940/16S_meta/data"
OUTPUT="/scratch/rx32940/16S_meta/data/demultiplex"

# module load GCC/6.4.0-2.28 before installation
# change adapter.py file for custom adapter and barcodes

source activate porechop

# # Trimming and demultiplexing
# $SOFTWARE/porechop \
# -i $DATA/Environmental_16S_Test_HAC_Basecalling_July_17_2021/Environmental_16S_combined.fastq \
# -b $OUTPUT \
# --discard_middle \
# --verbosity 2 \
# --threads 12

# # read quality assessment -pre-prefilter
# for file in $DATA/demultiplex/BC*;
# do
# BC=$(basename $file ".fastq")
# NanoStat -o $DATA/QC/pre_filter_QC -n $BC --fastq $file --tsv
# done


# # Filter reads smaller than 1.4 kbp and longer than 1.6 kbp
# for file in $DATA/demultiplex/BC*;
# do
# BC=$(basename $file ".fastq")
# cat $file | NanoFilt -l 1400 --maxlength 1600 > $DATA/Filtered/$BC.fastq
# done


# # read quality assessment - post-filter
# for file in $DATA/Filtered/BC*;
# do
# BC=$(basename $file ".fastq")
# NanoStat -o $DATA/QC/post_filter_QC -n $BC --fastq $file --tsv
# done

# # assess and QC use pistis for plot
for file in $DATA/Filtered/BC*;
do
BC=$(basename $file ".fastq")
pistis -f $file -o $DATA/QC/post_QC_pistis/$BC.pdf
done
conda deactivate
