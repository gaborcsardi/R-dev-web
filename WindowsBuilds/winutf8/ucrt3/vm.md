---
title: "Setting up a virtual machine to check R packages"
author: Tomas Kalibera
output: html_document
---
# Setting up a virtual machine to check R packages

This document describes how to get and set up a virtual machine running
Windows in which one may build and check R packages and R itself.  It uses a
free virtual machine provided by Microsoft for testing (with a 90-day limit,
see below).  The installation is automated via Vagrant.  The VM is set up
for ssh access (command line use) and RDP access (both command line and
graphics), with `bash` and command line tools to install and build R.

This setup was created primarily to help package developers normally working
on Linux or macOS who don't have access to Windows, but want to test or
debug their packages on Windows.  The document only covers the UCRT
toolchain, but the VM could easily be used for building also using other
toolchains.

## Installation

The process requires a good network connection.  The amount of data
downloaded on installation, including the toolchain, may be close to 10G. 
On a slow connection, one may have to re-start the process, see
`Troubleshooting' below.

### MacOS users

These instructions were tested on macOS 11.2.3 and 64-bit Intel machine.
They should work on older OS versions on Intel.

- Install [Vagrant](http://www.vagrantup.com) from macOS installer.

- Install [Virtualbox](http://www.virtualbox.org) from macOS ("OS X hosts")
  installer. At the end of installation, give the application the necessary
  permissions and reboot the machine as instructed by the installer.

- Install these vagrant plugins from the command line:
  ```
    vagrant plugin install winrm
    vagrant plugin install winrm-elevated
    vagrant plugin install winrm-fs
    vagrant plugin install vagrant-vbguest
  ```

- Install "Microsoft Remote Desktop" from App Store (optional).

- Generate an RSA ssh key for the current user from the command line (skip
  if you already have one in `~/.ssh/id_rsa`):
  ```
    ssh-keygen # run with defaults
  ```

- Create a new folder for the VM
  ```
    mkdir win10-tst
    cd win10-tst
  ```

- Download scripts to set up the VM
  ```
    curl -O https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/r/setup.ps1
    curl -O https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/extra/vagrant-win10-tst/Vagrantfile
  ```

- Download the "MSEdge on Win10 (x64) Stable 1809" VM for platform "Vagrant" from
  [here](https://developer.microsoft.com/en-us/microsoft-edge/tools/vms) and
  prepare it for vagrant:
  ```
    mv ~/Downloads/MSEdge.Win10.Vagrant.zip .
    unzip MSEdge.Win10.Vagrant.zip
    mv "MSEdge - Win10.box" MSEdgeWin10.box
    vagrant box add win10-tst MSEdgeWin10.box
  ```
- Start vagrant to install the VM (automated, takes about 20 minutes):
  ```
    vagrant up
  ```

### Ubuntu users

These instructions were tested on Ubuntu 20.04 and 64-bit Intel machine.
They should work on other Ubuntu versions on Intel.

- Install these packages as root:
  ```
    apt-get install virtualbox vagrant
    apt-get install freerdp2-x11 # optional
  ```
- Install these vagrant plugins as a regular user:
  ```
    vagrant plugin install winrm
    vagrant plugin install winrm-elevated
    vagrant plugin install winrm-fs
    vagrant plugin install vagrant-vbguest
  ```

- Generate an RSA ssh key for the current user from the command line (skip
  if you already have one in `~/.ssh/id_rsa`):
  ```
    ssh-keygen # run with defaults
  ```

- Create a new folder for the VM
  ```
    mkdir win10-tst
    cd win10-tst
  ```

- Download scripts to set up the VM
  ```
    wget https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/r/setup.ps1
    wget https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/extra/vagrant-win10-tst/Vagrantfile
  ```

- Download the "MSEdge on Win10 (x64) Stable 1809" VM for platform "Vagrant" from
  [here](https://developer.microsoft.com/en-us/microsoft-edge/tools/vms) and
  prepare it for vagrant:
  ```
    mv ~/Downloads/MSEdge.Win10.Vagrant.zip .
    unzip MSEdge.Win10.Vagrant.zip
    mv "MSEdge - Win10.box" MSEdgeWin10.box
    vagrant box add win10-tst MSEdgeWin10.box
  ```
- Start vagrant to install the VM (automated, takes about 20 minutes):
  ```
    vagrant up
  ```

### Other systems

Similar installation instructions should work on other systems running on
64-bit Intel. The `Vagrantfile` script has hard-coded path for the user's
RSA key, which may need to be changed e.g. on Windows host. Also, after
small adaptations, this should work with other virtualization software than
VirtualBox (e.g. VMWare, Hyper-V, Parallels). A different Windows VM may
require bigger changes.

## Using the VM

### Logging in

One can log in to the VM from the console using SSH without password using

```
vagrant ssh
```

to get `cmd.exe` shell.

To get `bash`, run:

```
set MSYSTEM=MSYSTEM & "c:\msys64\usr\bin\bash.exe" --login -i
```

The SSH access is convenient for command line utilities and is enough to
install R, build R, install and build probably most R packages.  It also
allows to install the virtual machine on say a remote Linux server where one
can only connect via SSH without graphical interface.  But, the SSH
interface does not work for applications need graphical interface nor
applications that use the console in some special way.

For a full graphical interface, one may log in using RDP via

```
vagrant rdp -- /cert-ignore
```

that invokes an external RDP client. If such client is not available or does
not work, one can always log in directly via virtualbox: run `virtualbox`,
find the running virtual machine in the list, choose `Show`. The default VM
username is `IEUser` and password `Passw0rd!`.

It is also possible to use a regular ssh client on port 2222 and
regular/other RDP client on the default port of the host machine.

### Booting, shutting down, etc.

Like a real computer, the virtual machine has state saved on a (virtual)
hard-disk, so when suspended or shut down properly, the state is preserved
across reboots of the guest as well as the host machine.

* `vagrant halt # shuts down gracefully the machine`
* `vagrant up  # boots the machine up`
* `vagrant suspend`
* `vagrant resume`

