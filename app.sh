CPPFLAGS="${CPPFLAGS} -I${DEST}/include"
CFLAGS="${CFLAGS:-} -ffunction-sections -fdata-sections"
LDFLAGS="${LDFLAGS:-} -L${DEPS}/lib -Wl,--gc-sections"

### LIBPOPT ###
_build_libpopt() {
local VERSION="1.16"
local FOLDER="popt-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="http://rpm5.org/files/popt/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
./configure --host="${HOST}" --prefix="${DEPS}" --disable-shared
make
make install
popd
}

### LIBUUID ###
_build_libuuid() {
local VERSION="1.42.13"
local FOLDER="e2fsprogs-libs-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="http://sourceforge.net/projects/e2fsprogs/files/e2fsprogs/v${VERSION}/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
./configure --host="${HOST}" --prefix="${DEPS}" \
  --disable-elf-shlibs --disable-quota
cd lib/uuid
make -j1
make install
popd
}

### LIBURCU ###
_build_liburcu() {
local VERSION="0.9.1"
local FOLDER="userspace-rcu-${VERSION}"
local FILE="${FOLDER}.tar.bz2"
local URL="http://www.lttng.org/files/urcu/${FILE}"

_download_bz2 "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
./configure --host="${HOST}" --prefix="${DEPS}" --disable-shared \
  LIBS="-lrt" \
  ac_cv_func_malloc_0_nonnull=yes \
  ac_cv_func_realloc_0_nonnull=yes
make
make install
popd
}

### LIBXML2 ###
_build_libxml2() {
local VERSION="2.9.3"
local FOLDER="libxml2-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="ftp://xmlsoft.org/libxml2/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
PATH=$DEPS/bin:$PATH \
  ./configure --host="${HOST}" --prefix="${DEPS}" --disable-shared \
    --without-iconv --without-icu --without-python --without-zlib
make
make install
popd
}

### LTTNG-UST ###
_build_lttng_ust() {
local VERSION="2.7.1"
local FOLDER="lttng-ust-${VERSION}"
local FILE="${FOLDER}.tar.bz2"
local URL="http://lttng.org/files/lttng-ust/${FILE}"

_download_bz2 "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
./configure --host="${HOST}" --prefix="${DEST}"
make
make install
popd
}

### LTTNG-TOOLS ###
_build_lttng_tools() {
local VERSION="2.7.1"
local FOLDER="lttng-tools-${VERSION}"
local FILE="${FOLDER}.tar.bz2"
local URL="http://lttng.org/files/lttng-tools/${FILE}"

_download_bz2 "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
PKG_CONFIG_PATH="${DEPS}/lib/pkgconfig:${DEST}/lib/pkgconfig" \
  ./configure --host="${HOST}" --prefix="${DEST}" --disable-shared \
    --with-xml-prefix="${DEPS}" --with-lttng-ust-prefix="${DEPS}"
make
make install
popd
}

### LTTNG-MODULES ###
_build_lttng_modules() {
local VERSION="2.7.1"
local FOLDER="lttng-modules-${VERSION}"
local FILE="${FOLDER}.tar.bz2"
local URL="http://lttng.org/files/lttng-modules/${FILE}"

export ARCH="arm"
export CROSS_COMPILE="${HOST}-"
export KERNELDIR="${KERNELDIR:-${HOME}/build/kernel-drobo64/kernel}"
export LDFLAGS=""

_download_bz2 "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
make KERNELDIR="${KERNELDIR}"
mkdir -p "${DEST}/modules" "${DEST}/modules/lib" "${DEST}/modules/probes"
find . -name "*.ko" | while read line; do
  cp -avf "${line}" "${DEST}/modules/${line}"
done
popd
}

_build() {
  _build_libpopt
  _build_libuuid
  _build_liburcu
  _build_libxml2
  _build_lttng_ust
  _build_lttng_tools
  _build_lttng_modules
  _package
}
