#!/bin/bash

# Make up the zip file for Plos One submission

#FIGLIST=`grep includegraph P1_Draft.tex | grep -v PLOS-submission| awk -F '{' '{print \$2}'| awk -F '}' '{print \$1}'`

FIGLIST=''
XSTART=1
XEND=10
for i in `seq ${XSTART} ${XEND}`; do
    FIGLIST="${FIGLIST} figures/Fig${i}.tiff"
done

cp ../analysis/Anova.pdf .

rm -f plosone_submission.zip

zip plosone_submission.zip \
cover_letter.pdf \
P1_Draft.pdf \
${FIGLIST} \
omit_reasons.pdf \
Anova.pdf \
striking_image.jpg \
P1_Draft.tex

rm -f Anova.pdf
