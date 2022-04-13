#!/bin/bash
#SBATCH --partition=highmem_p
#SBATCH --job-name=abricate
#SBATCH --ntasks=1                    
#SBATCH --cpus-per-task=12      
#SBATCH --time=160:00:00
#SBATCH --mem=300G
#SBATCH --output=%x.%j.out       
#SBATCH --error=%x.%j.out        
#SBATCH --mail-user=rx32940@uga.edu
#SBATCH --mail-type=ALL

# ########### Trim adapters ##################################
# # Trimming and demultiplexing (not needed in this case)
###########################################################


# DATA="/scratch/rx32940/16S_meta/culture/data/raw"
# OUT="/scratch/rx32940/16S_meta/culture/assembly/trim"

# ml Porechop/0.2.4-intel-2019b-Python-3.7.4

# for file in $DATA/*/barcode*.fastq;
# do
# sample=$(basename $file '.fastq')
# porechop \
# -i $file \
# -o $OUT/$sample.trim.fastq \
# --verbosity 2 \
# --threads 12
# done

# ########### QC check ##################################
# # Check quality of the reads after trimming, readlength vs. read quality
###########################################################
# source activate minION

# TRIM="/scratch/rx32940/16S_meta/culture/assembly/trim"
# OUT="/scratch/rx32940/16S_meta/culture/assembly/QC_trim"
# for file in $TRIM/*.trim.fastq;
# do
# sample=$(basename $file '.trim.fastq')

# NanoPlot --fastq $file -o $OUT -p $sample --verbose

# done

# conda deactivate

# ########### Filter Reads ##################################
# # Check quality of the reads after trimming, readlength vs. read quality
###########################################################
# source activate minION

# TRIM="/scratch/rx32940/16S_meta/culture/assembly/trim"
# OUT="/scratch/rx32940/16S_meta/culture/assembly/filtered"

# for file in $TRIM/*.trim.fastq;
# do
# sample=$(basename $file '.trim.fastq')
# cat $file | NanoFilt -l 1000 --maxlength 1000000 > $OUT/$sample.filtered.fastq
# done

# conda deactivate


# ########### Correct Reads ##################################
# # canu correct errors in reads by overlapping to form consensus reads
###########################################################

# ml canu/2.1.1-GCCcore-8.3.0-Java-11

# FILTERED="/scratch/rx32940/16S_meta/culture/assembly/filtered"
# OUT="/scratch/rx32940/16S_meta/culture/assembly/correct"
# for file in $FILTERED/*.filtered.fastq;
# do

# sample=$(basename $file ".filtered.fastq")

# echo $sample 

# canu -correct \
# gridOptions=" --partition=batch --ntasks=1 --cpus-per-task=12 --time=160:00:00" \
# -p $sample -d $OUT/$sample \
# genomeSize=5m \
# maxInputCoverage=10000 corOutCoverage=10000 corMhapSensitivity=high corMinCoverage=0 redMemory=32 oeaMemory=32 batMemory=200 \
# correctedErrorRate=0.16 \
# -nanopore $FILTERED/$sample.filtered.fastq
# done

# ########### Assemble corrected reads ##################################
# # assemble corrected reads use Flye
###############################################################

# ml Flye/2.8.1-foss-2019b-Python-3.8.2

# SEQ="/scratch/rx32940/16S_meta/culture/assembly/correct"
# OUT="/scratch/rx32940/16S_meta/culture/assembly/flye/output"

# THREAD=12

# header="                                                                        
# #!/bin/bash\n#SBATCH --partition=highmem_p\n#SBATCH --job-name=flye\n#SBATCH --ntasks=1\n#SBATCH --cpus-per-task=$THREAD\n#SBATCH --time=168:00:00\n#SBATCH --mem=200G\n#SBATCH --output=%x.%j.out\n#SBATCH --error=%x.%j.out\n#SBATCH --mail-user=rx32940@uga.edu\n#SBATCH --mail-type=ALL\n 
# ml Flye/2.8.1-foss-2019b-Python-3.8.2\n                                                      
# "

# for file in $SEQ/*/*.fasta.gz;
# do
# (
# sample=$(basename $file '.correctedReads.fasta.gz')

# echo -e $header > sub.sh

# echo -e "flye --nano-corr $file --out-dir $OUT/$sample -t 12 --meta" >> sub.sh

# sbatch sub.sh
# ) &

# wait
# done

# ########### Assemble polish ##################################
# # medaka polishs draft assembly using by creating a consensus 
###############################################################

# ml medaka/1.2.3

# ASM="/scratch/rx32940/16S_meta/culture/assembly/flye/output"
# BASECALLED="/scratch/rx32940/16S_meta/culture/data/raw"
# POLISH="/scratch/rx32940/16S_meta/culture/assembly/medaka"


# for file in $ASM/*/assembly.fasta;
# do
# sample=$(basename $(dirname $file))

# medaka_consensus -i $BASECALLED/$sample/$sample.fastq -o $POLISH/$sample -m r941_min_high_g360 -t 12 -d $file 

# done

