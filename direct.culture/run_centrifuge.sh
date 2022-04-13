#!/bin/sh
#SBATCH --partition=highmem_p
#SBATCH --job-name=centNewDB
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --time=168:00:00
#SBATCH --mem=300G
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.out
#SBATCH --mail-user=rx32940@uga.edu
#SBATCH --mail-type=ALL

cd $SLURM_SUBMIT_DIR

ml Centrifuge/1.0.4-beta-foss-2019b

# centrifuge-download -o taxonomy taxonomy

# centrifuge-download -P 12 -o library -m -d "archaea,bacteria,viral" refseq > seqid2taxid.map 

# used prebuilt index instead

DATA="/scratch/rx32940/16S_meta/culture/data/raw"
OUT="/scratch/rx32940/16S_meta/culture/centrifuge/output"
# for file in $DATA/*/barcode*fastq;
# do

# sample=$(basename $file ".fastq")

# mkdir -p $OUT/$sample

# cd $OUT/$sample

# centrifuge -p 12 -x /scratch/rx32940/16S_meta/culture/centrifuge/library/hpvc -q $file --report-file $OUT/$sample/$sample.summary.tsv > $OUT/$sample/$sample.out.tsv 
# done

# command used to split centrifuge output for each sample into separate files/ next time running centrifuge use -S <filename> --report-file <report>
# https://www.golinuxcloud.com/csplit-split-command-examples-linux-unix/
# csplit -k -f output/centrifuge_out centrDB.4431391.out '/^readID*/' '{*}'


for file in $OUT/*/*.out.tsv;
do
sample=$(basename $(dirname $file))
echo $sample
centrifuge-kreport -x /scratch/rx32940/16S_meta/culture/centrifuge/library/hpvc $file > $OUT/$sample/$sample.kreport
done