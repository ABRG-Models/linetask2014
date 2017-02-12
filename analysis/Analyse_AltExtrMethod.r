###
### Analysis on Mauro's alternative method for latencies.
###

set.seed(1974201701)

## Use functions from this script:
source('Bootstrap_all_twosamples.r')

## Read Mauro's data in
d <- read.csv('Mauro_analysis/Summary_reduced.csv')
f1 <- function (type) {
    ## Get all rows for distractor.type == 0
    dd<-d[which(d$Distractor.type == type), ]
    ## remove Subject and Distractor.type columns]
    dd$Subject <- NULL
    dd$Distractor.type <- NULL
    ## Matrix to vector (don't care which individual is which):
    dd <- unlist(dd)
    ## Remove nd fields:
    dd <- na.omit(dd)
    ## Remove negative fields and convert to ms:
    dd<-dd[dd>0]*1000
}

ND<-f1(0)
SD<-f1(1)
AD<-f1(2)

print (sprintf("ND mean: %f, Std Dev: %f", mean(ND), sd(ND)))
print (sprintf("SD mean: %f, Std Dev: %f", mean(SD), sd(SD)))
print (sprintf("AD mean: %f, Std Dev: %f", mean(AD), sd(AD)))

print("-----------------------------------------")
print("Bootstrap analysis of difference of means")
ndsd <- b.diffste(SD, ND, 1024)
print (sprintf("SD ND difference is %f, standard error estimate: %f", ndsd$meandiff, ndsd$stderr))
ndad <- b.diffste(AD, ND, 1024)
print (sprintf("AD ND difference is %f, standard error estimate: %f", ndad$meandiff, ndad$stderr))
sdad <- b.diffste(AD, SD, 1024)
print (sprintf("AD SD difference is %f, standard error estimate: %f", sdad$meandiff, sdad$stderr))

print("-----------------------------------------")
print ("Studentized bootstrapped hypothesis test (Algo 16.2)")
# ndsd does better than 1e-6 (set B to 1000000)
ndsd_tst <- b.studentized_ttest(SD, ND, 1000)
b.showsiglev (ndsd_tst, "SD vs ND")
ndsd_tst <- b.studentized_ttest(AD, ND, 1000)
b.showsiglev (ndsd_tst, "AD vs ND")
ndsd_tst <- b.studentized_ttest(AD, SD, 1000)
b.showsiglev (ndsd_tst, "AD vs SD")

print("-----------------------------------------")

# Now make a density graph, like Fig 6 in original submission.
print ('raw distributions')

doplot <- function () {

    par(mar=c(5,5,3,5))
    par(oma=c(0,0,0,0))

    lat.NDcol <- "black"
    lat.SDcol <- "steelblue"
    lat.ADcol <- "red"

    lat.raw.xmin <- 200
    lat.raw.xmax <- 800
    lat.raw.ymin <- 0
    lat.raw.ymax <- 0.012
    lat.raw.legx <- 365
    lat.raw.legy <- 0.012
                                        # ND is blue
    df <- density(ND, n=1024)

    plot(df, lwd=3, col=lat.NDcol, ylim=c(lat.raw.ymin,lat.raw.ymax), xlim=c(lat.raw.xmin,lat.raw.xmax),
         cex.lab=1.8, cex.axis=1.8, cex.main=1.8, cex.sub=1.8,
         main="Latency measurement distributions (alt method)", xlab="Latency (ms)")
    abline(v=mean(ND), lty=2, lwd=2, col=lat.NDcol)

    df1 <- density(SD, n=1024)
    lines(df1, lwd=3, col=lat.SDcol, xlim=c(lat.raw.xmin:lat.raw.xmax))
    abline(v=mean(SD), lty=2, lwd=2, col=lat.SDcol)

    df2 <- density(AD, n=1024)
    lines(df2, lwd=3, col=lat.ADcol, xlim=c(lat.raw.xmin:lat.raw.xmax))
    abline(v=mean(AD), lty=2, lwd=2, col=lat.ADcol)

    legend (lat.raw.legx, lat.raw.legy, bg="white",
            c(sprintf("No distractor (mean %.1f ms)", mean(ND)),
              sprintf("Synchronous (%.1f ms)", mean(SD)),
              sprintf("Asynchronous (%.1f ms)", mean(AD))),
            lty=c(1,1,1),
            lwd=c(3,3,3),
            cex=1.4,
            col=c(lat.NDcol,lat.SDcol,lat.ADcol))
}

setEPS()
postscript(sprintf('../paper/figures/data_density_altmethod.eps'),width=8,height=5)
doplot()
dev.off()

png(sprintf('../paper/figures/data_density_altmethod.png'),width=800, height=500, units = "px")
doplot()
dev.off()
