#
# Analysis of Async-specific statistics. Especially:
#
# 1) Does last event recency affect latency of distrator movements? (Ans: No)
# 2) Does distractor recency affect latency of target movements? (Ans: No)
# 3) Does distractor in same direction as target reduce latency?
# 4) What's the reaction time for distractors cf. targets?
#

maxlatency <- 1000

# a function which will bootstrap the standard error of the mean
bs.mean <- function(data, num) {
    resamples <- lapply(1:num, function(i) sample(data, replace=T))
    r.mean <- sapply(resamples, mean)
    std.err <- sqrt(var(r.mean))
    list(std.err=std.err, resamples=resamples, means=r.mean)
}
bs.median <- function(data, num) {
    resamples <- lapply(1:num, function(i) sample(data, replace=T))
    r.median <- sapply(resamples, median)
    std.err <- sqrt(var(r.median))
    list(std.err=std.err, resamples=resamples, medians=r.median)
}

d <- read.csv('AsyncTrials.csv')

set.seed(197420162)

# This takes a 2-D data set of latency vs time since last event. It
# collects "bins" of data by dividing time since last event into 30
# bins, then computes bootstrap mean & median values for each bin.
binned <- function (data, fname) {
    listPoints <- list()
    listBStrap <-  list()
    dfBStrap <- data.frame()
    nBreaks <- 30
    iter <- 1
    nResamples <- 200
    h <- hist(data$timesincelast, breaks=nBreaks, plot=F)
    for (b in h$breaks) {
        if (b==0) {
            bLast = b
            next
        }

        points <- data[which(data$timesincelast >= bLast & data$timesincelast < b),]
        listPoints[[iter]] <- points

        # Now bootstrap each member of listPoints, compute mean & std err of mean
        bsmed <- bs.median(points$latency, nResamples)
        bsmean <- bs.mean(points$latency, nResamples)
        if (nrow(points)) {
            dfBStrap <- rbind (dfBStrap, c((b-bLast/2), median(points$latency),
                                           bsmed$std.err, mean(points$latency),
                                           bsmean$std.err))
        }

        iter <- iter + 1
        bLast = b
    }
    names(dfBStrap) <- c("timesincelast","median","med.stderr","mean","mean.stderr")

    png (filename=fname)
    plot (dfBStrap$timesincelast,dfBStrap$median, xlim=c(0,1500),# ylim=c(0,400),
          pch=19, cex=1, cex.lab=1.5, cex.axis=1.5, cex.main=1.5, cex.sub=1.5,
          xlab="Time since last event (ms)",ylab="Median latency (ms)", col="black")
    lines(dfBStrap$timesincelast,dfBStrap$median, lty=1, lwd=2)
    arrows(dfBStrap$timesincelast,dfBStrap$median-dfBStrap$med.stderr,dfBStrap$timesincelast,dfBStrap$median+dfBStrap$med.stderr, length=0.1, angle=90, code=3, lwd=3, col='black')
    dev.off()
}

#
# 1) Does last event recency affect latency of distrator movements?
#

# This selects out distractor latencies and allows me to plot the
# latencies vs. time since last event.
# Note: 15 is "stylus didn't move away from target" 16 is "movement occurs beyond next target"
dlt <- d[which (d$type == 0 & d$correctmove == 0 & d$latency<maxlatency & !(d$omit == 1 & (d$oreas == 16 | d$oreas == 15)) ),c("latency","timesincelast")]
png (filename='./r_images/async_dist_timesince_vs_latency.png')
plot (dlt$timesincelast,dlt$latency,xlab="Time since last event (ms)",ylab="Latency to distracted motion (ms)")
dev.off()
binned (dlt, './r_images/async_dist_binned_latencies.png')

#
# 2) Does distractor recency affect latency of target movements?
#
tlt <- d[which (d$type == 1 & d$correctmove == 1 & d$latency<maxlatency & d$omit == 0),c("latency","timesincelast")]
png (filename='./r_images/async_targ_timesince_vs_latency.png')
plot (tlt$timesincelast,tlt$latency)
dev.off()
binned (tlt, './r_images/async_targ_binned_latencies.png')

