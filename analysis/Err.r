options(contrasts=c("contr.treatment","contr.treatment"))
require(nlme)

load(file="all_latencies.rdat")
load(file="ye_ci_all.rdat")

# Use the means a lot so compute 'em
lat.nd.mean = mean(ndall)
lat.sd.mean = mean(sdall)
lat.ad.mean = mean(adall)

set.seed(197420164)

errdat <- read.csv('error_rates.csv')

nderr <- errdat[errdat$condition_str == "ND",]$error_rate
sderr <- errdat[errdat$condition_str == "SD",]$error_rate
aderr <- errdat[errdat$condition_str == "AD",]$error_rate
errd.nd.mean <- mean(nderr)
errd.sd.mean <- mean(sderr)
errd.ad.mean <- mean(aderr)

errd.fontsize <- 1.8

print ('ND mean, mad then sd')
print (errd.nd.mean)
print (mad(nderr))
print (sd(nderr))

print ('SD mean, mad then sd')
print (errd.sd.mean)
print (mad(sderr))
print (sd(sderr))

print ('AD mean, mad then sd')
print (mean(aderr))
print (mad(aderr))
print (sd(aderr))

# Put the numbers above into a latex table:
print ("Lines for the simple error rate table:")
line_nd <- sprintf ("No Distractor & %.3f & %.3f & %.3f \\", errd.nd.mean, sd(nderr), mad(nderr))
line_sd <- sprintf ("Synchronous Distractor & %.3f & %.3f & %.3f \\", errd.sd.mean, sd(sderr), mad(sderr))
line_ad <- sprintf ("Asynchronous Distractor & %.3f & %.3f & %.3f \\ [1ex]", errd.ad.mean, sd(aderr), mad(aderr))

print (line_nd)
print (line_sd)
print (line_ad)

# Wilcoxon test between ND and SD
# individual latencies
# paired=TRUE indicates signed rank test
print(wilcox.test(nderr, sderr, paired=TRUE))

require(effsize)
print(cliff.delta(nderr, sderr))

# Estimate std. err. of the mean
nd.se = sqrt(var(nderr)/length(nderr))
sd.se = sqrt(var(sderr)/length(sderr))
print (sprintf("ND Error rate theoretical estimate: %.3f, se=%.3f, SD Error rate: %.3f, se=%.3f\n", errd.nd.mean, nd.se, errd.sd.mean, sd.se))

lat.n <- length(ndall)
print(paste("number of bootstrap resamples:",lat.n))
print(paste("number of ND samples:",length(ndall)))
print(paste("number of SD samples:",length(sdall)))
print(paste("number of AD samples:",length(adall)))

# Plot will show that 87% of the possible means that I could have
# measured for SD and ADALL were different with
errd.highconf <- 0.95
errd.lowconf <- 1-errd.highconf
errd.95conf <- 0.95
errd.05conf <- 1-errd.95conf

# Colour scheme
errd.ndallcol <- "black"
errd.sdallcol <- "steelblue"
errd.adallcol <- "red"

errd.ymin <- 0
errd.ymax <- 0.44
errd.xmin <- 0.01
errd.xmax <- 0.25
errd.legx <- 0.04
errd.legy <- 101


# Bootstrap for a nice distribution graph

# function which will bootstrap the standard error of the mean
b.mean <- function(data, num) {
    resamples <- lapply(1:num, function(i) sample(data, replace=T))
    r.mean <- sapply(resamples, mean)
    std.err <- sqrt(var(r.mean))
    ci95abs <- quantile (r.mean, errd.95conf)
    ci95 <- abs(ci95abs-mean(data))
    list(std.err=std.err, resamples=resamples, means=r.mean, ci95=ci95)
}

bmean.nd <- b.mean(nderr, 100)
print (paste("Std. error of the mean estimate for ND errors:",bmean.nd$std.err))
bmean.sd <- b.mean(sderr, 100)
print (paste("Std. error of the mean estimate for SD errors:",bmean.sd$std.err))
bmean.ad <- b.mean(aderr, 100)

#
# Plot the distribution of the possible means from the bootstrapping
#
setEPS()
postscript(file='../paper/figures/bootstrap_errors.eps',width=8,height=5)

edf <- density(bmean.nd$means, n=128)

