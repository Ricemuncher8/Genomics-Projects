#!/usr/bin/env bash
set -euo pipefail

wget -nc https://github.com/doxeylab/learn-genomics-in-linux/raw/master/task2/mt_reads.fastq.gz
gunzip -k -f mt_reads.fastq.gz
wget -nc https://github.com/doxeylab/learn-genomics-in-linux/raw/master/task2/mt_barcodes.txt

fastqc mt_reads.fastq

fastx_barcode_splitter.pl < mt_reads.fastq --bcfile mt_barcodes.txt --bol --suffix .fastq --prefix splitData_
fastx_trimmer -i splitData_mt1.fastq -f 9 -o trimmed_mt1.fastq -Q33
fastq_quality_filter -i trimmed_mt1.fastq -q 25 -p 80 -o qual_trim_mt1.fastq -Q33 -v
fastqc qual_trim_mt1.fastq

velveth out_21 21 -short -fastq qual_trim_mt1.fastq
velvetg out_21/ -scaffolding no -read_trkg yes -amos_file yes

velveth out_31 31 -short -fastq qual_trim_mt1.fastq
velvetg out_31/ -scaffolding no -read_trkg yes -amos_file yes

abyss-pe k=21 B=2G in='qual_trim_mt1.fastq' name=abyss-assembly
