#
# Two sample analysis as in Bootstrap_two.r requiring >120GB of RAM to
# run (or a re-code)
#


set.seed(1974201701)

load(file="all_latencies.rdat")
source('Bootstrap_all_twosamples.r')

print("-----------------------------------------")
print ("Studentized bootstrapped hypothesis test (Algo 16.2)")
# ndsd does better than 1e-6 (set B to 1000000)
ndsd_tst <- b.studentized_ttest(sdall, ndall, 4000000)
b.showsiglev (ndsd_tst, "SD vs ND")

# ndad does better than 3e-7 (set B to 3000000)
ndad_tst <- b.studentized_ttest(adall, ndall, 4000000)
b.showsiglev (ndad_tst, "AD vs ND")

# sdad produced asl of 0.000015 for B=4000000
sdad_tst <- b.studentized_ttest(adall, sdall, 4000000)
b.showsiglev (sdad_tst, "AD vs SD")

print("-----------------------------------------")
