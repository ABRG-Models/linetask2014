##
## Analysis of distance-to-target statistics.
## ALSO analysis of distance-to-distractor stats.
##
## 1) Does the distance to the target have an effect on the latency?
## This has been reported by Meegan & Tipper 99, Pratt and Abrams 94,
## Tipper et al 92 and 97.
##

maxlatency <- 1000

set.seed(197420168)

## a function which will bootstrap the standard error of the mean
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

## This takes a 2-D data set of latency vs time since last event. It
## collects "bins" of data by dividing time since last event into 30
## bins, then computes bootstrap mean & median values for each bin.
binned <- function (data, fname) {
    listPoints <- list()
    listBStrap <-  list()
    dfBStrap <- data.frame()
    nBreaks <- 30
    iter <- 1
    nResamples <- 200
    h <- hist(abs(data$direction), breaks=nBreaks, plot=F)
    bLast <- -1
    for (b in h$breaks) {
        if (b==0) {
            bLast = b
            next
        }

        points <- data[which(abs(data$direction) >= bLast & abs(data$direction) < b),]
        listPoints[[iter]] <- points

        ## Now bootstrap each member of listPoints, compute mean & std err of mean
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
    names(dfBStrap) <- c("distance","median","med.stderr","mean","mean.stderr")
    return (dfBStrap)
}

movingbinwidth <- 44 ## 44 corresponds to about 5 mm of screen; 1/7 foveal width

movingbin <- function (data, fname, distance) {

    ## First sort data wrt distance (absolute value of direction)
    ## data$distance <- abs(data$direction) # moved outside.
    data$distance <- distance
    data <- data[order(data$distance),]

    listPoints <- list()
    listBStrap <-  list()
    dfBStrap <- data.frame()
    iter <- 1
    nResamples <- 200
    maxdist <- max(data$distance)
    bLast <- -1
    for (b in unique(data$distance)) {

        if (b < movingbinwidth/2) {
            next
        }

        if (maxdist - b < movingbinwidth/2) {
            next
        }

        points <- data[which(data$distance >= b-movingbinwidth/2 & data$distance < b+movingbinwidth/2),]

        listPoints[[iter]] <- points

        ## Now bootstrap each member of listPoints, compute mean & std err of mean
        bsmed <- bs.median(points$latency, length(points$latency))
        bsmean <- bs.mean(points$latency, length(points$latency))

        if (nrow(points)) {
            ## 8.80734 mm per pixel, so this will make distance in mm.
            dfBStrap <- rbind (dfBStrap, c(b/8.80734, median(points$latency),
                                           bsmed$std.err, mean(points$latency),
                                           bsmean$std.err))
        }

        iter <- iter + 1
        bLast = b
    }
    names(dfBStrap) <- c("distance","median","med.stderr","mean","mean.stderr")

    return (dfBStrap)
}

movingbindir <- function (data, fname) {

    ## First sort data wrt direction
    data <- data[order(data$direction),]

    listPoints <- list()
    listBStrap <-  list()
    dfBStrap <- data.frame()
    iter <- 1
    nResamples <- 200
    maxdist <- max(data$direction)
    mindist <- min(data$direction)
    bLast <- -1
    for (b in unique(data$direction)) {

        if (b < mindist + movingbinwidth/2) {
            next
        }

        if (maxdist - b < movingbinwidth/2) {
            next
        }

        points <- data[which(data$direction >= b-movingbinwidth/2 & data$direction < b+movingbinwidth/2),]

        listPoints[[iter]] <- points

        # Now bootstrap each member of listPoints, compute mean & std err of mean
        bsmed <- bs.median(points$latency, length(points$latency))
        bsmean <- bs.mean(points$latency, length(points$latency))

        if (nrow(points)) {
            # 8.80734 mm per pixel, so this will make distance in mm.
            dfBStrap <- rbind (dfBStrap, c(b/8.80734, median(points$latency),
                                           bsmed$std.err, mean(points$latency),
                                           bsmean$std.err))
        }

        iter <- iter + 1
        bLast = b
    }
    names(dfBStrap) <- c("distance","median","med.stderr","mean","mean.stderr")

    return (dfBStrap)
}


##
## 1) Does event destination magnitude affect latency of target movements?
##

## This selects out target latencies and allows me to plot the
## latencies vs. distance to target (magnitude of direction)
d <- read.csv('AsyncTrials.csv')
alt <- d[which (d$type == 1 & d$latency > 0 & d$correctmove == 1 & d$omit == 0 ),c("latency","direction")]
png (filename='./r_images/async_latency_vs_dist.png')
plot (abs(alt$direction),alt$latency,xlab="Distance to target",ylab="Latency to motion (ms)")
dev.off()

d <- read.csv('SyncTrials.csv')
slt <- d[which (d$type == 1 & d$latency > 0 & d$correctmove == 1 & d$omit == 0 ),c("latency","direction")]
png (filename='./r_images/sync_latency_vs_dist.png')
plot (abs(slt$direction),slt$latency,xlab="Distance to target",ylab="Latency to motion (ms)")
dev.off()

d <- read.csv('NoDistTrials.csv')
nlt <- d[which (d$type == 1 & d$latency > 0 & d$correctmove == 1 & d$omit == 0 ),c("latency","direction")]
png (filename='./r_images/nodist_latency_vs_dist.png')
plot (abs(nlt$direction),nlt$latency,xlab="Distance to target",ylab="Latency to motion (ms)")
dev.off()

## Compute moving bootstraps
distance <- abs(alt$direction)
amb <- movingbin (alt, './r_images/async_targ_binned_latvsdist.png', distance)
distance <- abs(slt$direction)
smb <- movingbin (slt, './r_images/sync_targ_binned_latvsdist.png', distance)
distance <- abs(nlt$direction)
nmb <- movingbin (nlt, './r_images/nodist_targ_binned_latvsdist.png', distance)

## A common plotting function
plotfn <- function (nmb, smb, amb, xlimits) {
    plot (amb$distance,amb$mean, xlim=xlimits, ylim=c(270,405),
          pch=19, cex=0.2, cex.lab=1.5, cex.axis=1.5, cex.main=1.5, cex.sub=1.5,
          xlab="Distance to target (mm)",ylab="Mean latency (ms)", col="white")

    lines(amb$distance,amb$mean, lty=1, lwd=3, col="red")
    lines(amb$distance,amb$mean-1.96*amb$mean.stderr, lty=1, lwd=1, col="red")
    lines(amb$distance,amb$mean+1.96*amb$mean.stderr, lty=1, lwd=1, col="red")

    lines(smb$distance,smb$mean, lty=1, lwd=3, col="blue")
    lines(smb$distance,smb$mean-1.96*smb$mean.stderr, lty=1, lwd=1, col="blue")
    lines(smb$distance,smb$mean+1.96*smb$mean.stderr, lty=1, lwd=1, col="blue")

    lines(nmb$distance,nmb$mean, lty=1, lwd=3, col="black")
    lines(nmb$distance,nmb$mean-1.96*nmb$mean.stderr, lty=1, lwd=1, col="black")
    lines(nmb$distance,nmb$mean+1.96*nmb$mean.stderr, lty=1, lwd=1, col="black")

    lines(c(11.9,11.9),c(270,400),lty=2, lwd=2, col='steelblue')

    text (7,280, sprintf('Bin width: %.1f mm', movingbinwidth/8.807))

    legend (20, 408, bg="white",
            c("No distractor","Synchronous distractor","Asynchronous distractor","Approx. foveal extent"),
            lty=c(1,1,1,2),
            lwd=c(3,3,3,2),
            cex=1.0,
            col=c('black','blue','red','steelblue'))
}

## Do the png plot
png (filename='./r_images/movingbin_latvsdist.png')
plotfn(nmb,smb,amb,c(0,55))
dev.off()

## And the eps plot
setEPS()
postscript(file='../paper/figures/movingbin_latvsdist.eps',width=8,height=7)
plotfn(nmb,smb,amb,c(0,55))
dev.off()

##
## 2) This does the same analysis as above (latency vs. distance to
## target), but without throwing away direction information.
##
ambdir <- movingbindir (alt, './r_images/async_targ_binned_latvsdir.png')
smbdir <- movingbindir (slt, './r_images/sync_targ_binned_latvsdir.png')
nmbdir <- movingbindir (nlt, './r_images/nodist_targ_binned_latvsdir.png')
png (filename='./r_images/movingbin_latvsdir.png')
plotfn(nmbdir,smbdir,ambdir,c(-55,55))
dev.off()

##
## 3) Latency vs. distance to last distractor
##
d <- read.csv('AsyncTrials.csv')
ald <- d[which (d$type == 1 & d$latency > 0 & d$correctmove == 1 & d$omit == 0 ),c("latency","last_distractor_offset","time_since_last_distractor")]
png (filename='./r_images/async_latency_vs_lastdist.png')
plot (abs(ald$last_distractor_offset),ald$latency,xlab="Distance to last distractor",ylab="Latency to motion (ms)")
dev.off()
distance <- abs(ald$last_distractor_offset)
amb2 <- movingbin (ald, './r_images/async_targ_binned_latvsdist2.png', distance)

## A copy of plotfn() specifically for the latency to distractor.
plotfn2 <- function (aldmb, altmb, xlimits) {
    plot (altmb$distance, altmb$mean, xlim=xlimits, ylim=c(270,405),
          pch=19, cex=0.2, cex.lab=1.5, cex.axis=1.5, cex.main=1.5, cex.sub=1.5,
          xlab="Distance (mm)", ylab="Mean latency (ms)", col="white")

    lines(altmb$distance,altmb$mean, lty=1, lwd=3, col="red")
    lines(altmb$distance,altmb$mean-1.96*altmb$mean.stderr, lty=1, lwd=1, col="red")
    lines(altmb$distance,altmb$mean+1.96*altmb$mean.stderr, lty=1, lwd=1, col="red")

    lines(aldmb$distance,aldmb$mean, lty=1, lwd=3, col="seagreen3")
    lines(aldmb$distance,aldmb$mean-1.96*aldmb$mean.stderr, lty=1, lwd=1, col="seagreen3")
    lines(aldmb$distance,aldmb$mean+1.96*aldmb$mean.stderr, lty=1, lwd=1, col="seagreen3")

    lines(c(11.9,11.9),c(270,400),lty=2, lwd=2, col='steelblue')

    text (80,400, sprintf('Bin width: %.1f mm', movingbinwidth/8.807))

    legend (40, 300, bg="white",
            c("vs. distance to last distractor","vs. distance to target","Approx. foveal extent"),
            lty=c(1,1,2),
            lwd=c(3,3,2),
            cex=1.0,
            col=c('seagreen3','red','steelblue'))
}

png (filename='./r_images/movingbin_latvslastdist_async.png')
plotfn2(amb2,amb,c(0,105))
dev.off()

setEPS()
postscript(file='../paper/figures/movingbin_latvslastdist_async.eps',width=8,height=7)
plotfn2(amb2,amb,c(0,105))
dev.off()

## Quick linear regression model for latency vs. distance to last distractor
## This gives F(1,2230) = 2.799, p=0.094
lm1 <- lm(ald$latency ~ ald$last_distractor_offset)
summary(lm1)
