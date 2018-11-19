
include(ExternalProject)
include(cmake/utils.cmake)

add_custom_target(nss)

set(NSS_PREFIX ${CMAKE_BINARY_DIR}/deps/nss)
set(NSS_DIST ${NSS_PREFIX}/src/dist)
set(NSS_SOURCE ${NSS_PREFIX}/src/nss)
set(NSPR_SOURCE ${NSS_PREFIX}/src/nspr)

if(CMAKE_BUILD_TYPE EQUAL Release)
  set(NSS_EXTRA_BUILDFLAGS -o)
  set(NSS_INCLUDE_DIRS
    ${NSS_DIST}/Release/include/nspr
    ${NSS_DIST}/public/nss
    ${NSS_DIST}/public/dbm
  )
  set(NSS_STATIC_LIBRARIES
    ${NSS_PREFIX}/src/nss/out/Release/libnss_static.a
    ${NSS_PREFIX}/src/nss/out/Release/libnssutil.a
    ${NSS_PREFIX}/src/nss/out/Release/libcertdb.a
    ${NSS_PREFIX}/src/nss/out/Release/libpk11wrap.a
    ${NSS_PREFIX}/src/nss/out/Release/libnsspki.a
    ${NSS_PREFIX}/src/nss/out/Release/libnssutil.a
    ${NSS_PREFIX}/src/nss/out/Release/libcryptohi.a
    ${NSS_PREFIX}/src/nss/out/Release/libnssdev.a
    ${NSS_PREFIX}/src/nss/out/Release/libcerthi.a
    ${NSS_PREFIX}/src/nss/out/Release/libnssb.a
    ${NSS_PREFIX}/src/dist/Release/lib/libnspr4.a
    ${NSS_PREFIX}/src/dist/Release/lib/libplc4.a
    ${NSS_PREFIX}/src/dist/Release/lib/libplds4.a
  )
else()
  set(NSS_EXTRA_BUILDFLAGS)
  set(NSS_INCLUDE_DIRS
    ${NSS_DIST}/Debug/include/nspr
    ${NSS_DIST}/public/nss
    ${NSS_DIST}/public/dbm
  )
  set(NSS_STATIC_LIBRARIES
    ${NSS_PREFIX}/src/nss/out/Debug/libnss_static.a
    ${NSS_PREFIX}/src/nss/out/Debug/libnssutil.a
    ${NSS_PREFIX}/src/nss/out/Debug/libcertdb.a
    ${NSS_PREFIX}/src/nss/out/Debug/libpk11wrap.a
    ${NSS_PREFIX}/src/nss/out/Debug/libnsspki.a
    ${NSS_PREFIX}/src/nss/out/Debug/libnssutil.a
    ${NSS_PREFIX}/src/nss/out/Debug/libcryptohi.a
    ${NSS_PREFIX}/src/nss/out/Debug/libnssdev.a
    ${NSS_PREFIX}/src/nss/out/Debug/libcerthi.a
    ${NSS_PREFIX}/src/nss/out/Debug/libnssb.a
    ${NSS_PREFIX}/src/dist/Debug/lib/libnspr4.a
    ${NSS_PREFIX}/src/dist/Debug/lib/libplc4.a
    ${NSS_PREFIX}/src/dist/Debug/lib/libplds4.a
  )
endif()

CHECK_ALL_EXISTS(NSS_FOUND ${NSS_STATIC_LIBRARIES} ${NSS_INCLUDE_DIRS})

if(NOT NSS_FOUND)
  set(NSPR_URL "https://hg.mozilla.org/projects/nspr")
  set(NSPR_TAG "NSPR_4_18_BRANCH")

  ExternalProject_Add(nspr_external
    HG_REPOSITORY "${NSPR_URL}"
    HG_TAG "${NSPR_TAG}"
    PREFIX "${NSS_PREFIX}"
    DOWNLOAD_DIR "${NSS_PREFIX}"
    SOURCE_DIR "${NSPR_SOURCE}"
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
  )

  set(NSS_URL "https://hg.mozilla.org/projects/nss")
  set(NSS_TAG "NSS_3_35_BRANCH")

  ExternalProject_Add(nss_external
    HG_REPOSITORY "${NSS_URL}"
    HG_TAG "${NSS_TAG}"
    PREFIX "${NSS_PREFIX}"
    DOWNLOAD_DIR "${NSS_PREFIX}"
    SOURCE_DIR "${NSS_SOURCE}"
    CONFIGURE_COMMAND ""
    BUILD_IN_SOURCE 1
    BUILD_COMMAND
      ${CMAKE_COMMAND} -E env
        CC=${CMAKE_C_COMPILER}
        CCC=${CMAKE_CXX_COMPILER}
        CXX=${CMAKE_CXX_COMPILER}
        USE_SYSTEM_ZLIB=1
        ZLIB_LIBS=${ZLIB_STATIC_LIBRARIES}
      ${NSS_SOURCE}/build.sh -v --disable-tests ${NSS_EXTRA_BUILDFLAGS}
    INSTALL_COMMAND ""
    DEPENDS
      zlib
      nspr_external
    BUILD_BYPRODUCTS ${NSS_STATIC_LIBRARIES}
  )

  add_dependencies(nss nss_external)
endif()
