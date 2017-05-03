#!/bin/bash

# Make up the zip file for Arxiv submission
FIGLIST='figures/Fig1.jpg'
XSTART=2
XEND=12
for i in `seq ${XSTART} ${XEND}`; do
    FIGLIST="${FIGLIST} figures/Fig${i}.png"
done

# Make P1_Draft.tex into Arxiv-friendly format:
rm P1_Draft_arxiv.tex

sed 's/\%\\includegraphics/\\includegraphics/g' < P1_Draft.tex > P1_Draft_arxiv.tex.0
sed 's/tiff/png/g' < P1_Draft_arxiv.tex.0 > P1_Draft_arxiv.tex.1
sed 's/Fig1.png/Fig1.jpg/g' < P1_Draft_arxiv.tex.1 > P1_Draft_arxiv.tex
rm P1_Draft_arxiv.tex.[01]
sed 's/\\lhead/\%\\lhead/' < P1_Draft_arxiv.tex > P1_Draft_arxiv.tex.0
sed 's/\\lfoot/\%\\lfoot/' < P1_Draft_arxiv.tex.0 > P1_Draft_arxiv.tex.1
sed 's/\\linenumbers/\%\\linenumbers/' < P1_Draft_arxiv.tex.1 > P1_Draft_arxiv.tex
rm P1_Draft_arxiv.tex.[01]


cp ../analysis/Anova.pdf .

rm -f arxiv_submission.zip

zip arxiv_submission.zip \
${FIGLIST} \
omit_reasons.pdf \
Anova.pdf \
striking_image.jpg \
P1_Draft_arxiv.tex

rm -f Anova.pdf
rm -f P1_Draft_arxiv.tex
