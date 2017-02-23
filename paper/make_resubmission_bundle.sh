#!/bin/bash

# Make up the zip file for Plos One re-submission

#FIGLIST=`grep includegraph P1_Draft.tex | grep -v PLOS-submission| awk -F '{' '{print \$2}'| awk -F '}' '{print \$1}'`

FIGLIST=''
XSTART=1
XEND=12
for i in `seq ${XSTART} ${XEND}`; do
    FIGLIST="${FIGLIST} figures/Fig${i}.tiff"
done

cp ../analysis/Anova.pdf .

rm -f plosone_resubmission.zip

zip plosone_resubmission.zip \
revisions.pdf \
P1_Draft_annotated.pdf \
P1_Draft.pdf \
${FIGLIST} \
Anova.pdf \
P1_Draft.tex

rm -f Anova.pdf
