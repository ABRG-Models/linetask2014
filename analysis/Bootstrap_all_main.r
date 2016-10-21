
set.seed(197420161)

# This is the number of resamples to do for the bootstrap
lat.n <- length(ndall)
print(paste("number of bootstrap resamples:",lat.n))
print(paste("number of ND samples:",length(ndall)))
print(paste("number of SD samples:",length(sdall)))
print(paste("number of AD samples:",length(adall)))

# Plot will show that 87% of the possible means that I could have
# measured for SD and ADALL were different with
lat.highconf <- 0.9983 # or .998
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
lat.xmax <- 390
lat.legx <- 300
lat.legy <- 0.45

# Use the means a lot so compute 'em
lat.nd.mean = mean(ndall)
lat.sd.mean = mean(sdall)
lat.ad.mean = mean(adall)

setEPS()
postscript(file=sprintf('../paper/figures/bootstrapped_means_%s.eps',filesuffix),width=8,height=5)

par(mar=c(5,5,3,5)) # may need to change depending on errd.fontsize
par(oma=c(0,0,0,0) )

# ND is blue
lat.ndall.means <- numeric(lat.n) # numeric vector lat.n long
for(i in 1:lat.n) {
   this.samp <- ndall[ sample(length(ndall), length(ndall), replace=TRUE) ]
   lat.ndall.means[i] <- mean(this.samp)
}
nd.std.err = sqrt(var(lat.ndall.means))
print (paste("ND std err estimate:",nd.std.err))
df <- density(lat.ndall.means, n=1024)
plot(df, lwd=3, col=lat.ndallcol, ylim=c(lat.ymin,lat.ymax), xlim=c(lat.xmin,lat.xmax),
     cex.lab=1.8, cex.axis=1.8, cex.main=1.8, cex.sub=1.8,
     main="Distributions of bootstrapped means", xlab="Latency (ms)")
abline(v=lat.nd.mean, lty=2, lwd=2, col=lat.ndallcol)
ndq1 <- quantile(lat.ndall.means,lat.lowconf)
abline(v=ndq1[1], lty=6, lwd=2, col=lat.ndallcol)
ndq99 <- quantile(lat.ndall.means,lat.highconf)
abline(v=ndq99[1], lty=6, lwd=2, col=lat.ndallcol)


# Attempt to add the ND density plots for the individual results (just needs scaling)
#lines(density(ndall), lwd=2, col=lat.ndallcol)


# SDALL is dark red
lat.sdall.means <- numeric(lat.n) # numeric vector lat.n long
for(i in 1:lat.n) {
   this.samp <- sdall[ sample(length(sdall), length(sdall), replace=TRUE) ]
   lat.sdall.means[i] <- mean(this.samp)
}
sd.std.err = sqrt(var(lat.sdall.means))
print (paste("SD std err estimate:",sd.std.err))
df_sd<- density(lat.sdall.means, n=1024)
lines(df_sd, lwd=3, col=lat.sdallcol, xlim=c(lat.xmin,lat.xmax))
abline(v=lat.sd.mean, lty=2, lwd=2, col=lat.sdallcol)
sdq1 <- quantile(lat.sdall.means,lat.lowconf)
abline(v=sdq1[1], lty=6, lwd=2, col=lat.sdallcol)
sdq99 <- quantile(lat.sdall.means,lat.highconf)
abline(v=sdq99[1], lty=6, lwd=2, col=lat.sdallcol)


# ADALL is black
lat.adall.means <- numeric(lat.n) # numeric vector lat.n long
for(i in 1:lat.n) {
   this.samp <- adall[ sample(length(adall), length(adall), replace=TRUE) ]
   lat.adall.means[i] <- mean(this.samp)
}
ad.std.err = sqrt(var(lat.adall.means))
print (paste("AD std err estimate:",ad.std.err))
df_ad<- density(lat.adall.means, n=1024)
lines(df_ad, lwd=3, col=lat.adallcol, xlim=c(lat.xmin,lat.xmax))
abline(v=lat.ad.mean, lty=2, lwd=2, col=lat.adallcol)
adq1 <- quantile(lat.adall.means,lat.lowconf)
abline(v=adq1[1], lty=6, lwd=2, col=lat.adallcol)
adq99 <- quantile(lat.adall.means,lat.highconf)
abline(v=adq99[1], lty=6, lwd=2, col=lat.adallcol)


