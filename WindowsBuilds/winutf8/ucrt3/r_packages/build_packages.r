#
# Build binary versions of R packages. This can be run to build all packages
# available in CRAN+BIOC, or all in CRAN with BIOC dependencies, and one
# can also restrict to those needing compilation (see below). Only the selected
# binary packages are included, but outputs from all (attempted) installations.
#
# This can use a local CRAN mirror in a directory (see update_mirror.sh)
#

# --- customize below

#CRAN_mirror <- "https://cran.r-project.org"
#BIOC_mirror <- "https://master.bioconductor.org/packages/3.11"

CRAN_mirror <- paste0("file:///", getwd(), "/mirror/CRAN")
BIOC_mirror <- paste0("file:///", getwd(), "/mirror/BIOC")


onlync <- TRUE # only packages that need compilation will be created
               # (their dependencies will be installed if needed, but
               #  not part of output)

onlycran <- TRUE # only CRAN packages and their BIOC dependencies
                 # the BIOC dependencies will be part of output
Ncpus <- 20

contriburl <- c(paste0(CRAN_mirror, "/src/contrib"),
                paste0(BIOC_mirror, "/bioc/src/contrib"),
                paste0(BIOC_mirror, "/data/annotation/src/contrib"),
                paste0(BIOC_mirror, "/data/experiment/src/contrib"),
                paste0(BIOC_mirror, "/workflows/src/contrib"))

# --- customize above

ap <- available.packages(contriburl)
iscran <- grepl(CRAN_mirror, ap[,"Repository"])
cranpkgs <- ap[iscran, "Package"]

wanted <- rep(TRUE, nrow(ap))   # packages we want
accepted <- rep(TRUE, nrow(ap)) # packages we accept if dependencies
                                #   for those we want
if (onlync) {
  wanted <- wanted & ap[,"NeedsCompilation"]=="yes"
  accepted <- accepted & ap[,"NeedsCompilation"]=="yes"
}

if (onlycran)
  wanted <- wanted & iscran
  # but accept also non-CRAN

wanted_pkgs <- ap[wanted, "Package"]
accepted_pkgs <- ap[accepted, "Package"]

ip <- installed.packages()[,"Package"]
toinst <- wanted_pkgs[ !(wanted_pkgs %in% ip) ]

# install packages, building them, with dependencies

mkdir <- function(d)
  if (!dir.exists(d))
    dir.create(d, recursive = TRUE)

mkdir("pkgbuild/lib")
owd <- setwd("pkgbuild")

install.packages(pkgs=toinst, contriburl=contriburl, Ncpus=Ncpus, 
  keep_outputs=TRUE, type="source", lib="lib", available=ap,
  INSTALL_opts="--build")

# copy out the results, split by repository

setwd(owd)

cran_bin <- "build/CRAN/bin/windows/contrib/4.1"
bioc_bin <- "build/BIOC/bin/windows/contrib/4.1"

mkdir(cran_bin)
mkdir("build/CRAN/install_out")
mkdir(bioc_bin)
mkdir("build/BIOC/install_out")

  # generated zip files

bfiles <- list.files("pkgbuild", pattern="\\.zip$")
bpkgs <- gsub("_.*\\.zip$", "", bfiles)

tocran <- bfiles[ (bpkgs %in% accepted_pkgs) & (bpkgs %in% cranpkgs) ]
if (length(tocran))
  dummy <- file.copy(paste0("pkgbuild/", tocran), cran_bin)

tobioc <- bfiles[ (bpkgs %in% accepted_pkgs) & !(bpkgs %in% cranpkgs) ]
if (length(tobioc))
  dummy <- file.copy(paste0("pkgbuild/", tobioc), bioc_bin)

  # output files from the build

ofiles <- list.files("pkgbuild", pattern="\\.out$")
opkgs <- gsub("\\.out$", "", ofiles)

tocran <- ofiles[ opkgs %in% cranpkgs ]
if (length(tocran))
  dummy <- file.copy(paste0("pkgbuild/", tocran), "build/CRAN/install_out")

tobioc <- ofiles[ !(opkgs %in% cranpkgs) ]
if (length(tobioc))
  dummy <- file.copy(paste0("pkgbuild/", tobioc), "build/BIOC/install_out")

# create package indices

tools::write_PACKAGES(cran_bin, type="win.binary")
tools::write_PACKAGES(bioc_bin, type="win.binary")

cran_src <- "build/CRAN/src/contrib"
bioc_src <- "build/BIOC/src/contrib"

  # R complains if there is no index for source packages

mkdir(cran_src)
mkdir(bioc_src)
file.create(paste0(cran_src, "/PACKAGES"))
file.create(paste0(bioc_src, "/PACKAGES"))

