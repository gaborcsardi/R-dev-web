# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := ilmbase
$(PKG)_WEBSITE  := https://www.openexr.com/
$(PKG)_DESCR    := IlmBase
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 2.2.1
$(PKG)_CHECKSUM := cac206e63be68136ef556c2b555df659f45098c159ce24804e9d5e9e0286609e
$(PKG)_SUBDIR   := ilmbase-$($(PKG)_VERSION)
$(PKG)_FILE     := ilmbase-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := https://download.savannah.nongnu.org/releases/openexr/$($(PKG)_FILE)
$(PKG)_DEPS     := cc

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://www.openexr.com/downloads.html' | \
    grep 'ilmbase-' | \
    $(SED) -n 's,.*/ilmbase-\([0-9][^>]*\)\.tar.*,\1,p' | \
    head -1
endef

define $(PKG)_BUILD
    cd '$(1)' && ./bootstrap
    # build the win32 thread sources instead of the posix thread sources
    $(SED) -i 's,IlmThreadPosix\.,IlmThreadWin32.,'                   '$(1)/IlmThread/Makefile.in'
    $(SED) -i 's,IlmThreadSemaphorePosix\.,IlmThreadSemaphoreWin32.,' '$(1)/IlmThread/Makefile.in'
    $(SED) -i 's,IlmThreadMutexPosix\.,IlmThreadMutexWin32.,'         '$(1)/IlmThread/Makefile.in'
    echo '/* disabled */' > '$(1)/IlmThread/IlmThreadSemaphorePosixCompat.cpp'
    # Because of the previous changes, '--disable-threading' will not disable
    # threading. It will just disable the unwanted check for pthread.
    cd '$(1)' && $(SHELL) ./configure \
        $(MXE_CONFIGURE_OPTS) \
        --disable-threading \
        CONFIG_SHELL=$(SHELL) \
        SHELL=$(SHELL) \
        CXXFLAGS='-Wno-register'
    # do the first build step by hand, because programs are built that
    # generate source files
    cd '$(1)/Half' && $(BUILD_CXX) eLut.cpp -o eLut
    '$(1)/Half/eLut' > '$(1)/eLut.h'
    cd '$(1)/Half' && $(BUILD_CXX) toFloat.cpp -o toFloat
    '$(1)/Half/toFloat' > '$(1)/toFloat.h'
    $(MAKE) -C '$(1)' -j '$(JOBS)' install bin_PROGRAMS= sbin_PROGRAMS= noinst_PROGRAMS=
endef
