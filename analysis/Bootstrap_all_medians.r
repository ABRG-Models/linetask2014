#
# Now do analysis on ndall etc.
#
# This assumes ndall, sdall and adall have been generated from Bootstrap_indiv.r
#
# This is the bootstrapping version of the group analysis.
#

load(file="all_latencies.rdat")

set.seed(197420161)

# This is the number of resamples to do for the bootstrap
lat.n <- length(ndall)
print(paste("number of bootstrap resamples:",lat.n))
print(paste("number of ND samples:",length(ndall)))
print(paste("number of SD samples:",length(sdall)))
print(paste("number of AD samples:",length(adall)))

# Plot will show that 87% of the possible means that I could have
# measured for SD and ADALL were different with
lat.highconf <- 0.998 # or .998
lat.lowconf <- 1-lat.highconf
lat.95conf <- 0.95
lat.05conf <- 0.05

# Colour scheme
lat.ndallcol <- "black"
lat.sdallcol <- "steelblue"
lat.adallcol <- "red"

lat.ymin <- 0
lat.ymax <- 0.44
lat.xmin <- 290
lat.xmax <- 350
lat.legx <- 307
lat.legy <- 0.45

# Use the means a lot so compute 'em
lat.nd.mean = mean(ndall)
lat.sd.mean = mean(sdall)
lat.ad.mean = mean(adall)
lat.nd.median = median(ndall)
lat.sd.median = median(sdall)
lat.ad.median = median(adall)

setEPS()
postscript(file='../paper/figures/bootstrapped_medians.eps')

# ND is blue
lat.ndall.medians <- numeric(lat.n) # numeric vector lat.n long
for(i in 1:lat.n) {
   this.samp <- ndall[ sample(length(ndall), length(ndall), replace=TRUE) ]
   lat.ndall.medians[i] <- median(this.samp)
}
nd.std.err = sqrt(var(lat.ndall.medians))
print (paste("ND std err estimate:",nd.std.err))
df <- density(lat.ndall.medians, n=32)
plot(df, lwd=3, col=lat.ndallcol, ylim=c(lat.ymin,lat.ymax), xlim=c(lat.xmin,lat.xmax),
     cex.lab=1.5, cex.axis=1.5, cex.main=1.5, cex.sub=1.5,
     main="Distributions of bootstrapped medians", xlab="Latency (ms)")
abline(v=lat.nd.median, lty=2, lwd=2, col=lat.ndallcol)
ndq1 <- quantile(lat.ndall.medians,lat.lowconf)
abline(v=ndq1[1], lty=6, lwd=2, col=lat.ndallcol)
ndq99 <- quantile(lat.ndall.medians,lat.highconf)
abline(v=ndq99[1], lty=6, lwd=2, col=lat.ndallcol)


# Attempt to add the ND density plots for the individual results (just needs scaling)
#lines(density(ndall), lwd=2, col=lat.ndallcol)


# SDALL is dark red
lat.sdall.medians <- numeric(lat.n) # numeric vector lat.n long
for(i in 1:lat.n) {
   this.samp <- sdall[ sample(length(sdall), length(sdall), replace=TRUE) ]
   lat.sdall.medians[i] <- median(this.samp)
}
sd.std.err = sqrt(var(lat.sdall.medians))
print (paste("SD std err estimate:",sd.std.err))
df_sd<- density(lat.sdall.medians, n=32)
lines(df_sd, lwd=3, col=lat.sdallcol, xlim=c(lat.xmin,lat.xmax))
abline(v=lat.sd.median, lty=2, lwd=2, col=lat.sdallcol)
sdq1 <- quantile(lat.sdall.medians,lat.lowconf)
abline(v=sdq1[1], lty=6, lwd=2, col=lat.sdallcol)
sdq99 <- quantile(lat.sdall.medians,lat.highconf)
abline(v=sdq99[1], lty=6, lwd=2, col=lat.sdallcol)


# ADALL is black
lat.adall.medians <- numeric(lat.n) # numeric vector lat.n long
for(i in 1:lat.n) {
   this.samp <- adall[ sample(length(adall), length(adall), replace=TRUE) ]
   lat.adall.medians[i] <- median(this.samp)
}
ad.std.err = sqrt(var(lat.adall.medians))
print (paste("AD std err estimate:",ad.std.err))
df_ad<- density(lat.adall.medians, n=32)
lines(df_ad, lwd=3, col=lat.adallcol, xlim=c(lat.xmin,lat.xmax))
abline(v=lat.ad.median, lty=2, lwd=2, col=lat.adallcol)
adq1 <- quantile(lat.adall.medians,lat.lowconf)
abline(v=adq1[1], lty=6, lwd=2, col=lat.adallcol)
adq99 <- quantile(lat.adall.medians,lat.highconf)
abline(v=adq99[1], lty=6, lwd=2, col=lat.adallcol)


