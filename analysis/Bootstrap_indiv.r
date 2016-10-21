# Here, I'm going to bootstrap the latencies of each individual

set.seed(19742016)

# This loads individual latencies. each file contains two columns,
# latency and condition_str. The latencies are all from non-error
# events.
fns <- list.files(pattern="IndDat*")

fasterSlower <- c()

sdadNoDiff<-0
adFaster<-1
sdFaster<-2

ndall <- c()
sdall <- c()
adall <- c()
for (indiv in fns) {

    latdat <- read.csv(indiv)

    # Extract latencies for the three conditions
    nd <- latdat[latdat$condition_str == "ND",]$latency
    sd <- latdat[latdat$condition_str == "SD",]$latency
    ad <- latdat[latdat$condition_str == "AD",]$latency

    # Make vectors of all the latencies together, for all individuals
    ndall <-c(ndall, nd)
    sdall <-c(sdall, sd)
    adall <-c(adall, ad)

    lat.n <- 1000

    # Plot will show that 87% of the possible means that I could have
    # measured for SD and AD were different with
    lat.highconf <- 0.9
    lat.lowconf <- 1-lat.highconf
    lat.confint <- 1 - 2*lat.lowconf

    # Colour scheme
    lat.ndcol <- "black"
    lat.sdcol <- "steelblue"
    lat.adcol <- "red"

    lat.minx <- min(c(nd,sd,ad))
    lat.maxx <- max(c(nd,sd,ad))
    lat.miny <- 0
    lat.maxy <- 0.15

    # ND is blue
    lat.nd.mean <- numeric(lat.n) # numeric vector lat.n long
    # This is a bootstrap loop:
    for(i in 1:lat.n) {
       this.samp <- nd[ sample(length(nd), length(nd), replace=TRUE) ]
       lat.nd.mean[i] <- mean(this.samp)
    }
    df <- density(lat.nd.mean, n=1024)

    setEPS()
    # This fails to make the eps files (dev.copy fails). However, we don't really need those for now.
    postscript(file=sprintf('../paper/figures/bootstrap_indiv_%s.eps', indiv))
    dev.copy (png, filename=sprintf('r_images/bootstrap_indiv_%s.png', indiv))
    plot(df, lwd=3, col=lat.ndcol, ylim=range(lat.miny,lat.maxy), xlim=range(lat.minx:lat.maxx), main=indiv)
    abline(v=mean(nd), lty=2, lwd=2, col=lat.ndcol)
    q5nd <- quantile(lat.nd.mean,lat.lowconf)
    abline(v=q5nd[1], lty=6, lwd=2, col=lat.ndcol)
    q95nd <- quantile(lat.nd.mean,lat.highconf)
    abline(v=q95nd[1], lty=6, lwd=2, col=lat.ndcol)


    # SD is dark red
    lat.sd.mean <- numeric(lat.n) # numeric vector lat.n long
    for(i in 1:lat.n) {
       this.samp <- sd[ sample(length(sd), length(sd), replace=TRUE) ]
       lat.sd.mean[i] <- mean(this.samp)
    }
    df <- density(lat.sd.mean, n=1024)
    lines(df, lwd=3, col=lat.sdcol, xlim=range(280:365))
    abline(v=mean(sd), lty=2, lwd=2, col=lat.sdcol)
    q5sd <- quantile(lat.sd.mean,lat.lowconf)
    abline(v=q5sd[1], lty=6, lwd=2, col=lat.sdcol)
    q95sd <- quantile(lat.sd.mean,lat.highconf)
    abline(v=q95sd[1], lty=6, lwd=2, col=lat.sdcol)


    # AD is black
    lat.ad.mean <- numeric(lat.n) # numeric vector lat.n long
    for(i in 1:lat.n) {
       this.samp <- ad[ sample(length(ad), length(ad), replace=TRUE) ]
       lat.ad.mean[i] <- mean(this.samp)
    }
    df <- density(lat.ad.mean, n=1024)
    lines(df, lwd=3, col=lat.adcol, xlim=range(280:365))
    abline(v=mean(ad), lty=2, lwd=2, col=lat.adcol)
    q5ad <- quantile(lat.ad.mean,lat.lowconf)
    abline(v=q5ad[1], lty=6, lwd=2, col=lat.adcol)
    q95ad <- quantile(lat.ad.mean,lat.highconf)
    abline(v=q95ad[1], lty=6, lwd=2, col=lat.adcol)


    # Stick in a legend
    legend (320,0.15, bg="white",
            c("PDF, ND resampled latencies","ND mean latency",
              paste("ND latency conf. interval",lat.confint),"ibid, SD","ibid, AD"),
            lty=c(1,2,6,1,1),
            lwd=c(3,2,2,3,3),
            col=c(lat.ndcol,lat.ndcol,lat.ndcol,lat.sdcol,lat.adcol))

    # Close plotting devices
    dev.off(dev.prev())
    dev.off()

    if (lat.sd.mean < lat.ad.mean) {
        if (q5ad < q95sd) {
            # overlap SD==AD
            fasterSlower[indiv] <- sdadNoDiff
        } else {
            # no overlap, SD faster
            fasterSlower[indiv] <- sdFaster
        }
    } else {
        if (q5sd < q95ad) {
            # overlap SD==AD
            fasterSlower[indiv] <- sdadNoDiff
        } else {
            # no overlap AD faster
            fasterSlower[indiv] <- adFaster
        }
    }
}