In addition, one can save the machine state, export it, etc. Note that not
all operations technically possible are necessarily allowed by the license
terms under which Microsoft distributes the VM.

The directory with the Vagrant file (`win10-tst`) is accessible from the
guest VM as `C:\vagrant`, even in the SSH sessions.

### Installing and running R

To install the current R-devel patched for UCRT, get a bash prompt (already
assumed later on)

```
vagrant ssh
set MSYSTEM=MSYSTEM & "c:\msys64\usr\bin\bash.exe" --login -i
```

and run

```
wget -np -nd -r -l1 -A 'R-devel-win-[0-9]*.exe' https://www.r-project.org/nosvn/winutf8/ucrt3
./R-devel-win*.exe //VERYSILENT //SUPPRESSMSGBOXES
```

Now, run R via `/c/Program\ Files/R/R-devel/bin/R`. A sample
`sessionInfo()`:

```
> sessionInfo() 
R Under development (unstable) (2021-03-14 r80087) 
Platform: x86_64-w64-mingw32/x64 (64-bit)
Running under: Windows 10 x64 (build 17763)

Matrix products: default

locale:
[1] LC_COLLATE=English_United States.1252
[2] LC_CTYPE=English_United States.1252
[3] LC_MONETARY=English_United States.1252
[4] LC_NUMERIC=C
[5] LC_TIME=English_United States.1252

attached base packages: 
[1] stats     graphics  grDevices utils     datasets  methods   base

loaded via a namespace (and not attached):
[1] compiler_4.1.0
```

The VM is running Windows 10, but a version that is too old to have UTF-8 as
the current system encoding.  Hence, R is running with Latin-1 native
encoding.


## Installing packages (binary, not needing compilation)

In R, run e.g.

```
options(menu.graphics=FALSE)
install.packages("PKI")
```

The options change is needed, otherwise R will open a graphical windows
asking to choose a CRAN mirror, but that Window will not appear when logged
in via SSH.  A similar caveat is that one cannot use currently the R help
system when logged via SSH.

## Installing the toolchain

The compiler toolchain is needed to install from source packages which need
compilation.

```
wget -np -nd -r -l1 -A 'gcc10*.txz' https://www.r-project.org/nosvn/winutf8/ucrt3
tar xf gcc10*.txz

export PATH=`pwd`/x86_64-w64-mingw32.static.posix/bin:$PATH
export PATH=`pwd`/x86_64-w64-mingw32.static.posix/libexec/gcc/x86_64-w64-mingw32.static.posix/10.2.0:$PATH
export PATH=/c/Program\ Files/MiKTeX/miktex/bin/x64:$PATH
export TAR="/usr/bin/tar --force-local"
```

It makes sense to save the settings of environment variables to a file, say
named `e` and then include it via `. e` after logging in, when needed.

To check the paths are set correctly:

```
which cc1 gcc pdflatex
# /c/Users/IEUser/x86_64-w64-mingw32.static.posix/libexec/gcc/x86_64-w64-mingw32.static.posix/10.2.0/cc1
# /c/Users/IEUser/x86_64-w64-mingw32.static.posix/bin/gcc
# /c/Program Files/MiKTeX/miktex/bin/x64/pdflatex
```

## Installing packages that need compilation

With the environment variables from above, run e.g.

```
options(menu.graphics=FALSE)
install.packages("PKI", type="source")
```

## Building R from source

Download R, the patch for UCRT and Tcl/Tk bundle:

