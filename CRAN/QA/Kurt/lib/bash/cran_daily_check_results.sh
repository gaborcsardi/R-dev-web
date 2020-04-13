check_dir="${HOME}/tmp/R.check"

## <FIXME>
## Adjust when 3.2.2 is released.
## Used for the manuals ... adjust as needed.
##   flavors="prerel patched release"
##   flavors="patched release"
flavors="patched"
## </FIXME>
## <NOTE>
## This needed 
##   flavors="patched"
## prior to the 3.0.2 release.
## </NOTE>

## <NOTE>
## Keeps this in sync with
##   lib/bash/check_R_cp_logs.sh
##   lib/R/Scripts/check.R
## as well as
##   CRAN-package-list
## (or create a common data base eventually ...)
## </NOTE>

## Rsync daily check results for the various "flavors" using KH's
## check-R/check-R-ng layout.

## r-devel-linux-x86_64-debian-clang
sh ${HOME}/lib/bash/rsync_daily_check_flavor.sh \
  gimli.wu.ac.at::R.check/r-devel-clang/ \
  ${check_dir}/r-devel-linux-x86_64-debian-clang/

## r-devel-linux-x86_64-debian-gcc
sh ${HOME}/lib/bash/rsync_daily_check_flavor.sh \
  gimli2.wu.ac.at::R.check/r-devel-gcc/ \
  ${check_dir}/r-devel-linux-x86_64-debian-gcc/

## r-prerel-linux-x86_64
sh ${HOME}/lib/bash/rsync_daily_check_flavor.sh \
  gimli.wu.ac.at::R.check/r-patched-gcc/ \
  ${check_dir}/r-patched-linux-x86_64/

## r-release-linux-x86_64
sh ${HOME}/lib/bash/rsync_daily_check_flavor.sh \
  gimli.wu.ac.at::R.check/r-release-gcc/ \
  ${check_dir}/r-release-linux-x86_64/

## r-release-linux-ix86
## sh ${HOME}/lib/bash/rsync_daily_check_flavor.sh \
##   xmgyges.wu.ac.at::R.check/r-release-gcc/ \
##   ${check_dir}/r-release-linux-ix86/

## Hand-crafted procedures for getting the results for other layouts.

## r-devel-linux-x86_64-fedora-clang
mkdir -p "${check_dir}/r-devel-linux-x86_64-fedora-clang"
(cd "${check_dir}/r-devel-linux-x86_64-fedora-clang";
  rsync -q --times \
    --password-file="${HOME}/lib/bash/rsync_password_file_gannet.txt" \
    r-proj@gannet.stats.ox.ac.uk::Rlogs/clang-times.tab .;
  rsync -q --times \
    --password-file="${HOME}/lib/bash/rsync_password_file_gannet.txt" \
    r-proj@gannet.stats.ox.ac.uk::Rlogs/clang.tar.xz .;
  test clang.tar.xz -nt PKGS && \
    rm -rf PKGS && mkdir PKGS && cd PKGS && tar xf ../clang.tar.xz)

## r-devel-linux-x86_64-fedora-gcc
mkdir -p "${check_dir}/r-devel-linux-x86_64-fedora-gcc"
(cd "${check_dir}/r-devel-linux-x86_64-fedora-gcc";
  rsync -q --times \
    --password-file="${HOME}/lib/bash/rsync_password_file_gannet.txt" \
    r-proj@gannet.stats.ox.ac.uk::Rlogs/gcc-times.tab .;
  rsync -q --times \
    --password-file="${HOME}/lib/bash/rsync_password_file_gannet.txt" \
    r-proj@gannet.stats.ox.ac.uk::Rlogs/gcc.tar.xz .;
  test gcc.tar.xz -nt PKGS && \
    rm -rf PKGS && mkdir PKGS && cd PKGS && tar xf ../gcc.tar.xz)

## Discontinued as of 2017-04.
## ## r-devel-macos-x86_64-clang
## mkdir -p "${check_dir}/r-devel-macos-x86_64-clang"
## (cd "${check_dir}/r-devel-macos-x86_64-clang";
##   rsync -q --times \
##     --password-file="${HOME}/lib/bash/rsync_password_file_gannet.txt" \
##     r-proj@gannet.stats.ox.ac.uk::Rlogs/mavericks-times.tab .;
##   rsync -q --times \
##     --password-file="${HOME}/lib/bash/rsync_password_file_gannet.txt" \
##     r-proj@gannet.stats.ox.ac.uk::Rlogs/mavericks.tar.bz2 .;
##   test mavericks.tar.bz2 -nt PKGS && \
##     rm -rf PKGS && mkdir PKGS && cd PKGS && tar jxf ../mavericks.tar.bz2)

