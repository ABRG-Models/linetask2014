#
# Now do analysis on ndall etc.
#
# This assumes ndall, sdall and adall have been generated from
# Bootstrap_indiv.r
#
# This is an updated version of the bootstrapping group analysis,
# following reviewer comments that the analysis was not correct.
#

load(file="all_latencies.rdat")

filesuffix <- "all"
# To call this, you need to have ndall, sdall and adall in the workspace:
source('Bootstrap_all_twosamples.r')
