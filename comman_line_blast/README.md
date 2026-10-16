# Command-line BLAST & NCBI Data Retrieval

## Overview
This task demonstrates the retrieval of genomic and proteomic data from the NCBI FTP server, the formatting of BLAST databases, and the execution of command-line BLAST searches (`blastp`, `tblastn`, `blastn`, `blastx`) to identify proteins, genomic regions, and unknown DNA fragments.

## 1. Retrieving Data from NCBI
Genomic data for *Prochlorococcus marinus* was retrieved from the NCBI GenBank FTP server.

```bash
# Download genome, annotations, and proteome
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/007/925/GCA_000007925.1_ASM792v1/GCA_000007925.1_ASM792v1_genomic.fna.gz
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/007/925/GCA_000007925.1_ASM792v1/GCA_000007925.1_ASM792v1_genomic.gff.gz
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/007/925/GCA_000007925.1_ASM792v1/GCA_000007925.1_ASM792v1_protein.faa.gz

# Uncompress files
gunzip *.gz
```

File Formats Utilized:

- .fna: FASTA Nucleic Acid - Genomic Sequence
- .faa: FASTA Amino Acid - Proteome Sequence
- .gff: General Feature Format - Genome Annotations

## 2. Formatting the Genome and Proteome for BLAST
To perform a BLAST search, the database must be indexed into constituent k-mer fragments. The databases were formatted separately for protein and nucleotide queries, including the `-parse_seqids` flag for easy specific-entry retrieval.

```bash
makeblastdb -in GCA_000007925.1_ASM792v1_protein.faa -dbtype prot -parse_seqids
makeblastdb -in GCA_000007925.1_ASM792v1_genomic.fna -dbtype nucl -parse_seqids
```

### Retrieving Specific Entries
Using `blastdbcmd`, specific sequences and regions can be extracted directly from the indexed database.

```bash
# Retrieve full protein sequence
blastdbcmd -entry AAP99047.1 -db GCA_000007925.1_ASM792v1_protein.faa

# Retrieve a specific region (e.g., first 10 amino acids)
blastdbcmd -entry AAP99047.1 -db GCA_000007925.1_ASM792v1_protein.faa -range 1-10
```

## 3. Performing BLAST Searches

**Q:** How many significant (E < 0.001) hits were found for the E. coli L7 protein query?

**A:** 1 hit.

Both `blastp` (against the proteome) and `tblastn` (against the translated genome) yielded significant hits with an E-value < 0.001.

- blastp Hit: AAP99273.1 Ribosomal protein L7/L12 (Score: 87.8, E-value: 6e-25)
- tblastn Hit: AE017126.1 complete genome (Score: 59.7, E-value: 1e-12)

Note: BLAST detected the same protein as the top hit in both databases, but the alignment was shorter in the `tblastn` genomic search.

**Q:** What is the sequence identity (percentage) of the top BLAST hit?

**A:** 49%

Commands Used:

```bash
blastp -query e.coli.l7.faa -db GCA_000007925.1_ASM792v1_protein.faa -outfmt 6 -evalue 1e-5
tblastn -query e.coli.l7.faa -db GCA_000007925.1_ASM792v1_genomic.fna -outfmt 6 -evalue 1e-5
```

## 4. Identifying an Unknown DNA Fragment

Scenario: An unknown DNA fragment (`ACTGGCATTGATAGAACAACCATTTATTCGAGATAGTTCAATTACTGTAGAGCAAGTTGTAAAACA`) was sequenced.

Instead of using `grep` or `compseq` (which risk missing sequences due to line breaks, mismatches, or reverse-complement formatting), the sequence was written to a FASTA file and aligned using `blastn`.

```bash
# Create the query FASTA file
cat > fragment.fasta <<EOF
>mystery_fragment
ACTGGCATTGATAGAACAACCATTTATTCGAGATAGTTCAATTACTGTAGAGCAAGTTGTAAAACA
EOF

# Search the genomic database
blastn -query fragment.fasta -db GCA_000007925.1_ASM792v1_genomic.fna -outfmt 6 -evalue 1e-10
```

Results:
The `blastn` search yielded a good match with 97% Identity and 2 mismatches:

AE017126.1 Prochlorococcus marinus subsp. marinus str. CCMP1375 complete genome
Score = 111 bits (60), Expect = 2e-26
Identities = 64/66 (97%), Gaps = 0/66 (0%)

### Determining Biological Function
By running a `blastx` search (which translates the nucleotide query and searches a protein database), the fragment was identified as most likely being part of a gene encoding a translational elongation factor Ts.

```bash
blastx -query fragment.fasta -db GCA_000007925.1_ASM792v1_protein.faa -outfmt 6 -evalue 1e-5
```

Top blastx hit (example):
- elongation factor Ts (score, e-value, percent identity reported in BLAST output)

## Files Included
- README.md (this file)

(Optional) You may include `fragment.fasta` for reproducibility; it is small and safe to store in the repository.

## How to Reproduce
1. Install NCBI BLAST+ (makeblastdb, blastp, tblastn, blastn, blastx, blastdbcmd).
2. Download the three files shown in section 1 and decompress them.
3. Create BLAST databases as shown in section 2.
4. Run the example searches in section 3 and 4.

## Notes and Best Practices
- Always use `-parse_seqids` when creating BLAST databases if you plan to retrieve specific entries with `blastdbcmd`.
- For scriptable pipelines, use `-outfmt 6` (tabular) or `-outfmt 7` (commented tabular) for easier parsing.
- When searching short sequences, increase sensitivity (lower `-word_size`, adjust `-evalue`) and consider using `-task blastn-short` for very short queries.

## References
- NCBI FTP: ftp://ftp.ncbi.nlm.nih.gov/genomes/all/
- BLAST+ documentation: https://blast.ncbi.nlm.nih.gov/Blast.cgi?PAGE_TYPE=BlastDocs

---

Acknowledgements: This README was created to document the command-line BLAST workflow and results for Task 1b.
