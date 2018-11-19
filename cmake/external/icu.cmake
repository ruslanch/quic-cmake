include(ExternalProject)
include(cmake/utils.cmake)

add_custom_target(icu)

set(ICU_PREFIX ${CMAKE_BINARY_DIR}/deps/icu)
set(ICU_SOURCE ${ICU_PREFIX}/src/icu)
set(ICU_BINARY ${ICU_SOURCE}-build)
set(ICU_INSTALL ${ICU_PREFIX}/install)
set(ICU_INCLUDE_DIR ${ICU_INSTALL}/include)
set(ICU_STATIC_LIBRARIES
  ${ICU_INSTALL}/lib/libicuuc.a
  ${ICU_INSTALL}/lib/libicuio.a
  ${ICU_INSTALL}/lib/libicui18n.a
  ${ICU_INSTALL}/lib/libicudata.a
)

CHECK_ALL_EXISTS(ICU_FOUND
  ${ICU_STATIC_LIBRARIES}
  ${ICU_INCLUDE_DIR}/unicode
  ${QUIC_EXTRA_INC_ICU_COMMON_DIR}/unicode
)

if(NOT ICU_FOUND)
  set(ICU_URL https://github.com/unicode-org/icu)
  set(ICU_TAG release-60-2)

  if(WIN32)
    set(ICU_BUILD_COMMAND "")
  else()
    set(ICU_CONFIGURE_COMMAND
      ${ICU_SOURCE}/icu4c/source/runConfigureICU ${CMAKE_SYSTEM_NAME}
        --disable-shared --enable-static --disable-dyload --disable-extras
        --disable-tools --disable-tests --disable-samples --disable-layoutex
        --prefix=${ICU_INSTALL}
    )
  endif()

  set(ICU_EXTRA_FLAGS "-fPIC -DUCHAR_TYPE=uint16_t")

  ExternalProject_Add(icu_external
    GIT_REPOSITORY "${ICU_URL}"
    GIT_TAG "${ICU_TAG}"
    PREFIX "${ICU_PREFIX}"
    DOWNLOAD_DIR "${ICU_PREFIX}"
    SOURCE_DIR "${ICU_SOURCE}"
    BINARY_DIR "${ICU_BINARY}"
    CONFIGURE_COMMAND
      ${CMAKE_COMMAND} -E env
        CC=${CMAKE_C_COMPILER}
        CXX=${CMAKE_CXX_COMPILER}
        CFLAGS=${ICU_EXTRA_FLAGS}
        CXXFLAGS=${ICU_EXTRA_FLAGS}
      sh ${ICU_CONFIGURE_COMMAND}
    BUILD_COMMAND
      make
    INSTALL_COMMAND
      make install
    BUILD_BYPRODUCTS
      ${ICU_STATIC_LIBRARIES}
  )

  ExternalProject_Add_Step(
    icu_external CopyExtraHeaders
    COMMAND ${CMAKE_COMMAND} -E copy_directory
      ${ICU_INCLUDE_DIR}/unicode
      ${QUIC_EXTRA_INC_ICU_COMMON_DIR}/unicode
    DEPENDEES
      install
  )

  add_dependencies(icu icu_external)
endif()