par(mar=c(5,5,3,5)) # may need to change depending on errd.fontsize
par(oma=c(0,0,0,0))
plot(edf, lwd=3, col=errd.ndallcol, xlim=c(errd.xmin,errd.xmax),
     cex.lab=errd.fontsize, cex.axis=errd.fontsize, cex.main=errd.fontsize-0.2, cex.sub=errd.fontsize, mgp = c(3.5, 1.5, 0),
     main="Distributions of bootstrapped error rate means", xlab="Error rate")
abline(v=errd.nd.mean, lty=2, lwd=2, col=errd.ndallcol)
ndq05 <- quantile(bmean.nd$means,errd.05conf)
abline(v=ndq05[1], lty=6, lwd=2, col=errd.ndallcol)
ndq95 <- quantile(bmean.nd$means,errd.95conf)
abline(v=ndq95[1], lty=6, lwd=2, col=errd.ndallcol)

edf2 <- density(bmean.sd$means, n=128)
lines(edf2, lwd=3, col=errd.sdallcol, xlim=c(errd.xmin,errd.xmax))
abline(v=errd.sd.mean, lty=2, lwd=2, col=errd.sdallcol)
sdq05 <- quantile(bmean.sd$means,errd.05conf)
abline(v=sdq05[1], lty=6, lwd=2, col=errd.sdallcol)
sdq95 <- quantile(bmean.sd$means,errd.95conf)
abline(v=sdq95[1], lty=6, lwd=2, col=errd.sdallcol)

edf3 <- density(bmean.ad$means, n=128)
lines(edf3, lwd=3, col=errd.adallcol, xlim=c(errd.xmin,errd.xmax))
abline(v=errd.ad.mean, lty=2, lwd=2, col=errd.adallcol)
adq05 <- quantile(bmean.ad$means,errd.05conf)
abline(v=adq05[1], lty=6, lwd=2, col=errd.adallcol)
adq95 <- quantile(bmean.ad$means,errd.95conf)
abline(v=adq95[1], lty=6, lwd=2, col=errd.adallcol)

legend (errd.legx, errd.legy, bg="white",
        c("ND","SD","AD"),
        lty=c(1,1,1),
        lwd=c(3,3,3),
        cex=1.5,
        col=c(errd.ndallcol,errd.sdallcol,errd.adallcol))

dev.off()

# Repeat plot for PNG
png (filename='r_images/bootstrap_errors.png', width=640, height=480, units="px")
#        (b,l,t,r)
par(mar=c(5,5,3,5)) # may need to change depending on errd.fontsize
par(oma=c(0,0.5,0,0.5) )
plot(edf, lwd=3, col=errd.ndallcol, xlim=c(errd.xmin,errd.xmax),
     cex.lab=errd.fontsize, cex.axis=errd.fontsize, cex.main=errd.fontsize-0.2, cex.sub=errd.fontsize,
     main="Distributions of bootstrapped error rate means", xlab="Error rate")
abline(v=errd.nd.mean, lty=2, lwd=2, col=errd.ndallcol)
abline(v=ndq05[1], lty=6, lwd=2, col=errd.ndallcol)
abline(v=ndq95[1], lty=6, lwd=2, col=errd.ndallcol)

lines(edf2, lwd=3, col=errd.sdallcol, xlim=c(errd.xmin,errd.xmax))
abline(v=errd.sd.mean, lty=2, lwd=2, col=errd.sdallcol)
abline(v=sdq05[1], lty=6, lwd=2, col=errd.sdallcol)
abline(v=sdq95[1], lty=6, lwd=2, col=errd.sdallcol)

lines(edf3, lwd=3, col=errd.adallcol, xlim=c(errd.xmin,errd.xmax))
abline(v=errd.ad.mean, lty=2, lwd=2, col=errd.adallcol)
abline(v=adq05[1], lty=6, lwd=2, col=errd.adallcol)
abline(v=adq95[1], lty=6, lwd=2, col=errd.adallcol)

legend (errd.legx, errd.legy, bg="white",
        c("ND","SD","AD"),
        lty=c(1,1,1),
        lwd=c(3,3,3),
        cex=1.5,
        col=c(errd.ndallcol,errd.sdallcol,errd.adallcol))

dev.off()

#
# End plotting
#

#
# The per-group error rates
#

# fasterSync group
nderr_fs <- errdat[errdat$condition_str == "ND" &  errdat$subj_id %in% fssNames,]$error_rate # and subj_id in fssNames
sderr_fs <- errdat[errdat$condition_str == "SD" &  errdat$subj_id %in% fssNames,]$error_rate
aderr_fs <- errdat[errdat$condition_str == "AD" &  errdat$subj_id %in% fssNames,]$error_rate
# Means
errd.ndfs.mean <- mean(nderr_fs)
errd.sdfs.mean <- mean(sderr_fs)
errd.adfs.mean <- mean(aderr_fs)
bmean.ndfs <- b.mean(nderr_fs, 100)
bmean.sdfs <- b.mean(sderr_fs, 100)
bmean.adfs <- b.mean(aderr_fs, 100)

