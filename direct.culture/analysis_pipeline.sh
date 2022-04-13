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



####### Sequence pre-processing ###########################################
# source activate porechop

# DATA="/scratch/rx32940/16S_meta/culture/data"

# # read quality assessment -pre-prefilter
# for file in $DATA/raw/barcode*/barcode*fastq;
# do
# BC=$(basename $file ".fastq")
# NanoStat -o $DATA/QC/pre_filter_QC -n $BC --fastq $file --tsv
# done


# # Filter reads smaller than 1.4 kbp and longer than 1.6 kbp
# for file in $DATA/raw/barcode*/barcode*fastq;
# do
# BC=$(basename $file ".fastq")
# cat $file | NanoFilt -l 1400 --maxlength 1600 > $DATA/Filtered/$BC.fastq
# done


# # read quality assessment - post-filter
# for file in $DATA/Filtered/*.fastq;
# do
# BC=$(basename $file ".fastq")
# NanoStat -o $DATA/QC/post_filter_QC -n $BC --fastq $file --tsv
# done

# # assess and QC use pistis for plot
# for file in $DATA/Filtered/*.fastq;
# do
# BC=$(basename $file ".fastq")
# pistis -f $file -o $DATA/QC/post_QC_pistis/$BC.pdf
# done
# conda deactivate


######## Map read to 16S rRNA Databases for Classification ###############################################



DB="/scratch/rx32940/16S_meta/Environmental_16S_Test_HAC_Basecalling_July_17_2021/minimap2/db"
READS="/scratch/rx32940/16S_meta/culture/data/Filtered"
MINI="/scratch/rx32940/16S_meta/culture/minimap2"

# THREAD=3
# header="
# #!/bin/bash\n\
# #SBATCH --partition=bahl_salv_p\n\
# #SBATCH --job-name=minimap2\n\
# #SBATCH --ntasks=1\n\
# #SBATCH --cpus-per-task=$THREAD\n\
# #SBATCH --time=100:00:00\n\
# #SBATCH --mem-per-cpu=30G\n\
# #SBATCH --output=%x.%j.out\n\
# #SBATCH --error=%x.%j.out\n\
# #SBATCH --mail-user=rx32940@uga.edu\n\
# #SBATCH --mail-type=ALL\n\
# ml minimap2/2.17-GCC-8.3.0\n
# "

# # minimap2 -d $DB/SILVA_138.1_SSURef_NR99_tax_silva.mmi $DB/SILVA_138.1_SSURef_NR99_tax_silva.fasta
# for file in $READS/*fastq;
# do

# (
# sample_name=$(basename $file ".fastq")
# echo $sample_name

# echo -e $header > sub.sh

# echo -e "minimap2 -ax map-ont -L $DB/SILVA_138.1_SSURef_NR99_tax_silva.mmi $READS/$sample_name.fastq > $MINI/sam/$sample_name.sam -t $THREAD" >> sub.sh

# sbatch sub.sh
# ) &

# wait
# done
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