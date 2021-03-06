include(ExternalProject)
include(utils)

add_custom_target(protobuf)

set(PROTOBUF_URL https://github.com/google/protobuf.git)
set(PROTOBUF_TAG v3.6.1)
set(PROTOBUF_PREFIX ${CMAKE_BINARY_DIR}/deps/protobuf)
set(PROTOBUF_SOURCE ${PROTOBUF_PREFIX}/src/protobuf)
set(PROTOBUF_BUILD  ${PROTOBUF_SOURCE})
set(PROTOBUF_INCLUDE_DIR ${PROTOBUF_BUILD}/src)

if(WIN32)
  if(${CMAKE_GENERATOR} MATCHES "Visual Studio.*")
    set(PROTOBUF_STATIC_LIBRARIES
      debug ${PROTOBUF_BUILD}/$(Configuration)/libprotobufd.lib
      optimized ${PROTOBUF_BUILD}/$(Configuration)/libprotobuf.lib)
    set(PROTOBUF_PROTOC_EXECUTABLE ${PROTOBUF_BUILD}/$(Configuration)/protoc.exe)
  else()
    if(CMAKE_BUILD_TYPE EQUAL Debug)
      set(PROTOBUF_STATIC_LIBRARIES ${PROTOBUF_BUILD}/libprotobufd.lib)
    else()
      set(PROTOBUF_STATIC_LIBRARIES ${PROTOBUF_BUILD}/libprotobuf.lib)
    endif()
    set(PROTOBUF_PROTOC_EXECUTABLE ${PROTOBUF_BUILD}/protoc.exe)
  endif()

  set(PROTOBUF_GENERATOR_PLATFORM)
  if (CMAKE_GENERATOR_PLATFORM)
    set(PROTOBUF_GENERATOR_PLATFORM -A ${CMAKE_GENERATOR_PLATFORM})
  endif()
  set(PROTOBUF_GENERATOR_TOOLSET)
  if (CMAKE_GENERATOR_TOOLSET)
    set(PROTOBUF_GENERATOR_TOOLSET -T ${CMAKE_GENERATOR_TOOLSET})
  endif()
  set(PROTOBUF_ADDITIONAL_CMAKE_OPTIONS	-Dprotobuf_MSVC_STATIC_RUNTIME:BOOL=OFF
    -G${CMAKE_GENERATOR} ${PROTOBUF_GENERATOR_PLATFORM} ${PROTOBUF_GENERATOR_TOOLSET})
else()
  set(PROTOBUF_STATIC_LIBRARIES  ${PROTOBUF_BUILD}/libprotobuf.a)
  set(PROTOBUF_PROTOC_EXECUTABLE ${PROTOBUF_BUILD}/protoc)
endif()

CHECK_ALL_EXISTS(PROTOBUF_FOUND ${PROTOBUF_STATIC_LIBRARIES} ${PROTOBUF_PROTOC_EXECUTABLE})

if(NOT PROTOBUF_FOUND)
  ExternalProject_Add(protobuf_external
      PREFIX "${PROTOBUF_PREFIX}"
      GIT_REPOSITORY "${PROTOBUF_URL}"
      GIT_TAG "${PROTOBUF_TAG}"
      DOWNLOAD_DIR "${PROTOBUF_PREFIX}"
      BUILD_IN_SOURCE 1
      BUILD_BYPRODUCTS ${PROTOBUF_PROTOC_EXECUTABLE} ${PROTOBUF_STATIC_LIBRARIES}
      SOURCE_DIR "${PROTOBUF_SOURCE}"
      CONFIGURE_COMMAND ${CMAKE_COMMAND} cmake/
          -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON
          -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
          -DCMAKE_VERBOSE_MAKEFILE:BOOL=OFF
          -DZLIB_ROOT:PATH=${ZLIB_INSTALL}
          -DZLIB_LIBRARY:PATH=${ZLIB_STATIC_LIBRARIES}
          -DZLIB_INCLUDE_DIR:PATH=${ZLIB_INCLUDE_DIR}
          -Dprotobuf_BUILD_TESTS:BOOL=OFF
          ${PROTOBUF_ADDITIONAL_CMAKE_OPTIONS}
      CMAKE_CACHE_ARGS
          -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON
          -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
          -DCMAKE_VERBOSE_MAKEFILE:BOOL=OFF
          -DZLIB_ROOT:PATH=${ZLIB_INSTALL}
          -DZLIB_LIBRARY:PATH=${ZLIB_STATIC_LIBRARIES}
          -DZLIB_INCLUDE_DIR:PATH=${ZLIB_INCLUDE_DIR}
          -Dprotobuf_BUILD_TESTS:BOOL=OFF
          -Dprotobuf_MSVC_STATIC_RUNTIME:BOOL=OFF
      INSTALL_COMMAND ""
      DEPENDS
        zlib
  )

  add_dependencies(protobuf protobuf_external)
endif()
