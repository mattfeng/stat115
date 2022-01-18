# STAT 115

## Install and setup

```
pip install jupyter_contrib_nbextensions
jupyter contrib nbextension install --user
jupyter nbextension enable freeze/main
```

## Homeworks

Some of the data in the homeworks is stored on the HPC cluster used in STAT115.
Because most people do not have access to said cluster, problems requiring
access to the HPC cluster have alternate workshop materials linked, which can
be used to gain practical experience with the same tools.

- Homework 1
  - Part I: Introduction to R
  - Part II: Data Manipulation in R
  - Part III: Plotting in R
  - Part IV: Bash practice
  - Part V: High through sequencing read mapping
  - Part VI: Dynamic programming
- Homework 2
  - Part I: RNA-seq quality control
  - Part II: Pseudoalignment with Salmon
  - Part III: Differential gene expression
  - Part IV: Gene ontology with DAVID and GSEA
  - Part V: Python programming
  - Part VI: Batch effects and classification in the literature
  - Alternative exercises
    - [Introduction to (bulk) RNA-seq using High-Performance Computing - FAS-RC cluster](https://hbctraining.github.io/Intro-to-rnaseq-fasrc-salmon-flipped/schedule/links-to-lessons.html) is a good substitute for Parts I and II.
    - [Introduction to Differential Gene Expression](https://hbctraining.github.io/DGE_workshop_salmon/) is a good substitute for Parts III and IV.

## Remaining questions
- How does TruSeq stranded prep work (dUTP method)?

## Other tutorials to index
- https://hbctraining.github.io/Accessing_public_genomic_data/lessons/downloading_from_SRA.html