# Stick in a legend
legend (lat.legx, lat.legy, bg="white",
        c("No distractor","Synchronous distractor","Asynchronous distractor"),
        lty=c(1,1,1),
        lwd=c(3,3,3),
        cex=1.2,
        col=c(lat.ndallcol,lat.sdallcol,lat.adallcol))

#legend (lat.legx, lat.legy, bg="white",
#        c("PDF, ND resampled latencies",
#          sprintf("ND mean latency (%.1f ms, se=%.1f)", lat.nd.mean, nd.std.err),
#          sprintf("ND latency %.3f confidence interval=%.1f", lat.highconf, ndq99-lat.nd.mean),
#          sprintf("SD, mean=%.1f ms, ci=%.1f, se=%.1f", lat.sd.mean, sdq99-lat.sd.mean, sd.std.err),
#          sprintf("AD, mean=%.1f ms, ci=%.1f, se=%.1f", lat.ad.mean, adq99-lat.ad.mean, ad.std.err),
#        lty=c(1,2,6,1,1),
#        lwd=c(3,2,2,3,3),
#        col=c(lat.ndallcol,lat.ndallcol,lat.ndallcol,lat.sdallcol,lat.adallcol))

dev.off()

# Repeat the above for png...
png (filename=sprintf('./r_images/bootstrapped_means_%s.png', filesuffix))

plot(df, lwd=3, col=lat.ndallcol, ylim=c(lat.ymin,lat.ymax), xlim=c(lat.xmin,lat.xmax),
     cex.lab=1.8, cex.axis=1.8, cex.main=1.8, cex.sub=1.8,
     main="Distributions of bootstrapped means", xlab="Latency (ms)")
abline(v=lat.nd.mean, lty=2, lwd=2, col=lat.ndallcol)
abline(v=ndq1[1], lty=6, lwd=2, col=lat.ndallcol)
abline(v=ndq99[1], lty=6, lwd=2, col=lat.ndallcol)

lines(df_sd, lwd=3, col=lat.sdallcol, xlim=c(lat.xmin,lat.xmax))
abline(v=lat.sd.mean, lty=2, lwd=2, col=lat.sdallcol)
abline(v=sdq1[1], lty=6, lwd=2, col=lat.sdallcol)
abline(v=sdq99[1], lty=6, lwd=2, col=lat.sdallcol)

lines(df_ad, lwd=3, col=lat.adallcol, xlim=c(lat.xmin,lat.xmax))
abline(v=lat.ad.mean, lty=2, lwd=2, col=lat.adallcol)
abline(v=adq1[1], lty=6, lwd=2, col=lat.adallcol)
abline(v=adq99[1], lty=6, lwd=2, col=lat.adallcol)

dev.off()

#
# A nicer method to bootstrap the means:
#

#function which will bootstrap the standard error of the median
b.median <- function(data, num) {
    resamples <- lapply(1:num, function(i) sample(data, replace=T))
    r.median <- sapply(resamples, median)
    std.err <- sqrt(var(r.median))
    list(std.err=std.err, resamples=resamples, medians=r.median)
}

#function which will bootstrap the standard error of the mean
b.mean <- function(data, num) {
    resamples <- lapply(1:num, function(i) sample(data, replace=T))
    r.mean <- sapply(resamples, mean)
    std.err <- sqrt(var(r.mean))
    list(std.err=std.err, resamples=resamples, means=r.mean)
}