print (sprintf ("%d individuals were faster in the AD condition", length(fasterSlower[fasterSlower==adFaster])))
print (sprintf ("%d individuals were faster in the SD condition", length(fasterSlower[fasterSlower==sdFaster])))
print (sprintf ("%d individuals were no faster in either AD or SD", length(fasterSlower[fasterSlower==sdadNoDiff])))

# Output the individuals from fasterSlower in a form suitable for copy
# & paste into python, which is formatted like this:
#
# fasterSyncSubjects = ['CD1','CD2','CP','EC1','EC2','EF','IR','RF','RQ','SB2']
fssNames <- c()
fss <- "fasterSyncSubjects = ["
for (s in names(fasterSlower[fasterSlower==sdFaster])) {
    # Process name, remove "IndDat" and ".csv":
    s <- sub ("IndDat", "", s)
    s <- sub (".csv", "", s)
    fssNames <- c(fssNames, s)
    # Switch the R-form of "NA" back to the original as used in python:
    s <- sub ("NA_", "NA", s)
    fss <- sprintf ("%s '%s',", fss, s)
}
fss <- sprintf ("%s]",fss)
# Get rid of last ','
fss <- sub (",]", " ]", fss)
print (sprintf("fasterSyncSubjects (N=%d) python list code:", length(fssNames)))
print (fss)


fasNames <- c()
fas <- "fasterAsyncSubjects = ["
for (s in names(fasterSlower[fasterSlower==adFaster])) {
    s <- sub ("IndDat", "", s)
    s <- sub (".csv", "", s)
    fasNames <- c(fasNames, s)
    s <- sub ("NA_", "NA", s)
    fas <- sprintf ("%s '%s',", fas, s)
}
fas <- sprintf ("%s]",fas)
fas <- sub (",]", " ]", fas)
print (sprintf("fasterAsyncSubjects (N=%d) python list code:", length(fasNames)))
print (fas)


ndNames <- c()
nds <- "noDiffSubjects = ["
for (s in names(fasterSlower[fasterSlower==sdadNoDiff])) {
    s <- sub ("IndDat", "", s)
    s <- sub (".csv", "", s)
    ndNames <- c(ndNames, s)
    s <- sub ("NA_", "NA", s)
    nds <- sprintf ("%s '%s',", nds, s)
}
nds <- sprintf ("%s]",nds)
nds <- sub (",]", " ]", nds)
print (sprintf("noDiffSubjects (N=%d) python list code:", length(ndNames)))
print (nds)


#
# Now do analysis on ndall etc.
#

# Save some variables that are used in Bootstrap_all and Err.r
save (ndall, sdall, adall, fssNames, fasNames, ndNames, file="all_latencies.rdat", ascii=TRUE)

print ('You can now call Bootstrap_all.r for "the groupstrap"')
print ('You can also call Err.r for the per-group error analysis')
