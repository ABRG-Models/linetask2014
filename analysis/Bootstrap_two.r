#
# Now do analysis on ndall etc.
#
# This assumes ndall, sdall and adall have been generated from
# Bootstrap_indiv.r
#
# This is an updated version of the bootstrapping group analysis,
# following reviewer comments that the analysis was not correct.
#

set.seed(1974201701)

load(file="all_latencies.rdat")

filesuffix <- "twosamp"
source('Bootstrap_all_twosamples.r')

#
# Bootstrap the difference between the means of pairs of distributions:
#
print("-----------------------------------------")
print("Bootstrap analysis of difference of means")
ndsd <- b.diffste(sdall, ndall, 1024)
print (sprintf("SD ND difference is %f, standard error estimate: %f", ndsd$meandiff, ndsd$stderr))
#ndsd$df = density(ndsd$diffs)
#plot (ndsd$df)

ndad <- b.diffste(adall, ndall, 1024)
print (sprintf("AD ND difference is %f, standard error estimate: %f", ndad$meandiff, ndad$stderr))

sdad <- b.diffste(adall, sdall, 1024)
print (sprintf("AD SD difference is %f, standard error estimate: %f", sdad$meandiff, sdad$stderr))
#sdad$df = density(sdad$diffs, n=1024)
#plot (sdad$df)


#
# Apply a hypothesis test to obtain the probability that the pairs of
# distributions are drawn from the same population.
#

#print ("Algo 16.1")

# ASL < 1/4e6 (2.5e-7) with B=4e6
#ndsd_t <- b.ttest(sdall, ndall, 1000)
#b.showsiglev (ndsd_t, "SD vs ND")

# ASL < 1/4e6 (2.5e-7)
#ndad_t <- b.ttest(adall, ndall, 1000)
#b.showsiglev (ndad_t, "AD vs ND")

# With B=1000000, get asl=0.000016
#sdad_t <- b.ttest(adall, sdall, 1000)
#b.showsiglev (sdad_t, "AD vs SD")


print("-----------------------------------------")
print ("Studentized bootstrapped hypothesis test (Algo 16.2)")
# ndsd does better than 1e-6 (set B to 1000000)
ndsd_tst <- b.studentized_ttest(sdall, ndall, 1000)
b.showsiglev (ndsd_tst, "SD vs ND")

# ndad does better than 3e-7 (set B to 3000000)
ndad_tst <- b.studentized_ttest(adall, ndall, 1000)
b.showsiglev (ndad_tst, "AD vs ND")

# sdad produced asl of 0.000012 for B=1000000
sdad_tst <- b.studentized_ttest(adall, sdall, 1000)
b.showsiglev (sdad_tst, "AD vs SD")

print("-----------------------------------------")
