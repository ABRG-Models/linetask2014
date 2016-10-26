#!/bin/bash

# Make up the zip file for Plos One submission

FIGLIST=`grep eps P1_Draft.tex |grep includegraph | grep -v PLOS-submission| awk -F '{' '{print \$2}'| awk -F '}' '{print \$1}'`
echo 'FIGLIST is '${FIGLIST}

zip plosone_submission.zip \
P1_Draft.tex \
omit_reasons.pdf \
cover_letter.txt \
${FIGLIST}
