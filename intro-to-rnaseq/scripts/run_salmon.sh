#!/bin/bash

for fq in $HOME/stat115/intro-to-rnaseq/raw_data/*.fq; do
    samplename=`basename $fq .fq`

    # run salmon
    salmon quant -i $HOME/stat115/intro-to-rnaseq/data/reference_data/salmon_index \
	    -l A \
	    -r $fq \
	    -o ${samplename}.salmon \
	    --seqBias \
	    --useVBOpt \
	    --validateMappings
done
