source('../common.R')
## forensim infinite-loops in tcltk
## BayesXsrc was killed using 31Gb for a compile, rmatio 12.5GB
## mpMap2 uses over 1h CPU time
## RcppSMC used 50GB for an R process.
stoplist <- c(stoplist, 'sanitizers', 'BayesXsrc', 'crs', 'forensim', "rmatio",'mpMap2', 'icamix', 'fdaPDE', 'gllvm', 'glmmTMB', 'RcppSMC', 'mlpack')
## blavaan uses 10GB, ctsem 19GB, rstanarm 8GB
stan <- c(stan0, tools::dependsOnPkgs('StanHeaders',,FALSE))
cgal <- tools::dependsOnPkgs('RcppCGAL', 'LinkingTo', FALSE)
stoplist <- c(stoplist, stan, cgal)
do_it(stoplist, TRUE)
