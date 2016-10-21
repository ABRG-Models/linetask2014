
d <- read.csv('AsyncTrials.csv')
alt <- d[which (d$type == 1 & d$latency > 0 & d$correctmove == 1 & d$omit == 0 ),c("latency","direction")]

d <- read.csv('SyncTrials.csv')
slt <- d[which (d$type == 1 & d$latency > 0 & d$correctmove == 1 & d$omit == 0 ),c("latency","direction")]

d <- read.csv('NoDistTrials.csv')
nlt <- d[which (d$type == 1 & d$latency > 0 & d$correctmove == 1 & d$omit == 0 ),c("latency","direction")]

ndall <- nlt[which(abs(nlt$direction) >= 11.9*8.807),]$latency
sdall <- slt[which(abs(slt$direction) >= 11.9*8.807),]$latency
adall <- alt[which(abs(alt$direction) >= 11.9*8.807),]$latency

filesuffix <- 'nonfov'

# To call this, you need to have ndall, sdall and adall in the workspace:
source('Bootstrap_all_main.r')