## r-devel-osx-x86_64-gcc
## mkdir -p "${check_dir}/r-devel-osx-x86_64-gcc/PKGS"
## rsync --recursive --delete --times \
##   --include="/*.Rcheck" \
##   --include="/*.Rcheck/00[a-z]*" \
##   --include="/*VERSION" \
##   --include="/00_*" \
##   --exclude="*" \
##   rsync://build.rsync.urbanek.info:8081/build-all/snowleopard-x86_64/results/3.2/ \
##   ${check_dir}/r-devel-osx-x86_64-gcc/PKGS/

## r-devel-windows-ix86+x86_64
mkdir -p "${check_dir}/r-devel-windows-ix86+x86_64/PKGS"
rsync --recursive --delete --times \
  129.217.206.10::CRAN-bin-windows-check/4.0/ \
  ${check_dir}/r-devel-windows-ix86+x86_64/PKGS

## r-devel-windows-ix86+x86_64-gcc8
mkdir -p "${check_dir}/r-devel-windows-ix86+x86_64-gcc8/PKGS"
rsync --recursive --delete --times \
  129.217.206.10::CRAN-bin-windows-check/4.0gcc8/ \
  ${check_dir}/r-devel-windows-ix86+x86_64-gcc8/PKGS

## Discontinued as of 2017-07.
## ## r-patched-solaris-sparc
## mkdir -p "${check_dir}/r-patched-solaris-sparc/PKGS"
## (cd "${check_dir}/r-patched-solaris-sparc";
##   rsync -q --times \
##     --password-file="${HOME}/lib/bash/rsync_password_file_gannet.txt" \
##     r-proj@gannet.stats.ox.ac.uk::Rlogs/Sparc-times.tab .;
##   rsync -q --times \
##     --password-file="${HOME}/lib/bash/rsync_password_file_gannet.txt" \
##     r-proj@gannet.stats.ox.ac.uk::Rlogs/Sparc.tar.bz2 .;
##   test Sparc.tar.bz2 -nt PKGS && \
##     rm -rf PKGS && mkdir PKGS && cd PKGS && tar jxf ../Sparc.tar.bz2)

## r-patched-solaris-x86
mkdir -p "${check_dir}/r-patched-solaris-x86/PKGS"
(cd "${check_dir}/r-patched-solaris-x86";
  rsync -q --times \
    --password-file="${HOME}/lib/bash/rsync_password_file_gannet.txt" \
    r-proj@gannet.stats.ox.ac.uk::Rlogs/Solx86-times.tab .;
  rsync -q --times \
    --password-file="${HOME}/lib/bash/rsync_password_file_gannet.txt" \
    r-proj@gannet.stats.ox.ac.uk::Rlogs/Solx86.tar.xz .;
  test Solx86.tar.xz -nt PKGS && \
    rm -rf PKGS && mkdir PKGS && cd PKGS && tar xf ../Solx86.tar.xz)

## r-patched-osx-x86_64
mkdir -p "${check_dir}/r-patched-osx-x86_64/PKGS"
rsync --recursive --delete --times \
  --include="/*.Rcheck" \
  --include="/*.Rcheck/00[a-z]*" \
  --include="/*VERSION" \
  --include="/00_*" \
  --exclude="*" \
  cran@nz.build.rsync.urbanek.info:/data/results/high-sierra/4.0/ \
  ${check_dir}/r-patched-osx-x86_64/PKGS/

## r-release-windows-ix86+x86_64
mkdir -p "${check_dir}/r-release-windows-ix86+x86_64/PKGS"
rsync --recursive --delete --times \
  129.217.206.10::CRAN-bin-windows-check/3.6/ \
  ${check_dir}/r-release-windows-ix86+x86_64/PKGS

## r-release-osx-x86_64
mkdir -p "${check_dir}/r-release-osx-x86_64/PKGS"
rsync --recursive --delete --times \
  --include="/*.Rcheck" \
  --include="/*.Rcheck/00[a-z]*" \
  --include="/*VERSION" \
  --include="/00_*" \
  --exclude="*" \
  cran@build.rsync.urbanek.info:/R/build/el-capitan-x86_64/results/3.6/ \
  ${check_dir}/r-release-osx-x86_64/PKGS/

