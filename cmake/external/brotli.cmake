include(ExternalProject)
include(utils)

add_custom_target(brotli)

set(BROTLI_PREFIX ${CMAKE_BINARY_DIR}/deps/brotli)
set(BROTLI_SOURCE ${BROTLI_PREFIX}/src/brotli)
set(BROTLI_BINARY ${BROTLI_SOURCE}-build)
set(BROTLI_INSTALL ${BROTLI_PREFIX}/install)
set(BROTLI_INCLUDE_DIR ${BROTLI_INSTALL}/include)
set(BROTLI_STATIC_LIBRARIES
  ${BROTLI_INSTALL}/lib/libbrotlienc-static.a
  ${BROTLI_INSTALL}/lib/libbrotlidec-static.a
  ${BROTLI_INSTALL}/lib/libbrotlicommon-static.a
)

CHECK_ALL_EXISTS(BROTLI_FOUND
  ${BROTLI_INCLUDE_DIR}
  ${BROTLI_STATIC_LIBRARIES}
)

if(NOT BROTLI_FOUND)
  set(BROTLI_URL https://github.com/google/brotli.git)
  set(BROTLI_TAG v1.0.7)
  ExternalProject_Add(brotli_external
      PREFIX "${BROTLI_PREFIX}"
      GIT_REPOSITORY "${BROTLI_URL}"
      GIT_TAG "${BROTLI_TAG}"
      DOWNLOAD_DIR "${BROTLI_PREFIX}"
      SOURCE_DIR "${BROTLI_SOURCE}"
      BINARY_DIR "${BROTLI_BINARY}"
      CMAKE_CACHE_ARGS
        -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
        -DCMAKE_INSTALL_PREFIX:PATH=${BROTLI_INSTALL}
        -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON
      BUILD_BYPRODUCTS
        ${BROTLI_STATIC_LIBRARIES}
  )

  add_dependencies(brotli brotli_external)
endif()
