# De Novo Mitochondrial Genome Assembly & Quality Control Pipeline

## Overview
End-to-end Linux bioinformatics workflow demonstrating raw Illumina short-read quality assessment, barcode demultiplexing, 5' trimming, Phred quality filtering, and *de novo* genome assembly comparing **Velvet** (`k=21` vs. `k=31`) and **ABySS** (`k=21`).

## Pipeline Architecture
1. **Raw Data Inspection & QC (`FastQC`):** Evaluated `132,141` multiplexed Illumina reads (`109 bp`, Total `14.4 Mbp`, Mode Phred = `37`). Identified 5' barcode bias across positions 1–13 and 3' quality drop-off.
2. **Demultiplexing (`fastx_barcode_splitter.pl`):** Partitioned raw reads by 5' barcodes into `splitData_mt1.fastq` (`51,965` reads) and `splitData_mt2.fastq` (`80,176` reads) with `0` unmatched reads.
3. **Barcode Trimming & Quality Filtering (`fastx_trimmer` & `fastq_quality_filter`):** Removed 8-bp 5' barcodes (`-f 9 -Q33`) and filtered out reads where fewer than 80% of bases had Phred >= 25 (`11.29%` removed; `46,096` high-quality reads retained). Post-filtering FastQC confirmed `Per base sequence content` improved from **FAIL** to **PASS**.
4. **De Bruijn Graph Assembly Benchmarking (`Velvet` vs. `ABySS`):**

| Assembler & Parameter | Total Nodes / Unitigs | Total Contigs | Contigs >= 500 bp | N50 (bp) | Max Contig (bp) | Total Assembled Bases (bp) |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Velvet (`k=21`)** | 205 nodes | 134 | — | 329 | 1,267 | 19,589 |
| **Velvet (`k=31`)** | 82 nodes | 55 | — | 1,291 | 3,229 | 18,230 |
| **ABySS (`k=21` Contigs)** | 78 unitigs | 74 | 6 | 3,269 | 4,162 | 14,011 |
| **ABySS (`k=21` Scaffolds)** | 78 unitigs | 65 | 2 | 8,517 | 8,517 | 15,255 |

5. **Taxonomic Identification (`BLASTn`):** Querying the top ABySS contigs (`>297` at `4,176 bp`, `>298` at `3,271 bp`, `>296` at `3,127 bp`) against NCBI `nt` identified the sample as the **complete mitochondrial genome of the earthworm *Drawida gisti***.

## Repository Structure
- `scripts/run_assembly_pipeline.sh`: Automated bash script executing the complete workflow.
- `environment.yml`: Conda environment specification (`fastqc`, `fastx_toolkit`, `velvet`, `abyss`).
- `data/mt_barcodes.txt`: Multiplex barcode definitions.
- `results/fastqc/`: Pre- and post-processing FastQC HTML reports.
- `results/velvet/`: Contig FASTAs and execution logs for `k=21` and `k=31`.
- `results/abyss/`: Final ABySS contigs, scaffolds, and assembly summary metrics.