# Moving bin approach for timesincelast (Question 2)
movingbinwidth <- 80 # ms
movingbin <- function (data) {
    # First sort data wrt direction
    data <- data[order(data$timesincelast),]
    listPoints <- list()
    listBStrap <-  list()
    dfBStrap <- data.frame()
    iter <- 1
    nResamples <- 200
    maxtime <- 1000 # ms
    bLast <- -1
    for (b in unique(data$timesincelast)) {
        if (b < movingbinwidth/2) {
            next
        }
        if (maxtime - b < movingbinwidth/2) {
            next
        }
        points <- data[which(data$timesincelast >= b-movingbinwidth/2 & data$timesincelast < b+movingbinwidth/2),]
        listPoints[[iter]] <- points
        bsmed <- bs.median(points$latency, length(points$latency))
        bsmean <- bs.mean(points$latency, length(points$latency))
        if (nrow(points)) {
            dfBStrap <- rbind (dfBStrap, c(b, median(points$latency),
                                           bsmed$std.err, mean(points$latency),
                                           bsmean$std.err))
        }
        iter <- iter + 1
        bLast = b
    }
    names(dfBStrap) <- c("distance","median","med.stderr","mean","mean.stderr")
    return (dfBStrap)
}

amb <- movingbin (tlt)
png (filename='./r_images/async_targ_timesince_vs_latency_movingbin.png')
plot (amb$distance,amb$mean, xlim=c(0,1000), ylim=c(270,405),
      pch=19, cex=0.2, cex.lab=1.5, cex.axis=1.5, cex.main=1.5, cex.sub=1.5,
      xlab="Time since last event (ms)",ylab="Mean latency (ms)", col="white")
lines(amb$distance,amb$mean, lty=1, lwd=3, col="red")
lines(amb$distance,amb$mean-1.96*amb$mean.stderr, lty=1, lwd=1, col="red")
lines(amb$distance,amb$mean+1.96*amb$mean.stderr, lty=1, lwd=1, col="red")
dev.off()

# A linear model shows that timesincelast does not predict latency:
lmt <- lm(latency ~ timesincelast, data = tlt)
print(summary(lmt))

#
# 3) Does distractor in same direction as target reduce latency?
#