# Stick in a legend
legend (lat.legx, lat.legy, bg="white",
        c("PDF, ND resampled latencies",
          sprintf("ND median latency (%.1f ms, se=%.1f)", lat.nd.median, nd.std.err),
          sprintf("ND latency %.3f confidence interval=%.1f", lat.highconf, ndq99-lat.nd.median),
          sprintf("SD, median=%.1f ms, ci=%.1f, se=%.1f", lat.sd.median, sdq99-lat.sd.median, sd.std.err),
          sprintf("AD, median=%.1f ms, ci=%.1f, se=%.1f", lat.ad.median, adq99-lat.ad.median, ad.std.err)),
        lty=c(1,2,6,1,1),
        lwd=c(3,2,2,3,3),
        col=c(lat.ndallcol,lat.ndallcol,lat.ndallcol,lat.sdallcol,lat.adallcol))

dev.off()

# Repeat the above for png...
png (filename='./r_images/bootstrapped_medians.png')

plot(df, lwd=3, col=lat.ndallcol, ylim=c(lat.ymin,lat.ymax), xlim=c(lat.xmin,lat.xmax),
     cex.lab=1.5, cex.axis=1.5, cex.main=1.5, cex.sub=1.5,
     main="Distributions of bootstrapped medians", xlab="Latency (ms)")
abline(v=lat.nd.median, lty=2, lwd=2, col=lat.ndallcol)
abline(v=ndq1[1], lty=6, lwd=2, col=lat.ndallcol)
abline(v=ndq99[1], lty=6, lwd=2, col=lat.ndallcol)

lines(df_sd, lwd=3, col=lat.sdallcol, xlim=c(lat.xmin,lat.xmax))
abline(v=lat.sd.median, lty=2, lwd=2, col=lat.sdallcol)
abline(v=sdq1[1], lty=6, lwd=2, col=lat.sdallcol)
abline(v=sdq99[1], lty=6, lwd=2, col=lat.sdallcol)

lines(df_ad, lwd=3, col=lat.adallcol, xlim=c(lat.xmin,lat.xmax))
abline(v=lat.ad.median, lty=2, lwd=2, col=lat.adallcol)
abline(v=adq1[1], lty=6, lwd=2, col=lat.adallcol)
abline(v=adq99[1], lty=6, lwd=2, col=lat.adallcol)

dev.off()

#
# A nicer method to bootstrap the medians:
#

#function which will bootstrap the standard error of the median
b.median <- function(data, num) {
    resamples <- lapply(1:num, function(i) sample(data, replace=T))
    r.median <- sapply(resamples, median)
    std.err <- sqrt(var(r.median))
    list(std.err=std.err, resamples=resamples, medians=r.median)
}

#function which will bootstrap the standard error of the median
b.mean <- function(data, num) {
    resamples <- lapply(1:num, function(i) sample(data, replace=T))
    r.mean <- sapply(resamples, mean)
    std.err <- sqrt(var(r.mean))
    list(std.err=std.err, resamples=resamples, means=r.mean)
}

bmedian <- b.median(ndall, lat.n)
print (paste("Std. error of the median estimate for ND:",bmedian$std.err))
bmedian <- b.median(sdall, lat.n)
print (paste("Std. error of the median estimate for SD:",bmedian$std.err))
bmedian <- b.median(adall, lat.n)
print (paste("Std. error of the median estimate for AD:",bmedian$std.err))

# Show what this distro looks like on the graph:
#lines(density(bmedian$medians), lwd=1, col="orange", xlim=range(lat.xmin:lat.xmax))

x=c(1, 2, 3)
y=c(median(ndall),median(sdall),median(adall))
print ("latency medians, ND, SD, AD")
print(y)

# median absolute deviation:
ye_mad=c(mad(ndall),mad(sdall),mad(adall))
print ("MADs of latencies")
print(ye_mad)

ye_sd=c(sd(ndall),sd(sdall),sd(adall))
print ("SDs of latencies")
print(ye_sd)


# Standard error of the median:
ye_se=c(nd.std.err,sd.std.err,ad.std.err)
print ("SE of median")
print(ye_se)

# 95% confidence intervals:
ndq5 <- quantile(lat.ndall.medians,lat.05conf)
ndq95 <- quantile(lat.ndall.medians,lat.95conf)
sdq5 <- quantile(lat.sdall.medians,lat.05conf)
sdq95 <- quantile(lat.sdall.medians,lat.95conf)
adq5 <- quantile(lat.adall.medians,lat.05conf)
adq95 <- quantile(lat.adall.medians,lat.95conf)
ye_ci=c(abs(median(ndall)-ndq95),abs(median(sdall)-sdq95),abs(median(adall)-adq95))
# Save ye_ci for use in Err.r:
save(ye_ci, file="ye_ci.rdat", ascii=TRUE)

print ("95% confidence")
print (ye_ci)

xl=c("ND","SD","AD")
setEPS()
postscript('../paper/figures/medianmad.eps')
# R doesn't do error bars in its plots, so you can make arrows to do the same:
plot (x,y,ylim=c(range(y-ye_ci, y+ye_ci)), pch=19, cex=2, cex.lab=1.5, cex.axis=1.5, cex.main=1.5, cex.sub=1.5, xlab="Condition",ylab="Latency to first movement (ms)", main="Median latencies with 95% conf. intervals", xaxt="n")