```
svn checkout https://svn.r-project.org/R/trunk
wget -np -nd -r -l1 -A 'R-devel-*.diff' https://www.r-project.org/nosvn/winutf8/ucrt3
wget https://www.r-project.org/nosvn/winutf8/ucrt3/Tcl.zip
```

Now to build it:

```
cd trunk
patch -p0 < ../R-devel-*.diff
unzip ../Tcl.zip

cd src/gnuwin32
cat <<EOF >MkRules.local
LOCAL_SOFT = `pwd`/../../../x86_64-w64-mingw32.static.posix
WIN = 64
BINPREF64 =
BINPREF =
USE_ICU = YES
ICU_LIBS = -lsicuin -lsicuuc \$(LOCAL_SOFT)/lib/sicudt.a -lstdc++
USE_LIBCURL = YES
CURL_LIBS = -lcurl -lzstd -lrtmp -lssl -lssh2 -lgcrypt -lcrypto -lgdi32 -lz -lws2_32 -lgdi32 -lcrypt32 -lidn2 -lunistring -liconv -lgpg-error -lwldap32 -lwinmm
USE_CAIRO = YES
CAIRO_LIBS = "-lcairo -lfontconfig -lfreetype -lpng -lpixman-1 -lexpat -lharfbuzz -lbz2 -lintl -lz -liconv -lgdi32 -lmsimg32"
CAIRO_CPPFLAGS = "-I\$(LOCAL_SOFT)/include/cairo"
TEXI2ANY = texi2any
MAKEINFO = texi2any
ISDIR = C:/Program Files (x86)/InnoSetup
EOF

make rsync-recommended
make all recommended 2>&1 | tee make.out
```

Then, one should be able to even build the R installer via `make
distribution`, but that does not work from the SSH session because of
MikTeX (even `texify --version` segfaults). It would work from a graphical
interactive session.

## Installing other command line tools

One may install additional command-line programs from Msys2. For instance
to get the VIM editor, run (VIM works even in SSH sessions):

```
pacman -S vim
```

Useful pacman commands:

* `pacman -Syu # upgrade packages`
* `pacman -Fy # install file index`
* `pacman -F unzip.exe # find package providing unzip.exe`
* `pacman -Q # list installed packages`
* `pacman -Sl # list available (even not installed) packages`

## Troubleshooting

If something goes wrong during installation of the machine, the initial
`vagrant up` invocation, one may restart the process in this order via
`vagrant up`, `vagrant up --provision`, `vagrant reload`.  The scripts are
written to re-use what is already installed in the machine.  Restarting the
provisioning in particular should help on a slow network connection, when
some of the scripts time out (tested on one machine with throttled network).

A radical step is to destroy the machine completely via `vagrant destroy`
and then re-try via `vagrant up`. This destroys everything installed into
the virtual machine, but the (original version of) the machine does not 

If that does not help, one might have to read the outputs and debug, or find
a way around it, e.g.  just use the machine via virtualbox GUI, which should
always work.  Also one may run some of the steps manually in the VM and then
re-start the provisioning.

## Technical details and limitations of the VM

The VM should only be run in a secure environment where adversary connection
even to the host machine is not possible, because access to the VM cannot be
regarded as secure: it has a default password and user, it disables NLA so
that older RDP servers can connect, it forwards ports from the host machine.
Note that by default, the guest machine can access the host file system as
well (the directory with the VM configuration), so as set up now it cannot
be regarded as a sandbox.

The scripts for automated installation are fragile to external software site
changes.  It is very likely that download locations and file names for say
MikTeX will stop working in the near future as it already happened recently,
but fixing that should not be hard.

In principle, there is also WinRM connection to the VM (`vagrant winrm`)
using which the provisioning is started, enabling SSH, enabling RDP,
installing files, etc.

The `Vagrantfile` can be customized so that it does not automatically
check/upgrade virtualbox guest additions on provisioning, to save
time/bandwidth on system when it turns out not important.

There is the 90-day limit of this free virtual machine. One may log into the
graphical interface and see detailed license information at the Windows
desktop background. It also says:

> "Create a snapshot (or keep a backup of downloaded archive) before first
> booting and working with this VM, so that you can reset quickly after the
> OS trial expires)."


## References

1. [Howto: UTF-8 as native encoding in R on Windows.](https://svn.r-project.org/R-dev-web/trunk/WindowsBuilds/winutf8/ucrt3/howto.html)
   Instructions for using the UCRT toolchain and R build on Windows.

2. [Windows/UTF-8 Toolchain and CRAN Package Checks.](https://developer.r-project.org/Blog/public/2021/03/12/windows/utf-8-toolchain-and-cran-package-checks/index.html)
   Blog post about the build and toolchain.