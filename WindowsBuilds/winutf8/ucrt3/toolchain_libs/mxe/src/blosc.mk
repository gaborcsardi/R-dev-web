PKG             := blosc
$(PKG)_WEBSITE  := https://github.com/Blosc
$(PKG)_DESCR    := Blosc
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.21.5
$(PKG)_CHECKSUM := 32e61961bbf81ffea6ff30e9d70fca36c86178afd3e3cfa13376adec8c687509
$(PKG)_GH_CONF  := Blosc/c-blosc/releases/tag,v
$(PKG)_SUBDIR   := c-$(PKG)-$($(PKG)_VERSION)
$(PKG)_DEPS     := cc lz4 zstd zlib

# part of patch from Msys2
define $(PKG)_BUILD
    $(SED) -i 's,^\(Requires:.*\),\1 liblz4 libzstd zlib,' '$(SOURCE_DIR)/blosc.pc.in'
    cd '$(BUILD_DIR)' && $(TARGET)-cmake '$(SOURCE_DIR)' \
            -DBUILD_SHARED=$(CMAKE_SHARED_BOOL) \
            -DBUILD_STATIC=$(CMAKE_STATIC_BOOL) \
            -DCMAKE_BUILD_TYPE="Release" \
            -DPREFER_EXTERNAL_LZ4=ON \
            -DPREFER_EXTERNAL_ZLIB=ON \
            -DPREFER_EXTERNAL_ZSTD=ON \
            -DBUILD_TESTS=OFF \
            -DBUILD_BENCHMARKS=OFF \
         '$(1)'

    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)' VERBOSE=1
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install VERBOSE=1

    # Build test script
    '$(TARGET)-gcc' \
        -W -Wall -Werror -ansi -pedantic \
        '$(PWD)/src/$(PKG)-test.c' -o '$(PREFIX)/$(TARGET)/bin/test-$(PKG).exe' \
        `'$(TARGET)-pkg-config' $(PKG) --cflags --libs`
endef
