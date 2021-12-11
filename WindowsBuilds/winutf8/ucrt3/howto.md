---
title: "Howto: UTF-8 as native encoding in R on Windows with UCRT"
author: Tomas Kalibera
output: html_document
---

For UTF-8 as native encoding on Windows, we need a new compiler toolchain
using UCRT as C runtime ("C library" would be a Unix term) and we have to
rebuild all native code with it: R, packages with native code and libraries
used by those.  Some of that code needs patching (for UCRT, for newer
toolchain, newer libraries, etc).

We also need to adapt our code to work with multi-byte encodings where it
may previously have expected single-byte or double-byte encodings.  Sooner
we find about these problems and fix them, sooner we can enjoy UTF-8 in R on
Windows.

Regular CRAN checks have been run using the experimental toolchain described
here since March 2021 and CRAN/R-devel will switch to this toolchain on
December 13, see
[Upcoming Changes in R 4.2 on Windows](https://developer.r-project.org/Blog/public/2021/12/07/upcoming-changes-in-r-4.2-on-windows/index.html)
for more information about the transition.

This document describes how to obtain a build of R for Windows with UTF-8
as the current native encoding, how to install packages, how to update
packages to work with the toolchain, and additional advanced issues.

## Installing R build using installer, binary packages

One needs recent Windows 10 (May 2019 Update or newer, which one should
normally get simply by updating via Microsoft Update) or Windows Server 2022
for UTF-8 as the native encoding.  Still, one may test the build and
the toolchain on older versions of Windows where a different native encoding
will be used (encoding support there would be the same as in current MSVCRT builds of
R).

Windows Server 2016 and all versions of Windows 10 already ship with UCRT.
On earlier versions (from Windows Vista SP2, Sever 2008 SP1) UCRT can be
[installed](https://support.microsoft.com/en-us/topic/update-for-universal-c-runtime-in-windows-c0514201-7fe6-95a3-b0a5-287930f3560c)
manually.

Before installing this build of R, please remove any existing installation
of R-devel and the package library of R-devel, because the packages are
incompatible.  If you want to go back to the standard MSVCRT build of
R-devel, please again remove the library, first.

The binary installer of R is available
[here](https://www.r-project.org/nosvn/winutf8/ucrt3/) in a file named such
as `R-devel-win-79604-4354-4361.exe` (the numbers differ, they encode the
current version). Only 64-bit version is available and no 32-bit version is
planned.

To check UTF-8 is used as native encoding, run

```
> l10n_info()
$MBCS
[1] TRUE

$`UTF-8`
[1] TRUE

$`Latin-1`
[1] FALSE

$codepage
[1] 65001

$system.codepage
[1] 65001
```

Both "codepage" and "system.codepage" must be 65001 (UTF-8). When running RTerm (so
also R.exe) from the command line, make sure to set up this code page and
select a font with a wide set of glyphs. In cmd.exe, use `chcp 65001` and
select e.g. `NSimFun` before running R.

This build of R is patched to install binary packages built with UCRT (those
that need compilation), but the other binary packages are currently taken
from the CRAN package builds done using the MSVCRT build of R.

Some of these CRAN packages are patched at installation time to build/work
with UCRT and this toolchain (more below).  Bioconductor packages needed by
CRAN packages are also available in binary form and some of them with
installation-time patches. This is a temporary measure to give package
authors more time to fix their packages.

For example, try installing `PKI`:

```
install.packages("PKI", type="source")
```

will install a binary build of the PKI package, which has been patched to
work with this toolchain.

## Installation of external software for building from source

One needs MikTeX (with basic packages and `inconsolata`) to build package
vignettes and documentation.  Inno Setup is (only) needed for building R
installer, not R packages.  This is the same for the current version of R
and previous installations can be used.

In addition, one needs the compiler toolchain with pre-compiled libraries to
build R and packages.  This toolchain is available in two forms: Rtools42
installer  (works very similarly to Rtools4) and a tarball ("base" or
"full") for manual installation.

## Installing Rtools42

A preview version of Rtools42 can be installed using an installer from
[here](https://www.r-project.org/nosvn/winutf8/ucrt3/), a file named such as
`rtools42-4737-4741.exe`, where `4737-4741` are version numbers and change
as new builds are being added.  The installer has currently about 360M in
size and about 3G will be used after installation.  It is bigger than
Rtools4, because it includes libraries needed by almost all CRAN packages,
so that such libraries don't have to be downloaded from external sources. 
The advantage is that this way it is easy to ensure that the toolchain and
the libraries are always compatible, and to upgrade the toolchain and all
libraries together.  Going from MSVCRT to UCRT was as extreme example of how
incompatibilities would otherwise arise, but they do arise even with small
updates to the toolchain, particularly libraries using C++.

It is recommended to use the defaults and install into `c:/rtools42`. When
done that way, Rtools42 may be used in the same R session which installed
them.

Rtools42 include build tools from Msys2 (like Rtools4, but in original Msys2
versions) and the compiler toolchain and libraries built using MXE (unlike
Rtools4, which builds them using Msys2).  From the user perspective, it
works the same as Rtools4 and the installer is almost the same, but the
installation is one step easier (one does not have to set PATH).

## Building packages from source using Rtools42

One only needs to install the R build and Rtools42 as shown above, in either
order.  No further set up is needed, not even PATH changes by default -- one
may run R e.g.  using the desktop icon (Rgui) and then invoke (but, in
short, this works from user perspective the same as with Rtools4 and the
MSVCRT builds of R):

```
install.packages("PKI", type="source")
```

which will build from source `PKI` and its dependency `base64enc`. A patch
for `PKI` to build with UCRT will be downloaded and applied automatically.

As a harder and longer test, let's try installing `RcppCWB` from github. 

First, install `devtools` (accept to build packages from source when
offered, but most needed packages will be installed as binary):

```
install.packages(devtools)
````

And then install `RcppCWB` from github from source:

```
devtools::install_github("PolMine/RcppCWB")
```

The installation will by default use an installation-time patch for RcppCWB.
Patches are found by package name, only, regardless where the packages are
installed from (CRAN, Bioconductor, github, etc).

Currently, RcppCWB supports UCRT via this patch by building the CWB source
code during R package installation, like e.g. on Unix, so this takes several
minutes.

Finally, let's check package `tiff`:

```
download.packages("tiff", destdir=".")
tools::Rcmd("check tiff_0.1-8.tar.gz") # update file name as needed
```

One can run the package check also from command-line, e.g. cmd.exe, as
usual. No setting of PATH is necessary.

## Building R from source using Rtools42

As with Rtools4, one may run the Msys2 shell ("Rtools bash" from the startup
menu, or `c:/rtools42/msys2.exe` and run R from there).  One may also
install additional Msys2 software using `pacman`, e.g.  additional build
tools.

Run the Msys2 shell, update the Msys2 part and install two more package:

```
pacman -Syuu
pacman -Sy wget subversion
```

These pacman commands may also be useful:

* Install an index of available files using `pacman -Fy` and then get e.g. 
a package providing file `unzip.exe` by `pacman -F unzip.exe`.

* List all available packages (not necessarily installed) using `pacman
-Sl`.  List installed packages using `pacman -Q`.

One should only be installing packages from "msys" sub-repository of Msys2,
mixing other sub-repositories with the toolchain may cause trouble.

Like Rtools4, but unlike Msys2 default, the home directory in `bash` is the
user profile (e.g. `C:\Users\username`).

As a next step to install R from source, download and unpack Tcl/Tk bundle
from [here](https://www.r-project.org/nosvn/winutf8/ucrt3/), a file
currently named `Tcl.zip` (but it may soon also get a version number). 
Download R sources.  Download and apply patches for R (please note that the
numbers 80912 and 4742 below need to be replaced by the current ones, there is
always only one version available at the time; see the
[README](https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/r_packages/README_checks)
for more information about versioning)

```
wget https://www.r-project.org/nosvn/winutf8/ucrt3/Tcl.zip

svn checkout -r 80912 https://svn.r-project.org/R/trunk

RDIFF=R-devel-80912-4742.diff
wget https://www.r-project.org/nosvn/winutf8/ucrt3/$RDIFF

cd trunk
patch --binary -p0 < ../$RDIFF

unzip ../Tcl.zip

cd src/gnuwin32
```

The `--binary` option to patch above is due to Windows line endings.

To automatically download always the current/latest version of the diff, one
can do e.g.  this:

```
wget -np -nd -r -l1 -A 'R-devel-*.diff' https://www.r-project.org/nosvn/winutf8/ucrt3
```

And a similar trick can be used to obtain other files that always exist once
and have changing version names.

Set environment variables as follows (update MiKTeX installation directory
in the commands below if needed, this one is "non-standard" from an
automated installation described later below):

```
export PATH=/c/rtools42/x86_64-w64-mingw32.static.posix/bin:/c/rtools42/usr/bin:$PATH
export PATH=/c/Program\ Files/MiKTeX/miktex/bin/x64:$PATH
export TAR="/usr/bin/tar"
export TAR_OPTIONS="--force-local"
```

Test that the tools are available by running

```
which make gcc pdflatex tar
```

Note: GNU `tar`, which is part of Rtools42, does not work with colons used
in drive letters on Windows paths, because it instead uses colons when
specifying non-local archives.  By adding `--force-local` to `TAR_OPTIONS`,
this is disabled and colons work for drive letters.  One can, instead, use
the Windows tar (a variant of BSD tar) on Windows 10 and newer, e.g. 
`/c/Windows/System32/tar`, but several packages rely on GNU tar features
particularly during installation.  Rtools4 and earlier used a customized
version of GNU tar, which did not need the `--force-local` options for drive
letters to work.

`MkRules.rules` expects Inno Setup in `C:/Program Files (x86)/Inno Setup 6`.
If you have installed it into a different directory, specify it in
`MkRules.local`, as shown here:

```
cat <<EOF >MkRules.local
ISDIR = C:/Program Files (x86)/InnoSetup
EOF
```

Build R and recommended packages:

```
make rsync-recommended
make all recommended
```

When the build succeeds, one can run R via `../../bin/R`.

To build the installer, run `make distribution`, it will appear in
`installer/R-devel-win.exe`. Note, one may use parallel make via `-j` for
`all` and `recommended`, but not for `distribution` (because the manual
cannot be built in parallel).

To build R with debug symbols, set `export DEBUG=T` in the terminal before
the build (and possibly add `EOPTS = -O0" to MkRules.local to disable
compiler optimizations, hence obtaining reliable debug information). Note
that a debug build is also available for download from
[here](https://www.r-project.org/nosvn/winutf8/ucrt3/).

## Upgrading Rtools42

Please note that when Rtools42 is uninstalled, one looses also the Msys2
packages installed there in addition to the default set (or any other
possibly accidentally added files to the installation directory, so to
`c:\rtools42` by default).

One might use a standalone installation of Msys2 and use the toolchain from
the tarball (as described later in the text), but it is not necessary to
uninstall Rtools42 to upgrade it.

Instead, one may upgrade the Msys2 part by `pacman`:

```
pacman -Syuu
```

The toolchain and libraries in Rtools42 can be upgraded from the Rtools42
Msys2 bash. The toolchain and libraries are inside
`/x86_64-w64-mingw32.static.posix` (which corresponds to
`c:\rtools42\x86_64-w64-mingw32.static.posix` outside the shell).

To find what is the current installed version, run

```
cat /x86_64-w64-mingw32.static.posix/.version
```

You will get a single number, such as `4911`, which corresponds to the
number in the toolchain tarball, e.g. `gcc10_ucrt3_full_4911.tar.zst`. So
all that is needed is to delete the directory, download the current full toolchain tarball from
[here](https://www.r-project.org/nosvn/winutf8/ucrt3/gcc10_ucrt3_full_4911.tar.zst)
and extract it. This can be done from the shell using commands like

```
cd /
wget https://www.r-project.org/nosvn/winutf8/ucrt3/gcc10_ucrt3_full_4911.tar.zst
rm -rf /x86_64-w64-mingw32.static.posix
tar xf gcc10_ucrt3_full_4911.tar.zst
rm gcc10_ucrt3_full_4911.tar.zst
```

For reference, one may found out exactly how that version of the toolchain
was built by checking out

```
svn checkout -r 4911 https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/toolchain_libs/mxe/
```

The version numbers, download URLs for the sources, and build configurations
are under "src" (not all of those packages are part of the toolchain). So
e.g. to find out how `tiff` was built, one may run

```
svn cat -r 4911 https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/toolchain_libs/mxe/src/tiff.mk
```

This is one way to quickly find out if an upgrade would provide a newer
version of a specific library.

An upgrade "to fix things, without knowing for sure it will help" may be
useful when one is building someone else's source packages (so not from CRAN,
where binary packages are provided, but say from github) and the package
doesn't build due to say linking errors, but it builds correctly somewhere
else (say via github actions on the package github page).  One might also
try on Winbuilder.  When such package is building there fine, but locally
has linking errors, it may be that an upgrade could help.

In other cases, a package author working on their own package would
probably know for sure that an upgrade is needed, e.g. when local
installation of Rtools42 does not have a library which was however already
added to Rtools42.

## Co-existence of different Rtools and R versions

Package authors may prefer to have both Rtools4 and Rtools42 installed in
their system.  This is possible, these are treated as different applications
by Windows and are installed in different directories (by default
`c:\rtools40` and `c:\rtools42`).  It means one would have duplicate
installations of Msys2 (which are included in both), so there would be
different sets of Msys2 packages and different versions in the two
corresponding "Rtools" Msys2 shells. The home directory as perceived by the
shells will be the same (the user profile), which may be a good thing, yet,
there are potential issues with configurations of some of the tools, if they
have different versions.  That would be easiest to solve by upgrading the
Msys2 packages.

R version 4.1 and 4.0 would automatically use Rtools40 as documented for
those versions (with the necessity to put the build tools on PATH, as
documented). The UCRT builds (and eventually R 4.2) will automatically use
Rtools42 as documented here.

However, it is not possible easily to have an (old) MSVCRT-based as well as
(new) UCRT-based installation of R-devel. One should instead delete the old
one and delete the old library before installing the new one.


## Installing software for building using toolchain tarball

Toolchain tarballs are provided as an alternative to Rtools42. The "base"
version contains the compiler toolchain and libraries needed to build R
itself, but it is enough for most CRAN packages as well. The "full" version
contains libraries for almost all CRAN packages.

The tarballs do not include Msys2.  One instead needs to have a separate
installation of the required build tools, typically a standalone
installation of Msys2.  This text assumes a standalone Msys2 installation at
least with packages `unzip diffutils make winpty rsync texinfo tar
texinfo-tex zip subversion bison moreutils xz patch`.

The tarballs are more flexible in that one does not need to always install
the "full" version.  Also, they are compressed using the Zstandard
compressor, which works better for this content than the compressor used by
Rtools42, so the compressed file is smaller and decompresses faster.

The script below automatically installs Msys2, MiKTeX and Inno Setup (the
last two into non-standard directories) and can be used on fresh systems or
virtual machines or containers without previous installation of this
software.  It could also be used as an inspiration for installing on real
systems, but one should review it first or run selected lines manually,
to prevent damage to the existing installations:

```
cd \
Invoke-WebRequest -Uri https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/r/setup.ps1 -OutFile setup.ps1 -UseBasicParsing
PowerShell -ExecutionPolicy Bypass -File setup.ps1
```

One may also want to clean up after the script (`temp` can be deleted).

## Building packages from source using toolchain tarball

This assumes that R has been installed from the binary installer.

First, download the toolchain and libraries. They are
available in a single tarball
[here](https://www.r-project.org/nosvn/winutf8/ucrt3/), a file named such as
`gcc10_ucrt3_full_4737.tar.zst` (4737 is version number). 
The "base" toolchain is named `gcc10_ucrt3_base_4737.tar.zst`.

You may run an Msys2 shell `C:\msys64\msys2.exe` and the following commands
(please note the number 4737 in this example needs to be replaced by the
current release available, there is always only one at a time):

```
mkdir ucrt3
cd ucrt3
wget https://www.r-project.org/nosvn/winutf8/ucrt3/gcc10_ucrt3_full_4737.tar.zst
tar xf gcc10_ucrt3_full_4737.tar.zst

export R_CUSTOM_TOOLS_SOFT=`pwd`/x86_64-w64-mingw32.static.posix
export R_CUSTOM_TOOLS_PATH=`pwd`/x86_64-w64-mingw32.static.posix/bin:/usr/bin
export PATH=/c/Program\ Files/MiKTeX/miktex/bin/x64:$PATH
export TAR="/usr/bin/tar"
export TAR_OPTIONS="--force-local"
```

To make the use of Rtools42 simpler, when R is installed via the binary
installer, it by default uses Rtools42 for the compilers and libraries. 
`PATH` will be set by R (inside frontends like RGui and RTerm, but also R
CMD) to include the build tools (e.g.  make) and the compilers (e.g.  gcc). 
In addition, R installed via the binary installer will automatically set
`R_TOOLS_SOFT` (and `LOCAL_SOFT` for backwards compatibility) to the
Rtools42 location for building R packages.  This feature is only in the
installer builds of R, not when R is installed from source.

Now we are building packages using a custom installation of the toolchain
(the toolchain tarball) at an arbitrary location, and we use R installed
from the binary installer, and hence as shown above we set
`R_CUSTOM_TOOLS_PATH` and `R_CUSTOM_TOOLS_SOFT`.  `R_CUSTOM_TOOLS_PATH` will
be prepended to PATH instead of the Rtools42 directories. 
`R_CUSTOM_TOOLS_SOFT` value will be used as `R_TOOLS_SOFT` (and
`LOCAL_SOFT`) instead of the Rtools42 soft directory.  See below in this
text for discussion re `LOCAL_SOFT`.

This is not needed when installing R from source and building R packages
using that installation. In such case, the build tools and compilers already
have to be on PATH, and R uses by default `R_TOOLS_SOFT` (and `LOCAL_SOFT`)
derived from that. See below in this text for discussion re `LOCAL_SOFT`.

One wouldn't have to add `/usr/bin` to `R_CUSTOM_TOOLS_PATH` when running in
a standard installation of Msys2, but it is done here for instructional
purposes and may be useful in more complicated setups where a mix of tools
may be on PATH, such as github actions.

Note in the above example that the compiler toolchain does not have to be on
PATH itself, but it would do no harm if it were.

Now run R from the same terminal by `/c/Program\ Files/R/R-devel/bin/R`. Try
installing "PKI": `install.packages("PKI", type="source")`.

This will build from source `PKI` and its dependency `base64enc`. A patch
for `PKI` to build with UCRT will be downloaded and applied automatically.

Examples in this documents use Msys2 with mintty and bash, which is the
default with Msys2 and is perhaps easier to use with building/testing for
those familiar with Unix. One can, however, also use cmd.exe, with the
benefit of nicer fonts and more reliable line editing (mintty uses a
different interface to communicate with RTerm).

## Building R from source using toolchain tarball

Download and unpack Tcl/Tk bundle from
[here](https://www.r-project.org/nosvn/winutf8/ucrt3/), a file currently
named `Tcl.zip`.  Download R sources.  Download and apply patches for R. 
Do this in the Msys2 shell  (please note that
the numbers 80890 and 4736 need to be replaced by the current ones)

```
wget https://www.r-project.org/nosvn/winutf8/ucrt3/Tcl.zip

svn checkout -r 80890 https://svn.r-project.org/R/trunk

wget https://www.r-project.org/nosvn/winutf8/ucrt3/R-devel-80890-4736.diff

cd trunk
patch --binary -p0 < ../R-devel-80890-4736.diff

unzip ../Tcl.zip

cd src/gnuwin32
```

Set environment variables. Note that when building R, one needs to have the
compiler toolchain on PATH, it is not added automatically in this case
(adjust below if the toolchain tarball was unpacked in a different
directory). The `R_CUSTOM_TOOLS_SOFT` and `R_CUSTOM_TOOL_PATH` variables are
not needed when buillding R from source, but setting them would do no harm:

```
export PATH=`pwd`/x86_64-w64-mingw32.static.posix/bin
export PATH=/c/Program\ Files/MiKTeX/miktex/bin/x64:$PATH
export TAR="/usr/bin/tar"
export TAR_OPTIONS="--force-local"
```

Test that the tools are available by running (set variables like for
building R packages, as shown above):

```
which make gcc pdflatex tar
```

`MkRules.rules` expects Inno Setup in `C:/Program Files (x86)/Inno Setup 6`.
If you have installed it into a different directory (such as by the
automated script above), specify it in `MkRules.local`:

```
cat <<EOF >MkRules.local
ISDIR = C:/Program Files (x86)/InnoSetup
EOF
```

Build R and recommended packages:

```
make rsync-recommended
make all recommended
```

When the build succeeds, one can run R via `../../bin/R`.

To build the installer, run `make distribution`, it will appear in
`installer/R-devel-win.exe`.

To build R with debug symbols, set `export DEBUG=T` in the terminal before
the build (and possibly add `EOPTS = -O0" to MkRules.local to disable
compiler optimizations, hence obtaining reliable debug information).

## Testing packages using github actions

Github default runners for github actions include Windows Server 2022, which
has support for UTF-8 as native encoding and has pre-installed build tools. 
It is thus convenient to only install the toolchain there, packaged using
Zstandard compression (smaller, faster to decompress).

For packages that only need libraries from the "base" toolchain, it is
better to use that, saving more time and bandwidth.  The actions should
download the toolchain from github, not from CRAN servers.

R itself can be installed from the binary installer and cached. Caching the
toolchain itself is not helpful: the default compression currently used for
that is much less efficient than Zstandard, so using the cache checking
takes longer and requires more resources.

An experiment has been carried out using `codetools` (a package without
dependencies and not needing compilation) and using `tiff` (a package needed
compilation and depending on two more packages). 

With `tiff`, checking with a missing toolchain (which fails) took over 1
minute. Checking with the base toolchain took nearly 2 minutes (and
passed, it is enough for the involved packages). Checking with the full
toolchain took 3 minutes (note: the timings are expected to vary based on
internal github setup). More information is available
[here](https://github.com/kalibera/ucrt3).

## Other package building/checking options

The [Winbuilder](https://win-builder.r-project.org/) service and
[R-hub](https://builder.r-hub.io/) already support the new toolchain.

## Updating R packages to work with the UCRT toolchain

R packages with only R code should work without any modification.  R
packages with native code (C, Fortran, C++) but without any dependencies on
external libraries may and often do work right away as well.  Other packages
will typically need some updates.

### Linking to pre-built static libraries

Some R packages tend to download external static libraries during their
installation from "winlibs" or other sources.  When this work started, such
libraries were, however, understandably built for  MSVCRT and hence
did not work with UCRT build of R.

A common symptom of this incompatibility is that one gets error messages about undefined references
to various symbols, often  `__imp___iob_func`, `__ms_vsnprintf` or
`_setjmp`. Downloading
of external code is usually obvious from `src/Makevars.win` (e.g. presence
of "winlibs" or from `configure.win`) and from installation outputs.

To fix this, one needs to instead build against libraries built for UCRT. 
While libraries built for UCRT may become available for download, it is not
a good idea downloading them during package installation.

For transparency, source packages should contain source (not executable
code).  Using pre-compiled binaries often leads to that after few years, the
information on how they were built gets lost. Using older binary code may
also provide insufficient performance (newer compilers tend to optimize
better).  Also, the CRAN (and Bioconductor) repositories are used as a
unique test suite for R itself but also the toolchain, and by re-using
pre-compiled libraries, some parts will not be tested.  Finally, object
files (and hence static libraries, particularly when using C++) on Windows
tend to become incompatible when even the same toolchain is upgraded.  Going
from MSVCRT to UCRT is an extreme case when all such code becomes
incompatible, and adding support to 64-bit ARM would be another extreme
case, but smaller updates of different parts of the toolchain or even some
libraries in it have lead to incompatibilities as well.

As an example of the necessary updates, package `tiff` as of this writing
has in `src/Makevars.win`:

```
RWINLIB = ../windows/libtiff-4.1.0/mingw$(WIN)
PKG_CPPFLAGS = -I$(RWINLIB)/include
PKG_LIBS = -L$(RWINLIB)/lib -ltiff -ljpeg -lz

all: clean winlibs

winlibs:
        "${R_HOME}/bin${R_ARCH_BIN}/Rscript.exe" "../tools/winlibs.R"
```

To make the package build with UCRT and the experimental toolchain, one can
replace these lines by:

```
PKG_LIBS = -ltiff -ljpeg -lz -lzstd -lwebp -llzma 
all: clean 

```

Note that even Rtools4 has these libraries, so one could make a similar
change also for building the package with Rtools4 (even for MSVCRT, so avoid
downloading pre-compiled libraries). However, the same set and ordering of
libraries may not work with Rtools4, because the names would sometimes be
different.

### Creating a package patch

This new build of R automatically downloads and applies patches to
packages from [here](https://www.r-project.org/nosvn/winutf8/ucrt3/patches), so
[tiff.diff](https://www.r-project.org/nosvn/winutf8/ucrt3/patches/CRAN/tiff.diff)
is a patch for the tiff package discussed above.

These patches have been created for most CRAN packages and several
Bioconductor packages (so that all Bioconductor packages needed for CRAN
packages are built), so package authors can currently just take them, review
them, and incorporate in their packages, but eventually such changes have to
be maintained in the packages.

To create such a patch, get and unpack the sources

```
wget https://cran.r-project.org/src/contrib/tiff_0.1-6.tar.gz
mkdir original patched
cd original
tar xfz ../tiff_0.1-6.tar.gz
cd ../patched
tar xfz ../tiff_0.1-6.tar.gz
```

If updating an existing patch, apply it first:

```
cd patched
wget https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/r_packages/patches/CRAN/tiff.diff
patch -p1 <tiff.diff
```

now you may edit any source file in the package, e.g. 
`patched/tiff/src/Makevars.win` as shown above. However, specifically for
the case of `Makevars` (and `Makefile`) files, it is preferred to create a
copy with `.ucrt` extension instead of `.win`. `Makevars.ucrt`
(`Makefile.ucrt`) will take precedence over `Makevars.win` (`Makefile.win`)
in the UCRT builds of R. Similarly, `configure.ucrt` and
`cleanup.ucrt` take precedence over `configure.win` and `cleanup.win`. This
way, one may keep the package working also with older toolchains and older
versions of R.

Test the package:

```
env _R_INSTALL_TIME_PATCHES_=no R CMD build patched/tiff # possibly with --no-build-vignettes
env _R_INSTALL_TIME_PATCHES_=no R CMD INSTALL tiff_0.1-6.tar.gz
env _R_INSTALL_TIME_PATCHES_=no R CMD check tiff_0.1-6.tar.gz
```

The setting of `_R_INSTALL_TIME_PATCHES_=no` above ensures that R will not
attempt to patch automatically the package using a possibly present earlier
patch, but will build/install/check exactly the tarball given.

And when done with testing, create the patch using

```
diff -Nru original/tiff patched/tiff > tiff.diff
```

Note the 'N' which ensures new files (e.g. `Makevars.ucrt`) are added to the
patch.

One may instruct R to download patches, instead, from a local directory. To
do so, download first the current patches from
[here](https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/r_packages/patches/),
update them as needed, then run script [build_patches_idx.r](https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/r_packages/build_patches_idx.r)
to build patch index `patches_idx.rds`, and then tell R via environment
variable `_R_INSTALL_TIME_PATCHES_` about the directory where this index is.

This automated installation-time patching is only intended as convenience
for testing and transition to the new toolchain. It is likely that the
patches will be removed in the future and this feature will be removed or
disabled by default.

Therefore, if you are a package maintainer and want your package to work
with UCRT, please update your source code accordingly, e.g.  via adding
`Makevars.ucrt` files.  Feel free to re-use/copy from the patches provided
for your packages, and feel free then to ask for the patches to be removed
from the central repository.

If you are maintaining a package not on CRAN, but need to patch it to use a
specific library from the toolchain, which is used by some CRAN package, it
might be useful starting from the linking orders of that package (or a patch
available for that package), rather than from scratch.

### Multiple definitions of symbols

Another common issue observed with the new toolchain are linker errors about
multiply defined symbols.  This may be because GCC 10 is stricter about the
use of tentative definitions (global variables defined without an
initializer) than earlier versions, which allowed merging of tentative
definitions by the linker by putting them into a single "common" block.
 
With GCC 10, and earlier version with `-fno-common`, this merging does not
happen and one instead gets the linker error.  A quick hack is to build with
`-fcommon` to still use the common block, and this is also a reliable way of
detecting the cause of the problem. See
[Writing R Extension](https://cran.r-project.org/doc/manuals/r-release/R-exts.html#Common-symbols)
for more details.

The patches provided for affected packages for now mostly use `-fcommon` in
such cases, but this is a hack. Package maintainers who want their packages
to work with UCRT (and GCC 10 and newer in principle) should instead fix the
source code of their packages and then ask for the patch to be removed from
the central repository.

### Other issues

Other problems faced already included missing external libraries (MXE
configurations need to be added, as described below), external libraries
built in a way unexpected by the package or in an unexpected version (e.g. 
HDF5), headers stored in different directories (note `R_TOOLS_SOFT` variable
is set to the root of the toolchain, so `$(R_TOOLS_SOFT)/include` is added
automatically and subdirectories may be added explicitly), explicit setting
of Windows target version (`_WIN32_WINNT`).  Posix thread-safe functions are
only available when `_POSIX_THREAD_SAFE_FUNCTIONS` macro is defined.

## Building the toolchain and libraries from source

The toolchain and libraries are built using a modified version of
[MXE](https://mxe.cc/), which is available
[here](https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/toolchain_libs/mxe). 
The build is run on a Linux machine, so it involves building a
GCC10/MinGW-W64/UCRT cross-compilation toolchain, cross-compiling a large
number of libraries needed by R and R packages, and then building also a
native compiler toolchain so that R and R packages can be built natively on
Windows.

Scripts for setting up the build in docker running Ubuntu, Debian or Fedora are
available
[here](https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/toolchain_libs/).
However, this is easy enough and convenient to run natively. On Ubuntu
20.04, following [MXE documentation](https://mxe.cc/#requirements-debian),
install these packages:

```
apt-get install -y \
    autoconf \
    automake \
    autopoint \
    bash \
    bison \
    bzip2 \
    flex \
    g++ \
    g++-multilib \
    gettext \
    git \
    gperf \
    intltool \
    libc6-dev-i386 \
    libgdk-pixbuf2.0-dev \
    libltdl-dev \
    libssl-dev \
    libtool-bin \
    libxml-parser-perl \
    lzip \
    make \
    openssl \
    p7zip-full \
    patch \
    perl \
    python \
    ruby \
    sed \
    unzip \
    wget \
    xz-utils
```

And then also install these:

```
apt-get install -y texinfo sqlite3 zstd
```

For Fedora distributions, see the script `build_in_docker.sh` for the
required dependencies. Please refer to the script for any updates to the
list of packages shown above.

Run `make` (or `make -j`)  in `mxe`.  The build takes about 2 hours on a
server machine with 20 cores, so don't expect that to be fast, but then
building individual MXE packages (new, modified) is fast as the build is
incremental using `make`.  It has been reported that 8G of RAM and two cores
is enough for the build.

The result will appear in `mxe/usr`, the native toolchain and libraries
specifically in `mxe/usr/x86_64-w64-mingw32.static.posix`. The content of
that directory is currently just packed into a tarball available as
e.g. `gcc10_ucrt3_full_4354.tar.zst` [here](https://www.r-project.org/nosvn/winutf8/ucrt3/).

The toolchain is now regularly built in a docker container using the
provided script. One of the advantages is that it is easier to ensure that
absolute paths (some files use them, see below) are set up properly. 

## Adding/updating MXE package

Some R packages cannot be built or don't work, because they depend on an
external library not available in the toolchain. To add such
software, one needs to create an appropriate MXE package or update one. [MXE](https://mxe.cc/)
documentation has more details, but for example the package for the tiff
library is named "tiff" and available [here](https://github.com/mxe/mxe/blob/master/src/tiff.mk)
and did not have to be customized for R:

```
# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := tiff
$(PKG)_WEBSITE  := http://simplesystems.org/libtiff/
$(PKG)_DESCR    := LibTIFF
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 4.2.0
$(PKG)_CHECKSUM := eb0484e568ead8fa23b513e9b0041df7e327f4ee2d22db5a533929dfc19633cb
$(PKG)_SUBDIR   := tiff-$($(PKG)_VERSION)
$(PKG)_FILE     := tiff-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := https://download.osgeo.org/libtiff/$($(PKG)_FILE)
$(PKG)_DEPS     := cc jpeg libwebp xz zlib

define $(PKG)_UPDATE
    $(WGET) -q -O- 'http://simplesystems.org/libtiff/' | \
    $(SED) -n 's,.*>v\([0-9][^<]*\)<.*,\1,p' | \
    head -1
endef

define $(PKG)_BUILD
    cd '$(1)' && ./configure \
        $(MXE_CONFIGURE_OPTS) \
        --without-x
    $(MAKE) -C '$(1)' -j '$(JOBS)' install $(MXE_DISABLE_CRUFT)
endef
```

One may add a new package to `src`, then build it using `make pkgname`, and
when ready, add that to `settings.mk` to the `LOCAL_PKG_LIST` so that it is
built automatically. One the needs to copy the updated
`usr/86_64-w64-mingw32.static.posix` to the Windows machine and perform R
package builds there.

When maintaining open-source software distributions, often one may take
inspiration from somewhere else.  First, many packages are already available
in MXE; if they just work, they only need to be added to `settings.mk`. 
Still, a number of packages had to be adapted or upgraded to build with
UCRT.  Then, some packages may be available in a similar customized version
of MXE used by Octave, [MXE-Octave](https://wiki.octave.org/MXE).  Then some
packages popular in the R community but not present in MXE may be available
in [Msys2](https://github.com/msys2/MINGW-packages) or
[Rtools4](https://github.com/r-windows/rtools-packages), yet those package
configurations are in a different format and not written for
cross-compilation nor static linking.  Linux distributions, e.g.  Debian,
then have much bigger selection of build configurations of packages, again
in a different format.

If your package needs a library not currently supported by the modified
version of MXE used to build in this toolchain, you are welcome to provide a
build configuration for such library. Primarily, such package
configuration would be contributed directly to upstream MXE, which may be a
forcing function to test such package in a wider context (e.g. also
dynamic linking, also MSVCRT, etc), but a much wider group of users will be
able to benefit from that. Also, it would reduce the maintenance overhead
of the toolchain.

## Establishing the linking order from existing patches

As noted above, most CRAN packages that needed it at the time of this
writing have been patched (the patch adding `Makevars.ucrt`), so package
maintainer may find linking orders there and test them, update and add to
their source code. 
It may be that some of them are incorrect, even though there are no linking
errors - package authors may know better knowing their code, and issues
should be discovered by testing.

## Establishing the linking order in R packages via pkg-config

The linking order can be obtained via `pkg-config`. On the 
cross-compilation host (Linux) one may run

```
env PKG_CONFIG_PATH=usr/x86_64-w64-mingw32.static.posix/lib/pkgconfig ./usr/x86_64-pc-linux-gnu/bin/pkgconf --static libtiff-4 --libs-only-l
```

to get `-ltiff -lwebp -lzstd -llzma -ljpeg -lz`, a correct linking order
which may be added to the package `src/Makevars.ucrt` (`src/Makevars.win`)
for package tiff.  One still has to figure out that the pkg-config package
name is `libtiff-4` (the MXE package is `tiff`, the Rtool4 package is
`libtiff`).

Unfortunately, `pkg-config` does not always provide a working linking order. 
For example, for `opencv`, at the time of this writing (running on Linux),

```
env PKG_CONFIG_PATH=usr/x86_64-w64-mingw32.static.posix/lib/pkgconfig ./usr/x86_64-pc-linux-gnu/bin/pkgconf --static opencv4 --libs-only-l
```

gives

```
-lopencv_highgui451 -lopencv_ml451 -lopencv_objdetect451 -lopencv_photo451 -lopencv_stitching451 -lopencv_video451 -lopencv_calib3d451 -lopencv_features2d451 -lopencv_dnn451 -lopencv_flann451 -lopencv_videoio451 -lopencv_imgcodecs451 -lopencv_imgproc451 -lopencv_core451 -llibopenjp2 -lquirc -lprotobuf -lcomctl32 -lgdi32 -lole32 -lsetupapi -lws2_32 -ljpeg -lwebp -lpng -lz -ltiff -lzstd -llzma -lopengl32 -lglu32
```

which does not work.  One has to add
`-L$(R_TOOLS_SOFT)/lib/opencv4/3rdparty` so that `-llibopenjp2 -lquirc` are
found.  `R_TOOLS_SOFT` is set to the root of the compiled native toolchain,
`R_TOOLS_SOFT`/include is automatically available for headers,
`R_TOOLS_SOFT`/lib is automatically available for libraries, but when one
needs to refer to files in different locations or for different tools, one
may have to use that variable.

There is also `LOCAL_SOFT` variable which by default points to the root of
the compiled toolchain and in some CRAN packages has been used for this
purpose (well before this toolchain existed).  However, the original idea of
`LOCAL_SOFT` was to use it for libraries not available with the toolchain,
like `/usr/local` is used on Unix machines to refer to software not part of
the OS distribution.  It is hence more portable to use `R_TOOLS_SOFT` for
the purpose of referring to the libraries/headers which are part of the
toolchain.

Going back to the list of libraries obtained by pkg-config for opencv, this
list is not complete, a number of dependencies are missing (`webp` is one of
them).  In principle, this is a common problem that `pkg-config`
configurations are not thoroughly tested with static linking.

Packages hence should not use `pkg-config` directly in their make files, but
in some cases, it may be give a hint/starting point when establisthing the
linking order. In Rtools42 (so running on Windows), one may install
`pkg-config` and get the libraries for `opencv` as follows:

```
pacman -Sy pkg-config
env PKG_CONFIG_PATH=/x86_64-w64-mingw32.static.posix/lib/pkgconfig pkg-config --static opencv4 --libs-only-l
```

But, again, they don't work.

## findLinkingOrder: tool for establishing the linking order via topological sort

In the end all the linking orders were established  via computation over the
compiled static libraries, this is how.

### Background

This section may be skipped by those looking only for instructions to
follow.

R on Windows uses static linking.  Static libraries are just archives of
object files, without any references to other static libraries they may need
as dependencies.  The linker keeps track of the currently undefined symbols
and goes through the list of libraries (so archives of object files) from
left to right.  If an object file from a library defines a symbol that the
linker knows is undefined, the linker will add that object file to the
binary.  It will then add any additional object files from the same library
which define any undefined symbols arising from the same library, but it
will not add other object files from that library.  This may result in that
new symbols would become undefined after processing that library.  These
symbols have to be defined by some of the additional libraries in the list.

For this to work, one needs to make sure that any time one library uses a
symbol from another library, it is processed earlier by the linker.  This is
a problem when there is a loop of dependent libraries, however, one can
usually resolve that by adding some libraries multiple times to the list or
moving some library in the list, taking advantage of the mechanism described
above: only the object files with some currently needed symbols are added
from the library.

The GNU linker also allows to specify linking groups, within which linking
is repeated in the given order re-starting until all symbols are resolved
(see `--start-group` and `--end-group`), with a price in performance.  This
feature has not been needed yet in the experimental toolchain.

Symbols exported from object files and actually missing at linking time are
mostly unique in the experimental toolchain.  Non-unique are some inlined
C++ functions (but then they are not missing at linking time), alternative
implementations (e.g.  parallel OpenBLAS, serial OpenBLAS, reference BLAS),
runtime library wrappers (but they are not missing at linking time).  As
these exceptions are rare, it was possible to come up with a simple tool
which can reasonably well advice on the list and order of libraries to link,
with heuristics to resolve some edge cases.

Traditionally, this is done in Unix using `lorder` script and `tsort`. 
`lorder` generates a list of dependencies between static libraries,
defensively assuming that all object files from those libraries are needed. 
`tsort` establishes a topological ordering on the result of `lorder`.  One
can just try to build an R package without linking any libraries, parse the
output from the linker looking for undefined symbols, find static libraries
providing such symbols, and establish the topological ordering.  The
resulting linking order can be then added to the `src/Makevars.ucrt`
(`src/Makevars.win`), the build of the R package tried again, generating
another list of undefined symbols.  Then one can merge the list of libraries
established previously with the list established now, do the topological
sort again, and iterate this way until linking succeeds. `findLinkingOrder`
does this, with some additional heuristics, as shown below.

This is how linking orders for most patched CRAN packages were obtained, but
thorough testing is needed to figure out whether they produce a working
package.  In principle, a better tool could definitely make this process
faster and more automated, and not requiring manual iterative linking
attempts.

Some manual adaptations to the linking orders created that way were needed,
anyway, and probably always will.  These included resolving loops (`tsort`
gives warning when it sees them, which is a hint) by shifting libraries in
the ordering and adding some twice.  Also, some symbols are not completely
unique in the toolchain and the semi-automated process did not choose the
best library (e.g.  `libmincore` and `libwindowsapp` should not be linked,
because they depend on console Windows DLLs which are not present on Windows
Server). `-lsbml-static` should be used instead of `-lsbml.dll` (the latter
is an import library for a DLL, not a static library with the code per se).

None of this should be needed if the `pkg-config` databases were fixed to
work reliably with static linking.  That could be done via improving MXE
package configurations, but the effort required may be bigger than improving
a hint tool described above, but if fixed, the results could be more
reliable.  One still would need to know the right names of the pkg-config
packages, which are distribution specific.

Note that similar problems with other toolchains may be hidden when
pre-built (bigger) static libraries are being downloaded during package
installation.

### Using findLinkingOrder with Rtools42 (tiff package example)

This example uses Rtools42 and binary build of R. Run Rtools42 shell (Msys2
bash), download and extract the source package `tiff`. Create a temporary
`Makevars.ucrt` file as follows:

```
PKG_LIBS = -Wl,--no-demangle $(shell cat /tmp/tiff.libs)
```

Get the `findLinkingOrder` tool

```
svn checkout https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/linking_order
```

Run the tool, specifying the file to hold the found linking order:

```
./linking_order/findLinkingOrder tiff /tmp/tiff.libs
```

First time, it will take long as it will be creating an index of the
libraries. The end of the output is:

```
Installation failed, trying to find required link order
 -ltiff

Saved in /tmp/tiff.libs
```

Which means, that the linking was not successful (indeed, we provided no
libraries), but we know that the directly missing symbols will be satisfied
by `-ltiff`, which was automatically added. So lets simply run the tool
again:

```
./linking_order/findLinkingOrder tiff /tmp/tiff.libs
```

The output now ends with:

```
Installation failed, trying to find required link order
-ltiff -lzstd -lz -lwebpdecoder -lwebp -llzma -ljpeg -lcfitsio

Saved in /tmp/tiff.libs
```

Which means that `-ltiff` was not enough, but there is an extended
suggestions. Lets run the tool the same way again. The output ends with

```
Installation succeeded!
```

Which means the list of libraries is complete. So now we can modify the
`Makevars.ucrt` using the computed list of libraries:

```
PKG_LIBS=-ltiff -lzstd -lz -lwebpdecoder -lwebp -llzma -ljpeg -lcfitsio
```

The `-Wl,--no-demangle` option is removed, because it is only needed for the
tool (and only for code using C++).

## Troubleshooting library loading failures

Sometimes a package DLL is linked succesfully, but the DLL cannot be loaded.
Sometimes it can be loaded on the machine where it was built, but not on
another machine. One example is the linking of console API present on
Windows 10, but not on Windows Server. A common problem why a DLL cannot be
loaded is that a dependent DLL is not found (unlike static libraries, DLLs
know their dependencies). This is a common problem which can happen on
Windows with any toolchain.

When this happens to a DLL linked to an application, such as `Rblas` linked
to `R`, an error message will appear helpfully saying that `Rblas` could not
be found.  However, when such DLL is being loaded explicitly via a Windows
API call (to `LoadLibrary`), which is the case when loading DLLs of R
packages, Windows is unable to say which DLL is missing:


```
Error: package or namespace load failed for 'magick' in inDL(x, as.logical(local
), as.logical(now), ...):
 unable to load shared object 'C:/msys64/home/tomas/ucrt3/svn/ucrt3/r_packages/r
inst/library/00LOCK-magick/00new/magick/libs/x64/magick.dll':
  LoadLibrary failure:  The specified module could not be found.
```

Note: in the above, `magick.dll` is present on the path listed.  It is some
of its dependencies that is not found, but Windows would tell which one. 
The confusing error message comes directly from Windows and R cannot
possibly fix that.

There is still a way to debug this.  One can install
[WinDbg](https://docs.microsoft.com/en-us/windows-hardware/drivers/debugger/)
from Microsoft (for free), which also includes
[gflags](https://docs.microsoft.com/en-us/windows-hardware/drivers/debugger/gflags).

Using `gflags /i Rterm.exe +sls` (note `gflags` gets installed to `C:\Program Files (x86)\Windows
Kits\10\Debuggers\x64\`) set "loaded snaps" for the R executable. Then run
R, get its process ID using `Sys.getpid()`, start `WinDbg`, attach to the R
process via that process ID, type 'g' (to continue running). In the R
process, try to load the problematic package, e.g. `library(magick)`. This
will produce a number of messages, but in this case, one of them was

```
3e94:29f8 @ 674068078 - LdrpProcessWork - ERROR: Unable to load DLL: "api-ms-win-core-console-l1-2-0.dll", Parent Module: "C:\msys64\home\tomas\ucrt3\svn\ucrt3\r\build_opt\trunk\library\magick\libs\x64\magick.dll", Status: 0xc0000135
```

Which made it clear that `api-ms-win-core-console-l1-2-0.dll` was the
missing DLL.

The flag can be removed using `-sls`. Note that the Msys2 console (mintty
with bash, by default) is very different from cmd.exe in Windows: the latter
uses a different API and e.g. sometimes shows more debugging messages,
etc. It is better to use cmd.exe when debugging (with `WinDbg` but also
gdb). One may use `gdb` from Msys2 with this toolchain the same way as with
Rtools4.

## Building other applications (e.g. JAGS) for UCRT

R packages are sometimes linked against dynamic libraries installed by
external applications. It may become necessary to rebuild such libraries as
well to be built for UCRT. It is advisable for encodings to be handled
properly (yet that depends on how that library handles encodings), but it
may be the least inconvenient solution also to avoid other clashes between
runtimes, such as in memory allocation.

[JAGS](http://mcmc-jags.sourceforge.net/) (Just Another Gibbs Sampler) is
used by R package rjags and some other packages.  JAGS is installed as a
standalone application via its interactive installer and includes shared
libraries (JAGS library and a number of modules) and C headers.  R packages
at build time use those C headers and link against that JAGS shared library.

When R package rjags is built with the UCRT toolchain, so linked against the
JAGS library from the official JAGS 4 distribution, it does not work.  The
linking of the R package library is successful, but building of the package
indices fail, unfortunately without any detailed error message.  The problem
is that building of package indices already involves loading the rjags
package and running it, and that crashes because of C runtime mismatch, the
JAGS library built for MSVCRT ends up calling UCRT free function on an
object allocated using MSVCRT.

To resolve this, JAGS has been rebuilt for UCRT using this experimental
toolchain. The installer is available
[here](https://www.r-project.org/nosvn/winutf8/ucrt3/extra/jags) and the script
used to build it is available
[here](https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/extra/jags).

The tricks needed to build JAGS follow and some may be needed when natively
building other applications as well.

First, JAGS uses libtool for linking.  Some libraries in MXE, and luckily
most of those used by JAGS have libtool control files (`.la` extension), but
by libtool design these files include hard-coded directories that are filled
when the toolchain is built, so a PATH on some Linux machine.  Currently
that directory is `/usr/lib/mxe/x86_64-w64-mingw32.static.posix`, and
Rtools42 automatically create a symbolic link (junction) to make sure this
works.  When running inside Msys2 (or cygwin), one may create the link
manually.  At the time of building JAGS this way, the `.la` files were fixed
to include the hard-coded directory on the Windows machine where they are
installed (using `sed -i -e`).

Then, JAGS uses `configure`, but when running in Msys2, the host system
identification is different from what the MXE-built toolchain has, so some
utilities (but not all) are not detected correctly. `configure` has to be
run with `--host=x86_64-w64-mingw32.static.posix`).

Futhermore, as documented in JAGS installation manual, libtool will not link
a static library to a shared library created as "module. This causes trouble
for some JAGS modules, such as "bugs", which link against LAPACK and BLAS.
The UCRT toolchain includes static libraries for reference LAPACK and BLAS,
but libtool refuses to link them (also, they don't have `.la` files).

This can be solved by building wrapper dynamic libraries for these static
LAPACK and BLAS libraries, following instructions from the JAGS manual, with
the toolchain on PATH (as when building R and packages):

```
export TLIB=~/svn/ucrt3/r/x86_64-w64-mingw32.static.posix/lib
dlltool -z libblas.def --export-all-symbols $TLIB/libblas.a
gfortran -shared -o libblas.dll -Wl,--out-implib=libblas.dll.a libblas.def $TLIB/libblas.a
dlltool -z liblapack.def --export-all-symbols $TLIB/liblapack.a
gfortran -shared -o liblapack.dll -Wl,--out-implib=liblapack.dll.a liblapack.def $TLIB/liblapack.a  -L. -lblas
```

One can then provide these libraries to JAGS configure via
`-with-blas="-L$TLHOME -lblas" --with-lapack="-L$TLHOME -llapack"`, where
`XXX` is the directory with `liblapack.dll` and `libblas.dll`.  These two
DLLs have to be then copied into the JAGS build tree before running the
installer:

```
./configure --host=x86_64-w64-mingw32.static.posix --with-blas="-L$TLHOME -lblas" --with-lapack="-L $TLHOME -llapack"
make win64-install
cp $TLHOME/libblas.dll $TLHOME/liblapack.dll win/inst64/bin
make installer
```

But, before running `make installer`, one needs to fix the installer script
for 64-bit-only build. The original installer supported both 32-bit and
64-bit architecture, but the experimental toolchain only supports 64-bit.
The patch is available with the build script,
[here](https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/extra/jags).