# A graphing function for target data and distractor data, both
# assumed to be simple vectors of data
bs_graph <- function(dat1, dat2, dat1label, dat2label, xrange, yrange, alpha, mean=FALSE) {

    densityN <- 256
    nResamples <- 1024
    dat1Col <- "steelblue"
    dat2Col <- "red"

    # Raw distributions
    dat1dens = density(dat1, n=512)
    dat1densScale = max(dat1dens$y)
    dat2dens = density(dat2, n=512)
    dat2densScale = max(dat2dens$y)
    xmax = max(dat1dens$x,dat2dens$x)
    xmin = min(dat1dens$x,dat2dens$x)

    if (xrange[2]==0) {
        xrange <- c(xmin,xmax)
    }

    if (mean == TRUE) {
        bsdat1 <- bs.mean(dat1, nResamples)
        q5 <- quantile(bsdat1$means,alpha)
        q95 <- quantile(bsdat1$means,1-alpha)
        df <- density(bsdat1$means, n=densityN)
        cent <- mean(dat1)
        maintitle <- sprintf("Distns of bootstrapped means. alpha=%.3f", alpha)
        bsdat2 <- bs.mean(dat2, nResamples)
        df_ <- density(bsdat2$means, n=densityN)
        centtype <- 'mean'
    } else {
        bsdat1 <- bs.median(dat1, nResamples)
        q5 <- quantile(bsdat1$medians,alpha)
        q95 <- quantile(bsdat1$medians,1-alpha)
        df <- density(bsdat1$medians, n=densityN)
        cent <- median(dat1)
        maintitle <- sprintf("Distns of bootstrapped medians. alpha=%.3f", alpha)
        bsdat2 <- bs.median(dat2, nResamples)
        df_ <- density(bsdat2$medians, n=densityN)
        centtype <- 'median'
    }

    print (sprintf('%s: %s = %f +- %f', dat1label, centtype, cent, q95-cent))
    print (sprintf('%s: std %f, mad: %f', dat1label, sd(dat1), mad(dat1)))

    if (yrange[2]==0) {
        yrange <- c(0,max(df$y,df_$y))
    }

    # Plot dat1 first
    plot(df, lwd=2, col=dat1Col, xlim=xrange, ylim=yrange,
         cex.lab=1.5, cex.axis=1.5, cex.main=1.5, cex.sub=1.5,
         main=maintitle, xlab="Latency (ms)")
    abline(v=cent, lty=2, lwd=2, col=dat1Col)
    abline(v=q5[1], lty=6, lwd=2, col=dat1Col)
    abline(v=q95[1], lty=6, lwd=2, col=dat1Col)

    dat1densScale =  max(df$y) / dat1densScale
    print (dat1densScale)
    lines(dat1dens$x, dat1dens$y * dat1densScale, lwd=2, lty=5, col=dat1Col)



    if (mean == TRUE) {
        q5 <- quantile(bsdat2$means,alpha)
        q95 <- quantile(bsdat2$means,1-alpha)
        df <- density(bsdat2$means, n=densityN)
        cent <- mean(dat2)
    } else {
        q5 <- quantile(bsdat2$medians,alpha)
        q95 <- quantile(bsdat2$medians,1-alpha)
        df <- density(bsdat2$medians, n=densityN)
        cent <- median(dat2)
    }

    print (sprintf('%s: %s = %f +- %f', dat2label, centtype, cent, q95-cent))
    print (sprintf('%s: std %f, mad: %f', dat2label, sd(dat2), mad(dat2)))

    # Now plot dat2
    lines(df, lwd=2, col=dat2Col,
          cex.lab=1.5, cex.axis=1.5, cex.main=1.5, cex.sub=1.5,
          main=maintitle, xlab="Latency (ms)")
    abline(v=cent, lty=2, lwd=2, col=dat2Col)
    abline(v=q5[1], lty=6, lwd=2, col=dat2Col)
    abline(v=q95[1], lty=6, lwd=2, col=dat2Col)

    dat2densScale =  max(df$y) / dat2densScale
    lines(dat2dens$x, dat2dens$y * dat2densScale, lwd=2, lty=5, col=dat2Col)

    legend ("topleft", c(dat1label, dat2label),
            lty=c(1,1),
            lwd=c(2,2),
            col=c(dat1Col,dat2Col)
            )
    legend ("topright", c('bootstrap distribution','raw distn (scaled)',centtype,'bootstrap conf. interval'),
            lty=c(1,5,2,6),
            lwd=c(2,2,2,2),
            col=c(dat1Col,dat1Col,dat1Col,dat1Col)
            )

}

