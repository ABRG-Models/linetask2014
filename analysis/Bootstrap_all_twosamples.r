
set.seed(1974201701)

# Mouse data, for comparison of methods
mouse.treatment=c(94,197,16,38,99,141,23)     # zdata
mouse.control=c(52,104,146,10,51,30,40,27,46) # ydata

# This is the number of resamples to do for the bootstrap
lat.n <- length(ndall)

# Colour scheme
lat.ndallcol <- "black"
lat.sdallcol <- "steelblue"
lat.adallcol <- "red"

lat.ymin <- 0
lat.ymax <- 0.44
lat.xmin <- 290
lat.xmax <- 390
lat.legx <- 300
lat.legy <- 0.45

# Hand coded approach to computing bootstrap estimate of the mean
# difference between two samples. See p 89 of Efron for the two sample
# problem description
#
#lat.ndsd.diffs <- numeric(lat.n) # numeric vector lat.n long
#for(i in 1:lat.n) {
#    this.samp1 <- ndall[ sample(length(ndall), length(ndall), replace=TRUE) ]
#    this.samp2 <- sdall[ sample(length(sdall), length(sdall), replace=TRUE) ]
#    lat.ndsd.diffs[i] <- mean(this.samp2) - mean(this.samp1)
#}
#ndsd.std.err = sqrt(var(lat.ndsd.diffs))
#ndsd.mean = mean(lat.ndsd.diffs)
#print (paste("ND SD mean difference:",ndsd.mean))
#print (paste("ND SD difference standard error estimate:",ndsd.std.err))

# Calculates an estimate of the standard error for the difference
# between two distributions. Follows section 8.3 of Efron &
# Tibshirani, 1993 implementing Algorithm 6.1 for the difference of
# means of two sample sets.
b.diffste <- function(zdata, ydata, B) {

    ystar <- lapply(1:B, function(i) sample(ydata, size=length(ydata), replace=T))
    zstar <- lapply(1:B, function(i) sample(zdata, size=length(zdata), replace=T))

    ystarmeans <- sapply(ystar, mean)
    zstarmeans <- sapply(zstar, mean)
    theta <- zstarmeans - ystarmeans
    meantheta <- mean(theta) # theta_hat_star

    thesum <- sapply (1:B, function(i) (zstarmeans[i] - ystarmeans[i] - meantheta)^2 )
    seB <- sqrt(sum(thesum)/(B-1))

    # Observed difference of means
    diffofmeans = mean(zdata) - mean(ydata)

    list(meandiff=diffofmeans, stderr=seB)
}

mouseres0 <- b.diffste (mouse.treatment, mouse.control, 1400)

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

# Implements a bootstrapped hypothesis test to get a t-statistic. This
# follows the algorithm 16.1 described on p 221 of Efron & Tibshirani.
# data1 and data2 are the two datasets. B is the number of bootstrap
# replications to make to produce ystar and zstar. data2 is treatment,
# data1 is control.
b.test <- function(zdata, ydata, B) {
    xstar = c(ydata,zdata) # combine the data as if they were6 drawn from a single distribution
    tobs = mean(zdata) - mean(ydata) # observed value of the statistic (difference of means)
    #print (paste("length ydata: ", length(ydata)))
    ystar <- lapply(1:B, function(i) sample(xstar, size=length(ydata), replace=T))
    zstar <- lapply(1:B, function(i) sample(xstar, size=length(zdata), replace=T))
    ymeans <- sapply(ystar, mean)
    zmeans <- sapply(zstar, mean)
    diffs <- zmeans - ymeans
    numgt <- sum(diffs>=tobs)
    #print (paste("numgt:",numgt))
    asl <- numgt/B
    minasl <- 1/B # Smallest possible achieved significance level in case asl==0
    list(asl=asl, minasl=minasl)
}

# Utility function to display results
b.showsiglev <- function (asl, tag) {
    if (asl$asl == 0) {
        msg <- sprintf ("Achieved significance level for %s < %f", tag, asl$minasl)
    } else {
        msg <- sprintf ("Achieved significance level for %s = %f", tag, asl$asl)
    }
    print(msg)
}

# Reproduce result of algo 16.1 for the mouse data:
mouseres1 <- b.test(mouse.treatment, mouse.control, 1000)

print ("Algo 16.1")

# ASL < 1/4e6 (2.5e-7) with B=4e6
ndsd_t <- b.test(sdall, ndall, 1000)
b.showsiglev (ndsd_t, "SD vs ND")

# ASL < 1/4e6 (2.5e-7)
ndad_t <- b.test(adall, ndall, 1000)
b.showsiglev (ndad_t, "AD vs ND")

# With B=1000000, get asl=0.000016
sdad_t <- b.test(adall, sdall, 1000)
b.showsiglev (sdad_t, "AD vs SD")

# Compute a bootstrapped two sample t statistic as per algorithm 16.2
# in Efron & Tibshirani.
# zdata is treatment; ydata is control.
b.twosampt <- function (zdata, ydata, B) {

    n <- length(zdata)
    m <- length(ydata)

    # combine the data as if they were drawn from a single distribution
    x <- c(zdata,ydata)
    xmean <- mean(x)

    ymean <- mean(ydata)
    zmean <- mean(zdata)

    # Compute variances for the observed values:
    obsvarz <- sum((zdata-zmean)^2)/(n-1)
    obsvary <- sum((ydata-ymean)^2)/(m-1)

    # Compute the observed value of the studentised statistic (using
    # separate variances, rather than a pooled variance):
    tobs <- (zmean - ymean) / ((obsvary/m + obsvarz/n)^0.5)
    #print(sprintf("tobs=%f and xmean=%f",tobs,xmean))

    # Create shifted distributions; shifted by group mean and combined mean:
    ztilda <- zdata - mean(zdata) + xmean
    ytilda <- ydata - mean(ydata) + xmean

    # Resample from the shifted (tilda) distributions:
    zstar <- lapply(1:B, function(i) sample(ztilda, size=n, replace=T))
    ystar <- lapply(1:B, function(i) sample(ytilda, size=m, replace=T))

    # Create vectors of the means of these resamples:
    zstarmeans <- sapply(zstar, mean)
    ystarmeans <- sapply(ystar, mean)

    # Compute the variances
    zvariances <- sapply(1:B, function(i) sum((zstar[[i]] - zstarmeans[i])^2)/(n-1))
    yvariances <- sapply(1:B, function(i) sum((ystar[[i]] - ystarmeans[i])^2)/(m-1))

    top <- zstarmeans - ystarmeans
    bot <- ((yvariances/m + zvariances/n)^0.5)
    txstar <- top / bot

    numgt <- sum(txstar>=tobs)
    #print (paste("numgt:",numgt))
    asl <- numgt/B
    minasl <- 1/B # Smallest possible achieved significance level in case asl==0
    list(asl=asl, minasl=minasl,txstar=txstar)
}

# Reproduce result of Algo 16.2 for the mouse data:
mouseres2 <- b.twosampt(mouse.treatment, mouse.control, 1000)

print ("Algo 16.2 (Studentized)")
# ndsd does better than 1e-6 (set B to 1000000)
ndsd_tst <- b.twosampt(sdall, ndall, 1000)
b.showsiglev (ndsd_tst, "SD vs ND")

# ndad does better than 3e-7 (set B to 3000000)
ndad_tst <- b.twosampt(adall, ndall, 1000)
b.showsiglev (ndad_tst, "AD vs ND")

# sdad produced asl of 0.000012 for B=1000000
sdad_tst <- b.twosampt(adall, sdall, 1000)
b.showsiglev (sdad_tst, "AD vs SD")