# ########### AWK ##################################
# # split polished consensus assemblies in to separate files
###############################################################

# POLISH="/scratch/rx32940/16S_meta/culture/assembly/medaka"

# for file in $POLISH/*/consensus.fasta;
# do
# sample=$(basename $(dirname $file))


# mkdir -p $POLISH/$sample/split_contigs
# # 1) find line begins with ">", set F = substring the line, start with the second character".fasta", print the file
# awk -v dir="$POLISH/$sample" '/^>/ {path = "split_contigs";F = dir"/"path"/"substr($1, 2)".fasta"} {print > F}' $file

# done

# ########### checkM ##################################
# # check the complete genomes and contaminents in the assemblies
###############################################################

# ml CheckM/1.1.3-foss-2019b-Python-3.7.4

# POLISH="/scratch/rx32940/16S_meta/culture/assembly/medaka"
# CHECKM="/scratch/rx32940/16S_meta/culture/assembly/checkM"

# for dir in $POLISH/*/split_contigs;
# do

# sample=$(basename $(dirname $dir))

# echo $sample
# mkdir -p $CHECKM/$sample
# checkm lineage_wf $dir $CHECKM/$sample -t 12 -x fasta

# done

# ########### DIAMOND ##################################
# # align the assembled metagenomes to NCBI-nr
# - frame-shift mode that performs frame-shift alignment of DNA sequences against a protein reference database (-F 15)
# - range-culling. This feature determines which alignments are reported to output (--range-culling and --top 10)
###############################################################
# cd $DIAMOND
# ml DIAMOND/2.0.4-GCC-8.3.0

# POLISH="/scratch/rx32940/16S_meta/culture/assembly/medaka"
# DIAMOND="/scratch/rx32940/16S_meta/culture/assembly/diamond"



# DB="/db/ncbi/fasta/08302020"

# # diamond makedb --in $DB/nr -d $DIAMOND/nr 

# for file in $POLISH/*/*.fasta.gz;
# do
# sample=$(basename $(dirname $file))
# # -f (output format 100 = DIAMOND alignment archive (DAA))
# diamond blastx -d $DIAMOND/nr.dmnd -q $file -o $DIAMOND/$sample.daa -f 100 -F 15 --range-culling --top 10 -c1 -b12
# done

############ run the meganizer tool ##################################
# to index all reads and alignments, 
# and to bin the reads to taxonomic and functional classes
####################################################################

# source activate MEGAN

# MEGAN="/scratch/rx32940/16S_meta/culture/assembly/MEGAN_correct"
# DIAMOND="/scratch/rx32940/16S_meta/culture/assembly/diamond"

# # for file in $DIAMOND/barcode*daa;
# # do

# # sample=$(basename $file ".daa")

# # mkdir -p $MEGAN/$sample

# # cd $MEGAN/$sample

# # daa-meganizer -i $file -t 12 \
# # --longReads --lcaAlgorithm longReads \
# # --lcaCoveragePercent 51 \
# # --readAssignmentMode alignedBases \
# # -mdb $MEGAN/database/megan-map-Jan2021.db

# # done


# ##############extract all assemblies out after frameshift corrected (MEGAN)##########################

# # for file in $DIAMOND/*daa;
# # do

# # sample=$(basename $file ".daa")
# # read-extractor -i $file --frameShiftCorrect -a -o $MEGAN/$sample.corrected.fasta
# # done

# conda deactivate

######### split corrected multi-fasta into multiple fasta files #######################
# MEGAN="/scratch/rx32940/16S_meta/culture/assembly/MEGAN_correct"
# for file in $MEGAN/*/*fna;
# do
# sample=$(basename $file ".corrected.fna")
# echo $sample
# awk -v dir="$MEGAN/$sample" '/^>/ {F = dir"/"substr($1, 2)".fasta"} {print > F}' $file
# done
#########################################################################################
#
#  GTDB-Tk:
# GTDB-Tk is a software toolkit for assigning objective taxonomic classifications 
# to bacterial and archaeal genomes based on the Genome Database Taxonomy GTDB
# designed to work with recent advances that allow hundreds or thousands of metagenome-assembled genomes (MAGs)
#########################################################################################

# ml GTDB-Tk/1.3.0-foss-2019b-Python-3.7.4
# MEGAN="/scratch/rx32940/16S_meta/culture/assembly/MEGAN_correct"
# GTDBTK="/scratch/rx32940/16S_meta/culture/assembly/gtdbtk"

# # fasta input file must be named with ".fna" 
# for file in $MEGAN/barcode*/;
# do
# sample=$(basename $file)
# echo $sample
# mkdir -p $GTDBTK/$sample
# gtdbtk classify_wf --genome_dir $MEGAN/$sample/ --out_dir $GTDBTK/$sample --cpus 12
# done

#######################################################################
#
# identify AMR genes from the assembly
#
#######################################################################

# source activate abricate
# dir="/scratch/rx32940/16S_meta/culture/assembly/MEGAN_correct"

# abricate $dir/*/*fna --threads 12


# conda deactivate

##########################################################################
#
# use Prokka to annotate assemblies
#
##########################################################################


