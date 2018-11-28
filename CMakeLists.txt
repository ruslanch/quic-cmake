cmake_minimum_required(VERSION 3.2)

project(quic-cmake)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

get_filename_component(CHROMIUM_SOURCE_DIR ${CHROMIUM_DIR} ABSOLUTE)

set(QUIC_EXTRA_INC_DIR ${CMAKE_BINARY_DIR}/extra)
set(QUIC_EXTRA_INC_THIRD_PARTY_GTEST_DIR ${QUIC_EXTRA_INC_DIR}/third_party/googletest/src/googletest/include)
set(QUIC_EXTRA_INC_THIRD_PARTY_BORINGSSL_DIR ${QUIC_EXTRA_INC_DIR}/third_party/boringssl/src/include)
set(QUIC_EXTRA_INC_ICU_COMMON_DIR  ${QUIC_EXTRA_INC_DIR}/third_party/icu/source/common)

find_package(Threads)

include(external/zlib)
include(external/boringssl)
include(external/gtest)
include(external/protobuf)
include(external/libevent)
include(external/brotli)
include(external/icu)

include_directories(${ZLIB_INCLUDE_DIR})
include_directories(${BORINGSSL_INCLUDE_DIR})
include_directories(${PROTOBUF_INCLUDE_DIR})
include_directories(${LIBEVENT_INCLUDE_DIRS})
include_directories(${BROTLI_INCLUDE_DIR})
include_directories(${ICU_INCLUDE_DIR})
include_directories(${QUIC_EXTRA_INC_DIR})
include_directories(${CHROMIUM_SOURCE_DIR})

add_definitions(
  -DUSE_OPENSSL
  -D__STDC_CONSTANT_MACROS
  -D__STDC_LIMIT_MACROS
  -DNO_TCMALLOC=1
  -DUCHAR_TYPE=uint16_t)

if(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
  add_definitions(-DUSE_NSS_CERTS=1)
  include(external/nss)
  include_directories(${NSS_INCLUDE_DIRS})
endif()

add_subdirectory(base)
add_subdirectory(crypto)
add_subdirectory(url)
add_subdirectory(net)
add_subdirectory(tools)