axis(side=1,at=x,labels=xl,tck=-.02, cex.lab=1.5, cex.axis=1.5)
#arrows(x,y-ye_mad,x,y+ye_mad, length=0.05, angle=90, code=3)
#arrows(x,y-ye_se,x,y+ye_se, length=0.05, angle=90, code=3, col='steelblue')
arrows(x,y-ye_ci,x,y+ye_ci, length=0.1, angle=90, code=3, lwd=3, col='black')

dev.off()

# Repeat for PNG
png (filename='r_images/medianmad.png')
plot (x,y,ylim=c(range(y-ye_ci, y+ye_ci)), pch=19, cex=2, cex.lab=1.5, cex.axis=1.5, cex.main=1.5, cex.sub=1.5, xlab="Condition",ylab="Latency to first movement (ms)", main="Median latencies with 95% conf. intervals", xaxt="n")
axis(side=1,at=x,labels=xl,tck=-.02, cex.lab=1.5, cex.axis=1.5)
arrows(x,y-ye_ci,x,y+ye_ci, length=0.1, angle=90, code=3, lwd=3, col='black')
dev.off()

#
# Make another graph, this time the density of the raw data.
#
print ('raw distributions')
setEPS()
postscript('../paper/figures/data_density_median.eps')

lat.raw.xmin <- 200
lat.raw.xmax <- 800
lat.raw.ymin <- 0
lat.raw.ymax <- 0.012
lat.raw.legx <- 430
lat.raw.legy <- 0.012
# ND is blue
df <- density(ndall, n=1024)
plot(df, lwd=3, col=lat.ndallcol, ylim=c(lat.raw.ymin,lat.raw.ymax), xlim=c(lat.raw.xmin,lat.raw.xmax),
     cex.lab=1.5, cex.axis=1.5, cex.main=1.5, cex.sub=1.5,
     main="Latency measurement distributions", xlab="Latency (ms)")
abline(v=lat.nd.median, lty=2, lwd=2, col=lat.ndallcol)

df1 <- density(sdall, n=1024)
lines(df1, lwd=3, col=lat.sdallcol, xlim=c(lat.raw.xmin:lat.raw.xmax))
abline(v=lat.sd.median, lty=2, lwd=2, col=lat.sdallcol)

df2 <- density(adall, n=1024)
lines(df2, lwd=3, col=lat.adallcol, xlim=c(lat.raw.xmin:lat.raw.xmax))
abline(v=lat.ad.median, lty=2, lwd=2, col=lat.adallcol)

legend (lat.raw.legx, lat.raw.legy, bg="white",
        c("PDF, ND latencies",
          sprintf("ND median latency (%.1f ms)", lat.nd.median),
          "PDF, SD latencies",
          sprintf("SD median latency (%.1f ms)", lat.sd.median),
          "PDF, AD latencies",
          sprintf("AD median latency (%.1f ms)", lat.ad.median)),
        lty=c(1,2,1,2,1,2),
        lwd=c(3,2,3,2,3,2),
        col=c(lat.ndallcol,lat.ndallcol,lat.sdallcol,lat.sdallcol,lat.adallcol,lat.adallcol))

dev.off()

# Repeat for PNG
png (filename='r_images/data_density_median.png')
plot(df, lwd=3, col=lat.ndallcol, ylim=c(lat.raw.ymin,lat.raw.ymax), xlim=c(lat.raw.xmin,lat.raw.xmax),
     cex.lab=1.5, cex.axis=1.5, cex.main=1.5, cex.sub=1.5,
     main="Latency measurement distributions", xlab="Latency (ms)")
abline(v=lat.nd.median, lty=2, lwd=2, col=lat.ndallcol)

lines(df1, lwd=3, col=lat.sdallcol, xlim=c(lat.raw.xmin:lat.raw.xmax))
abline(v=lat.sd.median, lty=2, lwd=2, col=lat.sdallcol)

lines(df2, lwd=3, col=lat.adallcol, xlim=c(lat.raw.xmin:lat.raw.xmax))
abline(v=lat.ad.median, lty=2, lwd=2, col=lat.adallcol)

legend (lat.raw.legx, lat.raw.legy, bg="white",
        c("PDF, ND latencies",
          sprintf("ND median latency (%.1f ms)", lat.nd.median),
          "PDF, SD latencies",
          sprintf("SD median latency (%.1f ms)", lat.sd.median),
          "PDF, AD latencies",
          sprintf("AD median latency (%.1f ms)", lat.ad.median)),
        lty=c(1,2,1,2,1,2),
        lwd=c(3,2,3,2,3,2),
        col=c(lat.ndallcol,lat.ndallcol,lat.sdallcol,lat.sdallcol,lat.adallcol,lat.adallcol))
dev.off()