# faster Async group
nderr_fa <- errdat[errdat$condition_str == "ND" &  errdat$subj_id %in% fasNames,]$error_rate # and subj_id in fasNames
sderr_fa <- errdat[errdat$condition_str == "SD" &  errdat$subj_id %in% fasNames,]$error_rate
aderr_fa <- errdat[errdat$condition_str == "AD" &  errdat$subj_id %in% fasNames,]$error_rate
errd.ndfa.mean <- mean(nderr_fa)
errd.sdfa.mean <- mean(sderr_fa)
errd.adfa.mean <- mean(aderr_fa)
bmean.ndfa <- b.mean(nderr_fa, 100)
bmean.sdfa <- b.mean(sderr_fa, 100)
bmean.adfa <- b.mean(aderr_fa, 100)

# No diff group
nderr_nd <- errdat[errdat$condition_str == "ND" &  errdat$subj_id %in% ndNames,]$error_rate # and subj_id in ndNames
sderr_nd <- errdat[errdat$condition_str == "SD" &  errdat$subj_id %in% ndNames,]$error_rate
aderr_nd <- errdat[errdat$condition_str == "AD" &  errdat$subj_id %in% ndNames,]$error_rate
errd.ndnd.mean <- mean(nderr_nd)
errd.sdnd.mean <- mean(sderr_nd)
errd.adnd.mean <- mean(aderr_nd)
bmean.ndnd <- b.mean(nderr_nd, 100)
bmean.sdnd <- b.mean(sderr_nd, 100)
bmean.adnd <- b.mean(aderr_nd, 100)



#
# The per-group latencies
#

# First read in the data from the IndDat*.csv files:
fns <- list.files(pattern="IndDat*")
latdatall <- c()
for (indiv in fns) {
    latdat <- read.csv(indiv)
    s <- sub ("IndDat", "", indiv)
    s <- sub (".csv", "", s)
    latdat$subj_id <- s
    # Need to add subj_id to this:
    latdatall <- rbind (latdatall, latdat)
}

# fasterSync group
ndlat_fs <- latdatall[latdatall$condition_str == "ND" &  latdatall$subj_id %in% fssNames,]$latency
sdlat_fs <- latdatall[latdatall$condition_str == "SD" &  latdatall$subj_id %in% fssNames,]$latency
adlat_fs <- latdatall[latdatall$condition_str == "AD" &  latdatall$subj_id %in% fssNames,]$latency
# Means
latd.ndfs.mean <- mean(ndlat_fs)
latd.sdfs.mean <- mean(sdlat_fs)
latd.adfs.mean <- mean(adlat_fs)
bmean.latndfs <- b.mean(ndlat_fs, 100)
bmean.latsdfs <- b.mean(sdlat_fs, 100)
bmean.latadfs <- b.mean(adlat_fs, 100)

# faster Async group
ndlat_fa <- latdatall[latdatall$condition_str == "ND" &  latdatall$subj_id %in% fasNames,]$latency
sdlat_fa <- latdatall[latdatall$condition_str == "SD" &  latdatall$subj_id %in% fasNames,]$latency
adlat_fa <- latdatall[latdatall$condition_str == "AD" &  latdatall$subj_id %in% fasNames,]$latency
latd.ndfa.mean <- mean(ndlat_fa)
latd.sdfa.mean <- mean(sdlat_fa)
latd.adfa.mean <- mean(adlat_fa)
bmean.latndfa <- b.mean(ndlat_fa, 100)
bmean.latsdfa <- b.mean(sdlat_fa, 100)
bmean.latadfa <- b.mean(adlat_fa, 100)

# No diff group
ndlat_nd <- latdatall[latdatall$condition_str == "ND" &  latdatall$subj_id %in% ndNames,]$latency
sdlat_nd <- latdatall[latdatall$condition_str == "SD" &  latdatall$subj_id %in% ndNames,]$latency
adlat_nd <- latdatall[latdatall$condition_str == "AD" &  latdatall$subj_id %in% ndNames,]$latency
latd.ndnd.mean <- mean(ndlat_nd)
latd.sdnd.mean <- mean(sdlat_nd)
latd.adnd.mean <- mean(adlat_nd)
bmean.latndnd <- b.mean(ndlat_nd, 100)
bmean.latsdnd <- b.mean(sdlat_nd, 100)
bmean.latadnd <- b.mean(adlat_nd, 100)


