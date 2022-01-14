# Introduction to RNA-seq

This project introduces the fundamental practices involved in analyzing bulk RNA-seq data.

## Directory structure
```
.
├── Introduction to RNA-seq.ipynb   # main data exploration notebook
├── logs                            # contains logs on commands run
├── meta                            # metadata about samples used
├── raw_data                        # raw data and references
├── README.md
├── results                         # analysis results
└── scripts                         # scripts used for analysis
```

## HBC Training Links
- [Quality control with FastQC](https://hbctraining.github.io/Intro-to-rnaseq-fasrc-salmon-flipped/lessons/05_qc_running_fastqc_interactively.html)
- [RNA-seq Experimental Design](https://hbctraining.github.io/Intro-to-rnaseq-fasrc-salmon-flipped/lessons/02_experimental_planning_considerations.html)
- [Quasi-alignment with Salmon](https://hbctraining.github.io/Intro-to-rnaseq-hpc-salmon/lessons/04_quasi_alignment_salmon.html)

## Conda environments
- `salmon`
  - `fastqc`
  - `salmon`
  - `mashmap`
  - `bedtools`
  - `qualimap`
  - `star`

## Tutorial

### Pseudoalignment with Salmon

#### Install Salmon

For some reason, the Salmon conda package is not compatible with some R packages, so we create a clean environment just for Salmon.

First, make sure you have your conda channels setup correctly ([source](https://bioconda.github.io/user/install.html)). `conda-forge` should have higher priority than `bioconda`, which should have higher priority than `defaults`.

```bash
# make sure your channels are set up correctly; order of commands MATTERS!
conda config --add defaults
conda config --add bioconda
conda config --add conda-forge

conda config --show channels
# should output the following; list is in order of priority (highest first)
# channels:
#   - conda-forge
#   - bioconda
#   - defaults
```

Then, install Salmon. Make sure you're installing the latest version (1.6.0 as of January 2022) by looking at the [Salmon Bioconda recipe](https://bioconda.github.io/recipes/salmon/README.html)):

```bash
conda create -n salmon
conda install salmon
```

Check that Salmon was installed:

```bash
salmon -v
# output:
# salmon 1.6.0
```

#### Create Salmon index

Create the index using the following commands ([source](https://hbctraining.github.io/Intro-to-rnaseq-hpc-salmon/lessons/04_quasi_alignment_salmon.html)):

```bash
# download transcriptome sequences for humans
wget ftp://ftp.ensembl.org/pub/release-95/fasta/homo_sapiens/cdna/Homo_sapiens.GRCh38.cdna.all.fa.gz

gunzip Homo_sapiens.GRCh38.cdna.all.fa.gz

# create Salmon index
salmon index \
  -t Homo_sapiens.GRCh38.cdna.all.fa \
  -i salmon_index \
  -k 31
```
- `-t`. the path to the transcriptome (aka cDNA), in FASTA format
- `-i`. the output path; the folder to store the generated indices
- `-k`. the length of kmer to use to create the indices (will output all sequences in transcriptome of length k)

#### Quantifying transcripts

```bash
$RNA_SEQ_FILE="Mov10_oe_1.subset.fq"
$RNA_SEQ_PREFIX=`basename $RNA_SEQ_FILE .fq`

salmon quant -i $SALMON_INDEX_PATH \
  -l A \
  -r $RNA_SEQ_FILE \
  -o $RNA_SEQ_PREFIX.salmon \
  --seqBias \
  --useVBOpt \
  --validateMappings
```

- Arguments
  - `-i`. specify the location of the index directory; for us it is /n/groups/hbctraining/rna-seq_2019_02/reference_data/salmon.ensembl38.idx.09-06-2019
  - `-l A`. Format string describing the library. A will automatically infer the most likely library type (more info available here)
  - `-r`. sample file
  - `-o`. output quantification file name
  - `--useVBOpt`. use variational Bayesian EM algorithm rather than the ‘standard EM’ to optimize abundance estimates (more accurate)
  - `--seqBias`. will enable it to learn and correct for sequence-specific biases in the input data
  - `--validateMappings`. developed for finding and scoring the potential mapping loci of a read by performing base-by-base alignment of the reads to the potential loci, scoring the loci, and removing loci falling below a threshold score. This option improves the sensitivity and specificity of the mapping.
- Additional arguments
  - `--numBootstraps`. specifies computation of bootstrapped abundance estimates. Bootstraps are required for isoform level differential expression analysis for estimation of technical variance. Here, you can set the value to 30.

### QC with STAR and Qualimap

Before we can assess the quality of our transcript-level abundance estimates, we need to know where the transcripts mapped on the genome; Salmon only gives us the abundance, which is why it's fast.

We will use STAR to align our RNA-seq reads to our reference genome which will let us see potential quality issues with our data, such as:
- Are there more reads from one end of the gene or another? In other words, do we have a 3' or 5' bias?
- What proportion of total reads map to exons? If there are a lot of intronic reads, it may indicate DNA contamination.

#### Aligning RNA-seq with STAR

##### Creating the STAR genome index

Download the reference genome (FASTA) and gene annotations (GTF). You can see all the release versions [here](http://ftp.ensembl.org/pub/) and [all the files associated with version 95](http://ftp.ensembl.org/pub/release-95/).

```bash
wget ftp://ftp.ensembl.org/pub/release-95/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.chromosome.1.fa.gz
```

Create the STAR index with the following command:

```bash
STAR --runThreadN 6 \
  --runMode genomeGenerate \
  --genomeDir chr1_hg38_index \
  --genomeFastaFiles /n/holylfs05/LABS/hsph_bioinfo/Everyone/Workshops/Intro_to_rnaseq/reference_data/Homo_sapiens.GRCh38.dna.chromosome.1.fa \
  --sjdbGTFfile /n/holylfs05/LABS/hsph_bioinfo/Everyone/Workshops/Intro_to_rnaseq/reference_data/Homo_sapiens.GRCh38.92.gtf \
  --sjdbOverhang 99
```

##### Aligning the RNA-seq data

```bash
STAR --genomeDir ~/reference_data/intro-to-rnaseq/chr1_hg38_95_index \
  --runThreadN 6 \
  --readFilesIn ../../raw_data/Mov10_oe_1.subset.fq \
  --outFileNamePrefix Mov10_oe_1_ \
  --outSAMtype BAM SortedByCoordinate \
  --outSAMunmapped Within \
  --outSAMattributes Standard
```

#### Assessing quality with Qualimap
```bash
qualimap rnaseq -outdir Mov10_oe_1 \
  -a proportional \
  -bam ../star/Mov10_oe_1_Aligned.sortedByCoord.out.bam \
  -p strand-specific-reverse \
  -gtf ~/reference_data/intro-to-rnaseq/Homo_sapiens.GRCh38.95.gtf \
  --java-mem-size=8G
```