bmean <- b.median(ndall, lat.n)
print (paste("Std. error of the median estimate for ND:",bmean$std.err))
bmean <- b.mean(sdall, lat.n)
print (paste("Std. error of the mean estimate for SD:",bmean$std.err))
bmean <- b.mean(adall, lat.n)
print (paste("Std. error of the mean estimate for AD:",bmean$std.err))

# Show what this distro looks like on the graph:
#lines(density(bmean$means), lwd=1, col="orange", xlim=range(lat.xmin:lat.xmax))

x=c(1, 2, 3)
y=c(mean(ndall),mean(sdall),mean(adall))
print ("latency means, ND, SD, AD")
print(y)

# median absolute deviation:
ye_mad=c(mad(ndall),mad(sdall),mad(adall))
print ("MADs of latencies")
print(ye_mad)

ye_sd=c(sd(ndall),sd(sdall),sd(adall))
print ("SDs of latencies")
print(ye_sd)


# Standard error of the mean:
ye_se=c(nd.std.err,sd.std.err,ad.std.err)
print ("SE of mean")
print(ye_se)

# 95% confidence intervals:
ndq5 <- quantile(lat.ndall.means,lat.05conf)
ndq95 <- quantile(lat.ndall.means,lat.95conf)
sdq5 <- quantile(lat.sdall.means,lat.05conf)
sdq95 <- quantile(lat.sdall.means,lat.95conf)
adq5 <- quantile(lat.adall.means,lat.05conf)
adq95 <- quantile(lat.adall.means,lat.95conf)
ye_ci=c(abs(mean(ndall)-ndq95),abs(mean(sdall)-sdq95),abs(mean(adall)-adq95))
# Save ye_ci for use in Err.r:
save(ye_ci, file=sprintf("ye_ci_%s.rdat",filesuffix), ascii=TRUE)

print ("95% confidence")
print (ye_ci)

xl=c("ND","SD","AD")
setEPS()
postscript(sprintf('../paper/figures/meanmad_%s.eps',filesuffix),width=8,height=5)
# R doesn't do error bars in its plots, so you can make arrows to do the same:
par(mar=c(5,5,3,5)) # may need to change depending on errd.fontsize
par(oma=c(0,0,0,0) )
plot (x,y,ylim=c(range(y-ye_ci, y+ye_ci)), mgp=c(3.5,1,0), pch=19, cex=2, cex.lab=1.8, cex.axis=1.8, cex.main=1.8, cex.sub=1.8, xlab="Condition",ylab="Latency to first movement (ms)", main="Mean latencies with 95% conf. intervals", xaxt="n")

axis(side=1,at=x,labels=xl,tck=-.02, cex.lab=1.8, cex.axis=1.8)
#arrows(x,y-ye_mad,x,y+ye_mad, length=0.05, angle=90, code=3)
#arrows(x,y-ye_se,x,y+ye_se, length=0.05, angle=90, code=3, col='steelblue')
arrows(x,y-ye_ci,x,y+ye_ci, length=0.1, angle=90, code=3, lwd=3, col='black')

dev.off()

# Repeat for PNG
png (filename=sprintf('r_images/meanmad_%s.png', filesuffix))
plot (x,y,ylim=c(range(y-ye_ci, y+ye_ci)), pch=19, cex=2, cex.lab=1.8, cex.axis=1.8, cex.main=1.8, cex.sub=1.8, xlab="Condition",ylab="Latency to first movement (ms)", main="Mean latencies with 95% conf. intervals", xaxt="n")
axis(side=1,at=x,labels=xl,tck=-.02, cex.lab=1.8, cex.axis=1.8)
arrows(x,y-ye_ci,x,y+ye_ci, length=0.1, angle=90, code=3, lwd=3, col='black')
dev.off()

#
# Make another graph, this time the density of the raw data.
#
print ('raw distributions')
setEPS()
postscript(sprintf('../paper/figures/data_density_%s.eps', filesuffix),width=8,height=5)