# Get filenames:
fns <- list.files(pattern="AsyncDat*")
# Create container
d2 <- data.frame()
for (indiv in fns) {
    dat <- read.csv(indiv)
    # Add the 'opposite' column:
    dat$opposite <- 0
    # From this individual's data, find those targets for which prev. distractor is in same direction.
    for (i in 1:nrow(dat)) {
        if (dat[i,]$type == 1.0) {
            # 1 is TARG_EVENT
            earlier <- dat[which (dat$type == 0 & dat$num < i),]
            if (nrow(earlier)) {
                # Got earlier events, now find most recent earlier
                # event and extract its destination. Compare this with
                # the target destination.
                dest_d <- earlier[earlier$num==max(earlier$num),]$destination
                dest_t <- dat[i,]$destination
                dir_t <- dat[i,]$direction
                start <- dest_t - dir_t
                if ((dest_d < start & dest_t > start)
                    | (dest_d > start & dest_t < start)) {
                    # targ and dist in opposite directions
                    dat[i,]$opposite=1
                } else {
                    # targ and dist NOT in opposite directions
                }

            }
        }
    }
    # Lastly? combine data frame with the others to make up a return
    # data frame from which I can determine if opposite makes a
    # difference.
    d2 <- rbind(d2,dat)
}
# Extract opposite and same-side data:
tlt_opp <- d2[which (d2$type == 1 & d2$opposite == 1 & d2$correctmove == 1 & d2$latency<maxlatency & d2$omit == 0),]$latency
tlt_same <- d2[which (d2$type == 1 & d2$opposite == 0 & d2$correctmove == 1 & d2$latency<maxlatency & d2$omit == 0),c("latency")]
# Now make a nice graph:
png(filename='./r_images/async_targ_vs_oppositeness_of_distractor.png')
xrange <- c(325,360)
yrange <- c(0,0)
bs_graph(tlt_opp, tlt_same, "distractor opposite", "distractor same", xrange, yrange, 0.05, FALSE) # TRUE for mean rather than median.
dev.off()
# This appears to show that it is likely (0.79 probability) that the
# "distractor opposite" does have a small effect, increasing the
# latency by about 5 ms. However, there's a 0.1958 probability that
# the "distractor opposite" makes *no difference* to the latency and a
# 0.0121 probability that the "distractor opposite" actually decreases
# the latency. A 0.2 probability of no effect/the means being opposite
# doesn't pass the usual 0.05 alpha test, so conclude that this is
# still non-significant.


#
# 4) What's the reaction time for distractors cf. targets?
#
png(filename='./r_images/async_targ_vs_dist.png')
xrange <- c(180,500)
yrange <- c(0,0)
print('Async mean')
bs_graph (tlt$latency, dlt$latency, "target latency","distractor latency", xrange, yrange, 0.001, TRUE)
dev.off()
png(filename='./r_images/async_targ_vs_dist_median.png')
xrange <- c(180,500)
yrange <- c(0,0)
print('Async median')
bs_graph (tlt$latency, dlt$latency, "target latency","distractor latency", xrange, yrange, 0.001, FALSE)
dev.off()


#
# Last - sync trials.
#
d <- read.csv('SyncTrials.csv')
set.seed(197420163)
# distracted latencies. correctmove is 0 when definitely incorrect, -1 when undetermined and 1 when definitely correct.
dlt <- d[which (d$correctmove == 0 & d$latency<maxlatency & d$latency>0),]$latency
tlt <- d[which (d$correctmove == 1 & d$latency<maxlatency & d$latency>0),]$latency
png(filename='./r_images/sync_targ_vs_dist.png')
xrange <- c(150,550)
yrange <- c(0,0)
print('Sync mean')
bs_graph (tlt, dlt, "target latency","distractor latency", xrange, yrange, 0.001, TRUE)
dev.off()

png(filename='./r_images/sync_targ_vs_dist_median.png')
xrange <- c(150,550)
yrange <- c(0,.33)
print('Sync median')
bs_graph (tlt, dlt, "target latency","distractor latency", xrange, yrange, 0.001, FALSE)
dev.off()


#
# REALLY Last - nodist trials.
#
d <- read.csv('NoDistTrials.csv')
set.seed(197420166)
# distracted latencies. correctmove is 0 when definitely incorrect, -1 when undetermined and 1 when definitely correct.
dlt <- d[which (d$correctmove == 0 & d$latency<maxlatency & d$latency>100),]$latency
tlt <- d[which (d$correctmove == 1 & d$latency<maxlatency & d$latency>100),]$latency
png(filename='./r_images/nodist_targ_vs_dist.png')
xrange <- c(80,550)
yrange <- c(0,0)
print('Nodist mean')
bs_graph (tlt, dlt, "target latency","distractor latency", xrange, yrange, 0.01, TRUE)
dev.off()

png(filename='./r_images/nodist_targ_vs_dist_median.png')
xrange <- c(80,550)
yrange <- c(0,0)
print('Nodist median')
bs_graph (tlt, dlt, "target latency","distractor latency", xrange, yrange, 0.01, FALSE)
dev.off()
