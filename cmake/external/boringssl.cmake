include(ExternalProject)
include(cmake/utils.cmake)

add_custom_target(boringssl)

set(BORINGSSL_PREFIX ${CMAKE_BINARY_DIR}/deps/boringssl)
set(BORINGSSL_SOURCE ${BORINGSSL_PREFIX}/src/boringssl)
set(BORINGSSL_BINARY ${BORINGSSL_SOURCE}-build)

set(BORINGSSL_INCLUDE_DIR ${BORINGSSL_SOURCE}/include)
set(BORINGSSL_STATIC_LIBRARIES
  ${BORINGSSL_BINARY}/ssl/libssl.a
  ${BORINGSSL_BINARY}/crypto/libcrypto.a
  ${BORINGSSL_BINARY}/decrepit/libdecrepit.a
)

CHECK_ALL_EXISTS(BORINGSSL_FOUND
  ${BORINGSSL_STATIC_LIBRARIES}
  "${BORINGSSL_INCLUDE_DIR}/openssl"
  "${QUIC_EXTRA_INC_THIRD_PARTY_BORINGSSL_DIR}/openssl"
)

if(NOT BORINGSSL_FOUND)
  set(BORINGSSL_URL https://boringssl.googlesource.com/boringssl)
  set(BORINGSSL_TAG 702e2b6d3831486535e958f262a05c75a5cb312e)

  ExternalProject_Add(boringssl_external
      PREFIX "${BORINGSSL_PREFIX}"
      GIT_REPOSITORY "${BORINGSSL_URL}"
      GIT_TAG "${BORINGSSL_TAG}"
      DOWNLOAD_DIR "${BORINGSSL_PREFIX}"
      SOURCE_DIR "${BORINGSSL_SOURCE}"
      BINARY_DIR "${BORINGSSL_BINARY}"
      # BUILD_IN_SOURCE 1
      BUILD_BYPRODUCTS ${BORINGSSL_STATIC_LIBRARIES}
      INSTALL_COMMAND ""
      CMAKE_CACHE_ARGS
          -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON
          -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
          -DCMAKE_VERBOSE_MAKEFILE:BOOL=OFF
          -DBUILD_SHARED_LIBS:BOOL=OFF
  )

  ExternalProject_Add_Step(
    boringssl_external CopyExtraHeaders
    COMMAND ${CMAKE_COMMAND} -E copy_directory
      "${BORINGSSL_INCLUDE_DIR}/openssl"
      "${QUIC_EXTRA_INC_THIRD_PARTY_BORINGSSL_DIR}/openssl"
    DEPENDEES
      build
  )

  add_dependencies(boringssl boringssl_external)
endif()
