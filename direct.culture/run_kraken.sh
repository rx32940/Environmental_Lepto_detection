#!/bin/sh
#SBATCH --partition=highmem_p
#SBATCH --job-name=kraken2
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --time=168:00:00
#SBATCH --mem=300G
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.out
#SBATCH --mail-user=rx32940@uga.edu
#SBATCH --mail-type=ALL

# Kraken database
# https://lomanlab.github.io/mockcommunity/mc_databases.html

# cd scratch/rx32940/16S_meta/culture/kraken/maxikraken2_1903_140GB
# wget -c https://refdb.s3.climb.ac.uk/maxikraken2_1903_140GB/hash.k2d
# wget https://refdb.s3.climb.ac.uk/maxikraken2_1903_140GB/opts.k2d
# wget https://refdb.s3.climb.ac.uk/maxikraken2_1903_140GB/taxo.k2d


ml Kraken2/2.0.9-beta-gompi-2019b-Perl-5.30.0

DATA="/scratch/rx32940/16S_meta/culture/data/raw"
OUT="/scratch/rx32940/16S_meta/culture/kraken/output"
DB="/scratch/rx32940/16S_meta/culture/kraken/maxikraken2_1903_140GB"

# for file in $DATA/*/barcode*fastq;
# do
# # sample=$(basename $file ".fastq")
# # echo $sample
# # kraken2 --report $OUT/$sample.kreport \
# # --report-zero-counts \
# # -db $DB \
# # --use-names \
# # --threads 12 \
# # $file

# sample=$(basename $file ".fastq")
# echo $sample
# kraken2 --report $OUT/$sample.mpa.txt \
# --use-mpa-style \
# --report-zero-counts \
# -db $DB \
# --use-names \
# --threads 12 \
# $file

# done

#### Use KrakenTools to combine outputs #################

# TOOLS="/scratch/rx32940/16S_meta/culture/kraken/KrakenTools"
# OUT="/scratch/rx32940/16S_meta/culture/kraken/output"


# kreports=$(ls $OUT/* | grep -E 'barcode[0-9]+\.kreport')
# mpa=$(ls $OUT/*mpa.txt) # -r for kreport combine -i for mpa report combine
# file_type_option="-i"
# file_type="mpa"
# sample_names=$(find $OUT/*mpa.txt -type f | awk -F "/" '{print $NF}' | awk -F "." '{print $1}')

# python $TOOLS/combine_mpa.py \
# $file_type_option $mpa \
# -o combined.$file_type #\
# --display-headers \
# --sample-names $sample_names \