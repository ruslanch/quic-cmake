project(quic_chromium_url)

set(CHROMIUM_URL_SOURCE_FILES
  url/third_party/mozilla/url_parse.cc
  url/url_canon_etc.cc
  url/url_canon_filesystemurl.cc
  url/url_canon_fileurl.cc
  url/url_canon_host.cc
  url/url_canon_internal.cc
  url/url_canon_ip.cc
  url/url_canon_mailtourl.cc
  url/url_canon_path.cc
  url/url_canon_pathurl.cc
  url/url_canon_query.cc
  url/url_canon_relative.cc
  url/url_canon_stdstring.cc
  url/url_canon_stdurl.cc
  url/url_constants.cc
  url/url_parse_file.cc
  url/url_util.cc
  url/gurl.cc
  url/origin.cc
  url/scheme_host_port.cc
  url/url_canon.cc
  url/url_idna_icu.cc
)

LIST_PREFIX(CHROMIUM_URL_SOURCE_FILES ${CHROMIUM_SOURCE_DIR} ${CHROMIUM_URL_SOURCE_FILES})

add_library(${PROJECT_NAME} SHARED
  ${CHROMIUM_URL_SOURCE_FILES}
)

target_link_libraries(${PROJECT_NAME}
  quic_chromium_base
  ${ICU_STATIC_LIBRARIES}
)

add_dependencies(${PROJECT_NAME}
  icu
)
