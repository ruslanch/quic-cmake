include(ExternalProject)
include(utils)

add_custom_target(zlib)

set(ZLIB_PREFIX  ${CMAKE_BINARY_DIR}/deps/zlib)
set(ZLIB_SOURCE  ${ZLIB_PREFIX}/src/zlib)
set(ZLIB_INSTALL ${ZLIB_PREFIX}/install)
set(ZLIB_INCLUDE_DIR ${ZLIB_INSTALL}/include)

if(WIN32)
  if(${CMAKE_GENERATOR} MATCHES "Visual Studio.*")
      set(ZLIB_STATIC_LIBRARIES
          debug ${ZLIB_INSTALL}/lib/zlibstaticd.lib
          optimized ${ZLIB_INSTALL}/lib/zlibstatic.lib)
  else()
      if(CMAKE_BUILD_TYPE EQUAL Debug)
        set(ZLIB_STATIC_LIBRARIES ${ZLIB_INSTALL}/lib/zlibstaticd.lib)
      else()
        set(ZLIB_STATIC_LIBRARIES ${ZLIB_INSTALL}/lib/zlibstatic.lib)
      endif()
  endif()
else()
  set(ZLIB_STATIC_LIBRARIES ${ZLIB_INSTALL}/lib/libz.a)
endif()

CHECK_ALL_EXISTS(ZLIB_FOUND ${ZLIB_STATIC_LIBRARIES})

if(NOT ZLIB_FOUND)
  set(ZLIB_URL https://github.com/madler/zlib)
  set(ZLIB_TAG v1.2.11)

  ExternalProject_Add(zlib_external
      PREFIX "${ZLIB_PREFIX}"
      GIT_REPOSITORY "${ZLIB_URL}"
      GIT_TAG "${ZLIB_TAG}"
      DOWNLOAD_DIR "${ZLIB_PREFIX}"
      SOURCE_DIR "${ZLIB_SOURCE}"
      INSTALL_DIR "${ZLIB_INSTALL}"
      BUILD_IN_SOURCE 1
      BUILD_BYPRODUCTS ${ZLIB_STATIC_LIBRARIES}
      CMAKE_CACHE_ARGS
          -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON
          -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
          -DCMAKE_INSTALL_PREFIX:STRING=${ZLIB_INSTALL}
  )

  add_dependencies(zlib zlib_external)
endif()
