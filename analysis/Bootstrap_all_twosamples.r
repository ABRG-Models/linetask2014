

# Efron & Tibshirani example mouse data, for comparison of methods.
mouse.treatment=c(94,197,16,38,99,141,23)     # zdata
mouse.control=c(52,104,146,10,51,30,40,27,46) # ydata

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

# Implements a bootstrapped hypothesis test to get a t-statistic. This
# follows the algorithm 16.1 described on p 221 of Efron & Tibshirani.
# data1 and data2 are the two datasets. B is the number of bootstrap
# replications to make to produce ystar and zstar. data2 is treatment,
# data1 is control.
b.ttest <- function(zdata, ydata, B) {
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

# Utility function to display Achieved Significance Level (ASL) result.
b.showsiglev <- function (asl, tag) {
    if (asl$asl == 0) {
        msg <- sprintf ("Achieved significance level for %s < %f", tag, asl$minasl)
    } else {
        msg <- sprintf ("Achieved significance level for %s = %f", tag, asl$asl)
    }
    print(msg)
}

# Reproduce result of algo 16.1 for the mouse data:
mouseres1 <- b.ttest(mouse.treatment, mouse.control, 1000)

# Compute a bootstrapped two sample t statistic as per algorithm 16.2
# in Efron & Tibshirani.
# zdata is treatment; ydata is control.
b.studentized_ttest <- function (zdata, ydata, B) {

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
mouseres2 <- b.studentized_ttest(mouse.treatment, mouse.control, 1000)
