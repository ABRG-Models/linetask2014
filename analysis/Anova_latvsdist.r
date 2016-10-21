
prepdata <- function(d) {
    data <- d[which (d$type == 1 & d$latency > 0 & d$correctmove == 1 & d$omit == 0 ),c("latency","direction")]
    data$distance <- abs(data$direction)
    data <- data[order(data$distance),]
    # Select out non-foveal distances:
    data <- data[which(data$distance >= 11.9*8.807),]
    return (data)
}

d <- read.csv('AsyncTrials.csv')
alt <- prepdata(d)
d <- read.csv('SyncTrials.csv')
slt <- prepdata(d)
d <- read.csv('NoDistTrials.csv')
nlt <- prepdata(d)

binned <- function (data) {
    listPoints <- list()
    listBStrap <-  list()
    dfBStrap <- data.frame()
    nBreaks <- 30
    iter <- 1
    nResamples <- 200
    h <- hist(data$distance, breaks=nBreaks, plot=F)
    bLast <- -1
    for (b in h$breaks) {
        print (b)
        if (b==0) {
            bLast = b
            next
        }

        print (sprintf('points that are >= %d and < %d',bLast,b))
        points <- data[which(data$distance >= bLast & data$distance < b),]
        listPoints[[iter]] <- points

        # Now bootstrap each member of listPoints, compute mean & std err of mean
        bsmed <- bs.median(points$latency, nResamples)
        bsmean <- bs.mean(points$latency, nResamples)

        if (nrow(points)) {
            # length(points$latency)*bsmed$std.err*bsmed$std.err is an
            # attempt to get the bootstrap std err of the median as a
            # variance estimate.
            dfBStrap <- rbind (dfBStrap, c((b-bLast/2),
                                           median(points$latency),bsmed$std.err,length(points$latency)*bsmed$std.err*bsmed$std.err,
                                           mean(points$latency),bsmean$std.err,length(points$latency)*bsmean$std.err*bsmean$std.err))
        }

        iter <- iter + 1
        bLast = b
    }
    names(dfBStrap) <- c("distance","median","med.stderr","med.variance","mean","mean.stderr","mean.variance")

    return (dfBStrap)
}

plotfn <- function (dfBStrap) {
    plot (dfBStrap$distance,dfBStrap$median,
          pch=19, cex=1, cex.lab=1.5, cex.axis=1.5, cex.main=1.5, cex.sub=1.5,
            col="black")
    lines(dfBStrap$distance,dfBStrap$median, lty=1, lwd=2)
    arrows(dfBStrap$distance,dfBStrap$median-dfBStrap$med.stderr,dfBStrap$distance,dfBStrap$median+dfBStrap$med.stderr, length=0.1, angle=90, code=3, lwd=3, col='black')
}

a <- binned (alt)
s <- binned (slt)
n <- binned (nlt)

# anovas on mean and distance
ana  <- lm(mean ~ distance, data = a)
ans  <- lm(mean ~ distance, data = s)
ann  <- lm(mean ~ distance, data = n)

# another way to do this is just to apply a linear model to the un-binned data:
lma  <- lm(latency ~ distance, data = alt)
lms  <- lm(latency ~ distance, data = slt)
lmn  <- lm(latency ~ distance, data = nlt)

# In each case we get that distance predicts latency for the
# asynchronous case, but not for the synchronous or no distractor
# cases.

print (summary (lma))

print (anova(ana))
