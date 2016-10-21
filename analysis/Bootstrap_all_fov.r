
d <- read.csv('AsyncTrials.csv')
alt <- d[which (d$type == 1 & d$latency > 0 & d$correctmove == 1 & d$omit == 0 ),c("latency","direction")]

d <- read.csv('SyncTrials.csv')
slt <- d[which (d$type == 1 & d$latency > 0 & d$correctmove == 1 & d$omit == 0 ),c("latency","direction")]

d <- read.csv('NoDistTrials.csv')
nlt <- d[which (d$type == 1 & d$latency > 0 & d$correctmove == 1 & d$omit == 0 ),c("latency","direction")]

# Select the region which is inside the approximage foveal region,
# which is roughly +/- 1.7 degrees (At which point rods and cones
# cross in density and cone density is about 1/2e of maximum). Assuming
# 400 mm from tablet to the subject's eyes, that's about +/- 11.9 mm
# (400 tan 1.7) or (because it's 8.8 pix/mm on screen) 104 px
ndall <- nlt[which(abs(nlt$direction) < 11.9*8.807),]$latency
sdall <- slt[which(abs(slt$direction) < 11.9*8.807),]$latency
adall <- alt[which(abs(alt$direction) < 11.9*8.807),]$latency

filesuffix <- 'fov'

# To call this, you need to have ndall, sdall and adall in the workspace:
source('Bootstrap_all_main.r')
