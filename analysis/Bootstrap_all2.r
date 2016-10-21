# This should produce the same result as from load(file="all_latencies.rdat"):
d <- read.csv('AsyncTrials.csv')
alt <- d[which (d$type == 1 & d$latency > 0 & d$correctmove == 1 & d$omit == 0 ),c("latency","direction")]

d <- read.csv('SyncTrials.csv')
slt <- d[which (d$type == 1 & d$latency > 0 & d$correctmove == 1 & d$omit == 0 ),c("latency","direction")]

d <- read.csv('NoDistTrials.csv')
nlt <- d[which (d$type == 1 & d$latency > 0 & d$correctmove == 1 & d$omit == 0 ),c("latency","direction")]

ndall <- nlt$latency
sdall <- slt$latency
adall <- alt$latency

filesuffix <- 'all2'

# To call this, you need to have ndall, sdall and adall in the workspace:
source('Bootstrap_all_main.r')
