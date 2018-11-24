
include(ExternalProject)
include(cmake/utils.cmake)

add_custom_target(nss)

set(NSS_PREFIX ${CMAKE_BINARY_DIR}/deps/nss)
set(NSS_DIST ${NSS_PREFIX}/src/dist)
set(NSS_SOURCE ${NSS_PREFIX}/src/nss)
set(NSPR_SOURCE ${NSS_PREFIX}/src/nspr)

set(_NSS_STATIC_LIBRARIES
  libpk11wrap.a
  libnss_static.a
  libpk11wrap.a
  libcertdb.a
  libnsspki.a
  libnssutil.a
  libcryptohi.a
  libnssdev.a
  libcerthi.a
  libnssb.a
)

set(_NSPR_STATIC_LIBRARIES
  libplc4.a
  libplds4.a
  libnspr4.a
)

if(CMAKE_BUILD_TYPE EQUAL Release)
  set(NSS_EXTRA_BUILDFLAGS -o)
  set(NSS_INCLUDE_DIRS
    ${NSS_DIST}/Release/include/nspr
    ${NSS_DIST}/public/nss
    ${NSS_DIST}/public/dbm
  )

  LIST_PREFIX(_NSS_STATIC_LIBRARIES  "${NSS_PREFIX}/src/nss/out/Release"  ${_NSS_STATIC_LIBRARIES})
  LIST_PREFIX(_NSPR_STATIC_LIBRARIES "${NSS_PREFIX}/src/dist/Release/lib" ${_NSPR_STATIC_LIBRARIES})
else()
  set(NSS_EXTRA_BUILDFLAGS)
  set(NSS_INCLUDE_DIRS
    ${NSS_DIST}/Debug/include/nspr
    ${NSS_DIST}/public/nss
    ${NSS_DIST}/public/dbm
  )

  LIST_PREFIX(_NSS_STATIC_LIBRARIES  "${NSS_PREFIX}/src/nss/out/Debug"  ${_NSS_STATIC_LIBRARIES})
  LIST_PREFIX(_NSPR_STATIC_LIBRARIES "${NSS_PREFIX}/src/dist/Debug/lib" ${_NSPR_STATIC_LIBRARIES})
endif()

set(NSS_STATIC_LIBRARIES ${_NSS_STATIC_LIBRARIES} ${_NSPR_STATIC_LIBRARIES})

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
