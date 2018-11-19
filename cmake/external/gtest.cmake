include(ExternalProject)
include(cmake/utils.cmake)

add_custom_target(gtest)

set(GTEST_PREFIX ${CMAKE_BINARY_DIR}/deps/gtest)
set(GTEST_SOURCE ${GTEST_PREFIX}/src/gtest)
set(GTEST_BINARY ${GTEST_SOURCE})
set(GTEST_INCLUDE_DIR ${GTEST_SOURCE}/googletest/include)

if(WIN32)
  if(${CMAKE_GENERATOR} MATCHES "Visual Studio.*")
    set(GTEST_STATIC_LIBRARIES
      ${GTEST_BINARY}/googletest/$(Configuration)/gtest.lib)
  else()
    set(GTEST_STATIC_LIBRARIES
      ${GTEST_BINARY}/googletest/gtest.lib)
  endif()
else()
  set(GTEST_STATIC_LIBRARIES
    ${GTEST_BINARY}/googletest/libgtest.a)
endif()

CHECK_ALL_EXISTS(GTEST_FOUND
  ${GTEST_STATIC_LIBRARIES}
  "${GTEST_INCLUDE_DIR}/gtest"
  "${QUIC_EXTRA_INC_THIRD_PARTY_GTEST_DIR}/gtest"
)

message(STATUS "AAA ${GTEST_FOUND}")

if(NOT GTEST_FOUND)
  set(GTEST_URL https://github.com/google/googletest.git)
  set(GTEST_TAG ec44c6c1675c25b9827aacd08c02433cccde7780)

  ExternalProject_Add(gtest_external
      PREFIX "${GTEST_PREFIX}"
      GIT_REPOSITORY "${GTEST_URL}"
      GIT_TAG "${GTEST_TAG}"
      DOWNLOAD_DIR "${GTEST_PREFIX}"
      SOURCE_DIR "${GTEST_SOURCE}"
      BUILD_IN_SOURCE 1
      BUILD_BYPRODUCTS ${GTEST_STATIC_LIBRARIES}
      INSTALL_COMMAND ""
      CMAKE_CACHE_ARGS
          -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
          -DBUILD_GMOCK:BOOL=OFF
          -DBUILD_GTEST:BOOL=ON
          -Dgtest_force_shared_crt:BOOL=ON
  )

  ExternalProject_Add_Step(
    gtest_external CopyExtraHeaders
    COMMAND ${CMAKE_COMMAND} -E copy_directory
      "${GTEST_INCLUDE_DIR}/gtest"
      "${QUIC_EXTRA_INC_THIRD_PARTY_GTEST_DIR}/gtest"
    DEPENDEES
      build
  )

  add_dependencies(gtest gtest_external)
endif()