## r-oldrel-windows-ix86+x86_64
mkdir -p "${check_dir}/r-oldrel-windows-ix86+x86_64/PKGS"
rsync --recursive --delete --times \
  129.217.206.10::CRAN-bin-windows-check/3.5/ \
  ${check_dir}/r-oldrel-windows-ix86+x86_64/PKGS

## r-oldrel-osx-x86_64
mkdir -p "${check_dir}/r-oldrel-osx-x86_64/PKGS"
rsync --recursive --delete --times \
  --include="/*.Rcheck" \
  --include="/*.Rcheck/00[a-z]*" \
  --include="/*VERSION" \
  --include="/00_*" \
  --exclude="*" \
  cran@build.rsync.urbanek.info:/R/build/el-capitan-x86_64/results/3.5/ \
  ${check_dir}/r-oldrel-osx-x86_64/PKGS/

## Discontinued 2018-03.
## ## r-oldrel-osx-x86_64-mavericks
## mkdir -p "${check_dir}/r-oldrel-osx-x86_64/PKGS"
## rsync --recursive --delete --times \
##   --include="/*.Rcheck" \
##   --include="/*.Rcheck/00[a-z]*" \
##   --include="/*VERSION" \
##   --include="/00_*" \
##   --exclude="*" \
##   cran@build.rsync.urbanek.info:/R/build/mavericks-x86_64/results/3.3/ \
##   ${check_dir}/r-oldrel-osx-x86_64/PKGS/
## ## Old style:
## ##   rsync://build.rsync.urbanek.info:8081/build-all/mavericks-x86_64/results/3.3/

## BDR memtests
## mkdir -p "${check_dir}/bdr-memtests"
## rsync -q --recursive --delete --times \
##   --password-file="${HOME}/lib/bash/rsync_password_file_gannet.txt" \
##   r-proj@gannet.stats.ox.ac.uk::Rlogs/memtests/ \
##   ${check_dir}/bdr-memtests

## Issues
mkdir -p "${check_dir}/issues/"
rsync -q --recursive --delete --times \
  --password-file="${HOME}/lib/bash/rsync_password_file_gannet.txt" \
  r-proj@gannet.stats.ox.ac.uk::Rlogs/memtests/*.csv \
  ${check_dir}/issues
rsync -q --recursive --delete --times \
  --password-file="${HOME}/lib/bash/rsync_password_file_gannet.txt" \
  r-proj@gannet.stats.ox.ac.uk::Rlogs/noLD/*.csv \
  ${check_dir}/issues
rsync -q --recursive --delete --times \
  --password-file="${HOME}/lib/bash/rsync_password_file_gannet.txt" \
  r-proj@gannet.stats.ox.ac.uk::Rlogs/LTO.csv \
  ${check_dir}/issues

wget -q \
  https://raw.githubusercontent.com/kalibera/cran-checks/master/rchk/rchk.csv \
  -O ${check_dir}/issues/rchk.csv
wget -q \
  https://raw.githubusercontent.com/kalibera/cran-checks/master/rcnst/rcnst.csv \
  -O ${check_dir}/issues/rcnst.csv

## Dbs.

mkdir -p "${check_dir}/dbs"
rsync -q --recursive --delete --times \
  gimli2.wu.ac.at::R.check/*.rds \
  ${check_dir}/dbs  

## Summaries and logs.

LANG=en_US.UTF-8 LC_COLLATE=en_US.UTF-8 \
  sh ${HOME}/lib/bash/check_R_summary.sh

LANG=en_US.UTF-8 LC_COLLATE=en_US.UTF-8 \
  sh ${HOME}/lib/bash/check_R_cp_logs.sh

## Manuals.
manuals_dir=/srv/ftp/pub/R/doc/manuals
for flavor in devel ${flavors} ; do
    rm -rf ${manuals_dir}/r-${flavor}
done    
cp -pr ${check_dir}/r-devel-linux-x86_64-debian-gcc/Manuals \
    ${manuals_dir}/r-devel
for flavor in ${flavors} ; do
  cp -pr ${check_dir}/r-${flavor}-linux-x86_64/Manuals \
    ${manuals_dir}/r-${flavor}
done  

### Local Variables: ***
### mode: sh ***
### sh-basic-offset: 2 ***
### End: ***
