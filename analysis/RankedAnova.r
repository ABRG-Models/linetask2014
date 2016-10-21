# I found guidance on Anovas in R here:
# https://gribblelab.wordpress.com/2009/03/09/repeated-measures-anova-using-r/
# and here:
# https://seriousstats.wordpress.com/tag/rank-transformation/

# Set factor contrasts option, important for aov() function.
options(contrasts=c("contr.treatment","contr.treatment"))

latdat <- read.csv('AnovaR.csv')

# Using Linear Mixed Effects models
require(nlme)

# Compute ranks to carry out ANOVA on the ranks
rlatency <- rank(latdat$latency)
#
# The formulae here are:
# fixed: rlatency "is predicted by" condition_str
# random: "is predicted by" "the mean" "given" "condition_str nested within subj_id"
anova_ranked_cond <- lme(fixed = rlatency ~ condition_str, random = ~1|subj_id/condition_str, data=latdat)
# ------------------------------------------------------------------------------
print (summary(anova_ranked_cond))
# ------------------------------------------------------------------------------
print(anova(anova_ranked_cond))
# ------------------------------------------------------------------------------
#
# Showing residuals of ANOVA on ranks:

setEPS()
postscript(file='../paper/figures/anova_ranked_cond_resid.eps')
plot(fitted(anova_ranked_cond), residuals(anova_ranked_cond))
dev.off()

png(filename='r_images/anova_ranked_cond_resid.png')
plot(fitted(anova_ranked_cond), residuals(anova_ranked_cond))
dev.off()

# Carry out the LME on subj_id - the inverse of the above.
anova_ranked_indiv <- lme(fixed = rlatency ~ subj_id, random = ~1|condition_str/subj_id, data=latdat)
# ------------------------------------------------------------------------------
print(anova(anova_ranked_indiv))
# ------------------------------------------------------------------------------
setEPS()
postscript(file='../paper/figures/anova_ranked_indiv_resid.eps')
plot (fitted(anova_ranked_indiv), residuals(anova_ranked_indiv))
dev.off()

png (filename='r_images/anova_ranked_indiv_resid.png')
plot (fitted(anova_ranked_indiv), residuals(anova_ranked_indiv))
dev.off()

#
# Apply Wilcoxon Signed-Rank test for pairwise comparisons
#
# individual latencies
nd <- latdat[latdat$condition_str == "ND",]$latency
sd <- latdat[latdat$condition_str == "SD",]$latency
ad <- latdat[latdat$condition_str == "AD",]$latency
#
# paired=TRUE indicates signed rank test
# Note in wilcox.test, V is what R calls W.
print(wilcox.test(nd, sd, paired=TRUE))
print(wilcox.test(nd, ad, paired=TRUE))
print(wilcox.test(ad, sd, paired=TRUE, exact=T))

#
# Cliff's delta
require(effsize)
#
# Between No Distractor and Synchronous Distractor:
cliff.delta(nd,sd)
#
# Between No Distractor and Asynchronous Distractor:
cliff.delta(nd,ad)
#
# Between Asynchronous Distractor and Synchronous Distractor:
cliff.delta(ad,sd)
