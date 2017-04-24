#!/bin/bash

# Make up the zip file for Plos One final author re-submission

#FIGLIST=`grep includegraph P1_Draft.tex | grep -v PLOS-submission| awk -F '{' '{print \$2}'| awk -F '}' '{print \$1}'`

FIGLIST=''
XSTART=1
XEND=12
for i in `seq ${XSTART} ${XEND}`; do
    FIGLIST="${FIGLIST} figures/Fig${i}.tiff"
done

cp ./omit_reasons.pdf ./S1_Appendix.pdf
cp ../analysis/Anova.pdf ./S2_Appendix.pdf

rm -f plosone_resubmission2.zip

zip plosone_resubmission2.zip \
P1_Draft.pdf \
S1_Appendix.pdf \
S2_Appendix.pdf \
P1_Draft.tex

rm -f S1_Appendix.pdf
rm -f S2_Appendix.pdf
