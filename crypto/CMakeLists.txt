project(quic_chromium_crypto)

if(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
  set(CHROMIUM_CRYPTO_ARCH_SOURCE_FILES
    crypto/nss_util.cc
    crypto/nss_key_util.cc
  )
elseif(${CMAKE_SYSTEM_NAME} MATCHES "Android")
  set(CHROMIUM_CRYPTO_ARCH_SOURCE_FILES
    base/base_paths_android.cc
  )
elseif(${CMAKE_SYSTEM_NAME} MATCHES "FreeBSD")
  set(CHROMIUM_CRYPTO_ARCH_SOURCE_FILES)
elseif(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
  set(CHROMIUM_CRYPTO_ARCH_SOURCE_FILES)
elseif(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
  set(CHROMIUM_CRYPTO_ARCH_SOURCE_FILES)
endif()

set(CHROMIUM_CRYPTO_SOURCE_FILES
  ${CHROMIUM_CRYPTO_ARCH_SOURCE_FILES}

  crypto/ec_private_key.cc
  crypto/openssl_util.cc
  crypto/rsa_private_key.cc
  crypto/secure_hash.cc
  crypto/sha2.cc
  crypto/signature_verifier.cc
)

LIST_PREFIX(CHROMIUM_CRYPTO_SOURCE_FILES ${CHROMIUM_SOURCE_DIR} ${CHROMIUM_CRYPTO_SOURCE_FILES})

add_library(${PROJECT_NAME} SHARED
  ${CHROMIUM_CRYPTO_SOURCE_FILES}
)

# WARNING: ordering is very important
target_link_libraries(${PROJECT_NAME}
  quic_chromium_base
  ${BORINGSSL_STATIC_LIBRARIES}
  ${NSS_STATIC_LIBRARIES}
  ${CMAKE_DL_LIBS}
)
