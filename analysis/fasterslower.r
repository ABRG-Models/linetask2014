#
# This fasterSlower container is created in Bootstrap_indiv.r
#
# This is just a utility for looking at the individual bootstrap mean
# distributions.

# Recap:
sdadNoDiff<-0
adFaster<-1
sdFaster<-2

#              Set adFaster or sdFaster here---v
for (indiv in names(fasterSlower[fasterSlower==adFaster])) {
    latdat <- read.csv(indiv)

    # Extract latencies for the three conditions
    nd <- latdat[latdat$condition_str == "ND",]$latency
    sd <- latdat[latdat$condition_str == "SD",]$latency
    ad <- latdat[latdat$condition_str == "AD",]$latency

    # Make vectors of all the latencies together, for all individuals
    print(length(ndall))
    ndall <-c(ndall, nd)
    print(length(sdall))
    sdall <-c(sdall, sd)
    adall <-c(adall, ad)

    lat.n <- 1000

    # Plot will show that 87% of the possible means that I could have
    # measured for SD and AD were different with
    lat.highconf <- 0.9
    lat.lowconf <- 1-lat.highconf

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
    for(i in 1:lat.n) {
       this.samp <- nd[ sample(length(nd), length(nd), replace=TRUE) ]
       lat.nd.mean[i] <- mean(this.samp)
    }
    df <- density(lat.nd.mean, n=1024)
    plot(df, lwd=3, col=lat.ndcol, ylim=range(lat.miny,lat.maxy), xlim=range(lat.minx:lat.maxx))
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
              paste("ND latency conf. interval",lat.highconf),"ibid, SD","ibid, AD"),
            lty=c(1,2,6,1,1),
            lwd=c(3,2,2,3,3),
            col=c(lat.ndcol,lat.ndcol,lat.ndcol,lat.sdcol,lat.adcol))


    # Continue or halt?
    n <- readline(prompt="Enter 1 to stop: ")
    if (as.integer(n) == 1) {
       stop('User request')
    }
}
