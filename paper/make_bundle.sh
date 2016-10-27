#!/bin/bash

# Make up the zip file for Plos One submission

FIGLIST=`grep includegraph P1_Draft.tex | grep -v PLOS-submission| awk -F '{' '{print \$2}'| awk -F '}' '{print \$1}'`
echo 'FIGLIST is '${FIGLIST}

cp ../analysis/Anova.pdf .

rm -f plosone_submission.zip

zip plosone_submission.zip \
P1_Draft.tex \
omit_reasons.pdf \
Anova.pdf \
cover_letter.pdf \
striking_image.jpg \
${FIGLIST}

rm -f Anova.pdf