#
# Can now build up the latex output for tables in the paper (actually, not used, this one):
#

line_grp <- sprintf ("\textbf{\\emph{Entire group (N=55)}} & \\emph{ %.3f (%.3f)} & \\emph{%.3f (%.3f)} &  \\emph{%.3f (%.3f)} \\",
                     errd.sd.mean, bmean.sd$ci95, errd.nd.mean, bmean.nd$ci95, errd.ad.mean, bmean.ad$ci95)

# The numbers in this line (lat.sd.mean etc) are computed in Bootstrap_all.r:
if (exists("lat.sd.mean") == FALSE) {
    stop ("Make sure to run Bootstrap_all.r before Err.r (and Bootstrap_indiv.r before both)")
}
line_latgrp <- sprintf ("\textbf{\\emph{Entire group (N=55)}} & \\emph{ %.1f ms (%.1f)} & \\emph{%.1f ms (%.1f)} &  \\emph{%.1f ms (%.1f)} \\",
                     lat.sd.mean, ye_ci[1], lat.nd.mean, ye_ci[2], lat.ad.mean, ye_ci[3])

line_fs  <- sprintf ("\textbf{Faster Synchronous (N=%d)}  &        %.3f (%.3f)  &       %.3f (%.3f)  &        %.3f (%.3f)  \\",
                     length(fssNames), errd.sdfs.mean, bmean.sdfs$ci95, errd.ndfs.mean, bmean.ndfs$ci95, errd.adfs.mean, bmean.adfs$ci95)

line_latfs <- sprintf ("\textbf{Faster Synchronous (N=%d)}  &        %.1f ms (%.1f) &       %.1f ms (%.1f) &        %.1f ms (%.1f) \\",
                       length(fssNames), latd.sdfs.mean, bmean.latsdfs$ci95, latd.ndfs.mean, bmean.latndfs$ci95, latd.adfs.mean, bmean.latadfs$ci95)

line_nd  <- sprintf ("\textbf{No Difference (N=%d)}       &        %.3f (%.3f)  &       %.3f (%.3f)  &        %.3f (%.3f)  \\",
                     length(ndNames), errd.sdnd.mean, bmean.sdnd$ci95, errd.ndnd.mean, bmean.ndnd$ci95, errd.adnd.mean, bmean.adnd$ci95)

line_latnd <- sprintf ("\textbf{No Difference (N=%d)}       &        %.1f ms (%.1f) &       %.1f ms (%.1f) &        %.1f ms (%.1f) \\",
                     length(ndNames), latd.sdnd.mean, bmean.latsdnd$ci95, latd.ndnd.mean, bmean.latndnd$ci95, latd.adnd.mean, bmean.latadnd$ci95)

line_fa  <- sprintf ("\textbf{Faster Asynchronous (N=%d)} &        %.3f (%.3f)  &       %.3f (%.3f)  &        %.3f (%.3f)  \\ [1ex]",
                     length(fasNames), errd.sdfa.mean, bmean.sdfa$ci95, errd.ndfa.mean, bmean.ndfa$ci95, errd.adfa.mean, bmean.adfa$ci95)

line_latfa <- sprintf ("\textbf{Faster Asynchronous (N=%d)} &        %.1f ms (%.1f) &       %.1f ms (%.1f) &        %.1f ms (%.1f) \\ [1ex]",
                     length(fasNames), latd.sdfa.mean, bmean.latsdfa$ci95, latd.ndfa.mean, bmean.latndfa$ci95, latd.adfa.mean, bmean.latadfa$ci95)

print ("Lines for the error rate table:")
print (line_grp)
print (line_fs)
print (line_nd)
print (line_fa)

line_latgrp <- sprintf ("\textbf{\\emph{Entire group (N=55)}} & \\emph{ %.1f ms (%.1f)} & \\emph{%.1f ms (%.1f)} &  \\emph{%.1f ms (%.1f)} \\",
                     lat.sd.mean, ye_ci[1], lat.nd.mean, ye_ci[2], lat.ad.mean, ye_ci[3])

print ("Lines for the latency table:")
print (line_latgrp)
print (line_latfs)
print (line_latnd)
print (line_latfa)