par(mar=c(5,5,3,5))
par(oma=c(0,0,0,0))

lat.raw.xmin <- 200
lat.raw.xmax <- 800
lat.raw.ymin <- 0
lat.raw.ymax <- 0.012
lat.raw.legx <- 365
lat.raw.legy <- 0.012
# ND is blue
df <- density(ndall, n=1024)

plot(df, lwd=3, col=lat.ndallcol, ylim=c(lat.raw.ymin,lat.raw.ymax), xlim=c(lat.raw.xmin,lat.raw.xmax),
     cex.lab=1.8, cex.axis=1.8, cex.main=1.8, cex.sub=1.8,
     main="Latency measurement distributions", xlab="Latency (ms)")
abline(v=lat.nd.mean, lty=2, lwd=2, col=lat.ndallcol)

df1 <- density(sdall, n=1024)
lines(df1, lwd=3, col=lat.sdallcol, xlim=c(lat.raw.xmin:lat.raw.xmax))
abline(v=lat.sd.mean, lty=2, lwd=2, col=lat.sdallcol)

df2 <- density(adall, n=1024)
lines(df2, lwd=3, col=lat.adallcol, xlim=c(lat.raw.xmin:lat.raw.xmax))
abline(v=lat.ad.mean, lty=2, lwd=2, col=lat.adallcol)

#legend (lat.raw.legx, lat.raw.legy, bg="white",
#        c("PDF, ND latencies",
#          sprintf("ND mean latency (%.1f ms)", lat.nd.mean),
#          "PDF, SD latencies",
#          sprintf("SD mean latency (%.1f ms)", lat.sd.mean),
#          "PDF, AD latencies",
#          sprintf("AD mean latency (%.1f ms)", lat.ad.mean)),
#        lty=c(1,2,1,2,1,2),
#        lwd=c(3,2,3,2,3,2),
#        col=c(lat.ndallcol,lat.ndallcol,lat.sdallcol,lat.sdallcol,lat.adallcol,lat.adallcol))
legend (lat.raw.legx, lat.raw.legy, bg="white",
        c(sprintf("No distractor (mean %.1f ms)", lat.nd.mean),
          sprintf("Synchronous (%.1f ms)", lat.sd.mean),
          sprintf("Asynchronous (%.1f ms)", lat.ad.mean)),
        lty=c(1,1,1),
        lwd=c(3,3,3),
        cex=1.4,
        col=c(lat.ndallcol,lat.sdallcol,lat.adallcol))

dev.off()

# Repeat for PNG
png (filename=sprintf('r_images/data_density_%s.png',filesuffix))
plot(df, lwd=3, col=lat.ndallcol, ylim=c(lat.raw.ymin,lat.raw.ymax), xlim=c(lat.raw.xmin,lat.raw.xmax),
     cex.lab=1.8, cex.axis=1.8, cex.main=1.8, cex.sub=1.8,
     main="Latency measurement distributions", xlab="Latency (ms)")
abline(v=lat.nd.mean, lty=2, lwd=2, col=lat.ndallcol)

lines(df1, lwd=3, col=lat.sdallcol, xlim=c(lat.raw.xmin:lat.raw.xmax))
abline(v=lat.sd.mean, lty=2, lwd=2, col=lat.sdallcol)

lines(df2, lwd=3, col=lat.adallcol, xlim=c(lat.raw.xmin:lat.raw.xmax))
abline(v=lat.ad.mean, lty=2, lwd=2, col=lat.adallcol)

legend (lat.raw.legx, lat.raw.legy, bg="white",
        c(sprintf("No Distractor (mean %.1f ms)", lat.nd.mean),
          sprintf("Synchronous (%.1f ms)", lat.sd.mean),
          sprintf("Asynchronous (%.1f ms)", lat.ad.mean)),
        lty=c(1,1,1),
        lwd=c(3,3,3),
        col=c(lat.ndallcol,lat.sdallcol,lat.adallcol))
dev.off()
