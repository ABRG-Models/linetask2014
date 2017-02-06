ad <- read.csv('AsyncTrials.csv')
sd <- read.csv('SyncTrials.csv')
nd <- read.csv('NoDistTrials.csv')

## Create lists of errored and non-errored latencies. Note that we omit latencies > 1 second as outliers.
tr.noerror.ad <- ad[which (ad$type == 1 & ad$latency > 0 & ad$latency < 1000 & ad$correctmove == 1 & ad$omit == 0 ),c("latency","direction")]
tr.noerror.sd <- sd[which (sd$type == 1 & sd$latency > 0 & sd$latency < 1000 & sd$correctmove == 1 & sd$omit == 0 ),c("latency","direction")]
tr.noerror.nd <- nd[which (nd$type == 1 & nd$latency > 0 & nd$latency < 1000 & nd$correctmove == 1 & nd$omit == 0 ),c("latency","direction")]
tr.error.ad <- ad[which (ad$type == 1 & ad$latency > 0 & ad$latency < 1000 & ad$correctmove == 0 & ad$omit == 0 ),c("latency","direction")]
tr.error.sd <- sd[which (sd$type == 1 & sd$latency > 0 & sd$latency < 1000 & sd$correctmove == 0 & sd$omit == 0 ),c("latency","direction")]
tr.error.nd <- nd[which (nd$type == 1 & nd$latency > 0 & nd$latency < 1000 & nd$correctmove == 0 & nd$omit == 0 ),c("latency","direction")]

set.seed(1974201702)

print('Means:')
print (sprintf('AD, noerror: %f', mean(tr.noerror.ad$latency)))
print (sprintf('AD, error: %f', mean(tr.error.ad$latency)))
print (sprintf('SD, noerror: %f', mean(tr.noerror.sd$latency)))
print (sprintf('SD, error: %f', mean(tr.error.sd$latency)))
print (sprintf('ND, noerror: %f', mean(tr.noerror.nd$latency)))
print (sprintf('ND, error: %f', mean(tr.error.nd$latency)))
print("-----------------------------------------")

# Load two sample bootstrapping functions:
source('Bootstrap_all_twosamples.r')

tr.error.ndsd <- b.diffste(tr.error.sd$latency, tr.error.nd$latency, 1024)
print (sprintf("For error trials, SD ND difference is %f, standard error estimate: %f",
               tr.error.ndsd$meandiff, tr.error.ndsd$stderr))

tr.error.ndad <- b.diffste(tr.error.ad$latency, tr.error.nd$latency, 1024)
print (sprintf("For error trials, AD ND difference is %f, standard error estimate: %f",
               tr.error.ndad$meandiff, tr.error.ndad$stderr))

tr.error.sdad <- b.diffste(tr.error.ad$latency, tr.error.sd$latency, 1024)
print (sprintf("For error trials, AD SD difference is %f, standard error estimate: %f",
               tr.error.sdad$meandiff, tr.error.sdad$stderr))



tr.noerror.ndsd <- b.diffste(tr.noerror.sd$latency, tr.noerror.nd$latency, 1024)
print (sprintf("For noerror trials, SD ND difference is %f, standard error estimate: %f",
               tr.noerror.ndsd$meandiff, tr.noerror.ndsd$stderr))

tr.noerror.ndad <- b.diffste(tr.noerror.ad$latency, tr.noerror.nd$latency, 1024)
print (sprintf("For noerror trials, AD ND difference is %f, standard error estimate: %f",
               tr.noerror.ndad$meandiff, tr.noerror.ndad$stderr))

tr.noerror.sdad <- b.diffste(tr.noerror.ad$latency, tr.noerror.sd$latency, 1024)
print (sprintf("For noerror trials, AD SD difference is %f, standard error estimate: %f",
               tr.noerror.sdad$meandiff, tr.noerror.sdad$stderr))


print("-----------------------------------------")
print ("Studentized bootstrapped hypothesis test (Algo 16.2) for No Error data")
ndsd_tst <- b.studentized_ttest(tr.noerror.sd$latency, tr.noerror.nd$latency, 10000)
b.showsiglev (ndsd_tst, "SD vs ND")

ndad_tst <- b.studentized_ttest(tr.noerror.ad$latency, tr.noerror.nd$latency, 10000)
b.showsiglev (ndad_tst, "AD vs ND")

sdad_tst <- b.studentized_ttest(tr.noerror.ad$latency, tr.noerror.sd$latency, 10000)
b.showsiglev (sdad_tst, "AD vs SD")

print("-----------------------------------------")
print ("Studentized bootstrapped hypothesis test (Algo 16.2) for Error data")
ndsd_tst <- b.studentized_ttest(tr.error.sd$latency, tr.error.nd$latency, 1000)
b.showsiglev (ndsd_tst, "SD vs ND")

ndad_tst <- b.studentized_ttest(tr.error.ad$latency, tr.error.nd$latency, 1000)
b.showsiglev (ndad_tst, "AD vs ND")

sdad_tst <- b.studentized_ttest(tr.error.ad$latency, tr.error.sd$latency, 1000)
b.showsiglev (sdad_tst, "AD vs SD")

print("-----------------------------------------")

print("Does error/noerror achieve significant effect in each condition?")
nderrnoerr_tst <- b.studentized_ttest(tr.noerror.nd$latency, tr.error.nd$latency, 1000)
b.showsiglev (nderrnoerr_tst, "ND no error vs ND error")

aderrnoerr_tst <- b.studentized_ttest(tr.noerror.ad$latency, tr.error.ad$latency, 10000)
b.showsiglev (aderrnoerr_tst, "AD no error vs AD error")

sderrnoerr_tst <- b.studentized_ttest(tr.noerror.sd$latency, tr.error.sd$latency, 50000)
b.showsiglev (sderrnoerr_tst, "SD no error vs SD error")

errnoerr.ndnd <- b.diffste(tr.error.nd$latency, tr.noerror.nd$latency, 1024)
errnoerr.sdsd <- b.diffste(tr.error.sd$latency, tr.noerror.sd$latency, 1024)
errnoerr.adad <- b.diffste(tr.error.ad$latency, tr.noerror.ad$latency, 1024)
