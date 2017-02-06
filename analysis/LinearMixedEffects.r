## This script computes linear mixed effects model for the latency data.

## I found guidance on Anovas/Linear models in R here:
## https://gribblelab.wordpress.com/2009/03/09/repeated-measures-anova-using-r/
## and here:
## https://seriousstats.wordpress.com/tag/rank-transformation/

##NB: source like this: source('Nonranked.r', print.eval=TRUE)

## Set factor contrasts option, important for aov() function.
options(contrasts=c("contr.treatment","contr.treatment"))

latdat <- read.csv('AnovaR.csv')

## Using Linear Mixed Effects models
require(nlme)

## Compute ranks to carry out ANOVA on the ranks
##rlatency <- rank(latdat$latency)

## The formulae here are:
## fixed effects: latency "is predicted by" condition_str as a factor.
## random effects: "is predicted by" "subj_id"
nonranked <- lme(fixed = latency ~ condition_str, random = ~1|subj_id, data=latdat)
## ------------------------------------------------------------------------------
summary(nonranked)
## ------------------------------------------------------------------------------
anova(nonranked)

## Method="ML" is equivalent in the lme() function to REML=FALSE for the lmer function.
nonranked.null <- lme(latency ~ 1, random= ~1|subj_id, data=latdat, method="ML")
nonranked.mdl <- lme(latency ~ condition_str, random= ~1|subj_id, data=latdat, method="ML")
anova(nonranked.null, nonranked.mdl)

setEPS()
postscript(file='../paper/figures/lme_latency_resid1.eps')
plot(nonranked, resid(., type = "p") ~ fitted(.) | condition_str, abline = 0, xlab=c("Fitted latency (ms)"))
dev.off()

setEPS()
postscript(file='../paper/figures/lme_latency_resid2.eps')
plot(nonranked, subj_id ~ resid(.))
dev.off()

setEPS()
postscript(file='../paper/figures/lme_latency_fits.eps')
plot(nonranked, latency ~ fitted(.) | subj_id, abline = c(0,1))
dev.off()
