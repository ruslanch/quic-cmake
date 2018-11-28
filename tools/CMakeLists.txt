project(quic_chromium_tools)

add_custom_command(
  OUTPUT ${QUIC_EXTRA_INC_DIR}/net/grit/net_resources.h
  COMMAND ${CMAKE_COMMAND} -E make_directory ${QUIC_EXTRA_INC_DIR}/net/grit
  COMMAND ${CHROMIUM_SOURCE_DIR}/tools/grit/grit.py
  ARGS
    -i ${CHROMIUM_SOURCE_DIR}/net/base/net_resources.grd
    build
    -o ${QUIC_EXTRA_INC_DIR}/net
    --depdir ${QUIC_EXTRA_INC_DIR}/net
    --depfile ${QUIC_EXTRA_INC_DIR}/net/grit/net_resources_stamp.d
    --write-only-new=1
    --depend-on-stamp
  DEPENDS
    ${CHROMIUM_SOURCE_DIR}/tools/grit/grit.py
    ${CHROMIUM_SOURCE_DIR}/net/base/net_resources.grd
)

include(AddFileDependencies)

add_file_dependencies(
  "${CHROMIUM_SOURCE_DIR}/net/base/directory_listing.cc"
  "${QUIC_EXTRA_INC_DIR}/net/grit/net_resources.h"
)

if(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
  set(CHROMIUM_NET_QUIC_SIMPLE_TOOLS_ARCH_SOURCE_FILES
    base/nix/mime_util_xdg.cc
    base/third_party/xdg_mime/xdgmimecache.c
    base/third_party/xdg_mime/xdgmimealias.c
    base/third_party/xdg_mime/xdgmimemagic.c
    base/third_party/xdg_mime/xdgmimeparent.c
    base/third_party/xdg_mime/xdgmimeglob.c
    base/third_party/xdg_mime/xdgmimeicon.c
    base/third_party/xdg_mime/xdgmimeint.c
    base/third_party/xdg_mime/xdgmime.c
    net/base/file_stream_context_posix.cc
    net/base/platform_mime_util_linux.cc
  )
  include_directories(${NSS_INCLUDE_DIRS})
elseif(${CMAKE_SYSTEM_NAME} MATCHES "Android")
  set(CHROMIUM_NET_QUIC_SIMPLE_TOOLS_ARCH_SOURCE_FILES)
elseif(${CMAKE_SYSTEM_NAME} MATCHES "FreeBSD")
  set(CHROMIUM_NET_QUIC_SIMPLE_TOOLS_ARCH_SOURCE_FILES)
elseif(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
  set(CHROMIUM_NET_QUIC_SIMPLE_TOOLS_ARCH_SOURCE_FILES)
elseif(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
  set(CHROMIUM_NET_QUIC_SIMPLE_TOOLS_ARCH_SOURCE_FILES
    net/base/file_stream_context_win.cc
    net/base/platform_mime_util_win.cc
  )
endif()

set(CHROMIUM_NET_QUIC_SIMPLE_TOOLS_SOURCE_FILES
  ${CHROMIUM_NET_QUIC_SIMPLE_TOOLS_ARCH_SOURCE_FILES}

  base/threading/simple_thread.cc
  base/i18n/char_iterator.cc
  base/i18n/file_util_icu.cc
  base/i18n/string_compare.cc
  base/i18n/time_formatting.cc
  net/base/data_url.cc
  net/base/directory_lister.cc
  net/base/directory_listing.cc
  net/base/file_stream.cc
  net/base/file_stream_context.cc
  net/base/filename_util.cc
  net/base/filename_util_internal.cc
  net/base/mime_util.cc
  net/base/net_module.cc
  net/base/network_delegate_impl.cc
  net/cert/ct_log_verifier.cc
  net/cert/ct_log_verifier_util.cc
  net/cert/ct_objects_extractor.cc
  net/cert/ct_policy_enforcer.cc
  net/cert/ct_sct_to_string.cc
  net/cert/ct_serialization.cc
  net/cert/ct_signed_certificate_timestamp_log_param.cc
  net/cert/multi_log_ct_verifier.cc
  net/cookies/cookie_change_dispatcher.cc
  net/cookies/cookie_monster.cc
  net/cookies/cookie_monster_change_dispatcher.cc
  net/cookies/cookie_monster_netlog_params.cc
  net/ftp/ftp_auth_cache.cc
  net/ftp/ftp_ctrl_response_buffer.cc
  net/ftp/ftp_network_layer.cc
  net/ftp/ftp_network_session.cc
  net/ftp/ftp_network_transaction.cc
  net/ftp/ftp_response_info.cc
  net/ftp/ftp_util.cc
  net/http/broken_alternative_services.cc
  net/http/http_content_disposition.cc
  net/http/http_server_properties_impl.cc
  net/http/transport_security_persister.cc
  net/url_request/data_protocol_handler.cc
  net/url_request/file_protocol_handler.cc
  net/url_request/ftp_protocol_handler.cc
  net/url_request/static_http_user_agent_settings.cc
  net/url_request/url_range_request_job.cc
  net/url_request/url_request_context_builder.cc
  net/url_request/url_request_context_storage.cc
  net/url_request/url_request_data_job.cc
  net/url_request/url_request_file_dir_job.cc
  net/url_request/url_request_file_job.cc
  net/url_request/url_request_ftp_job.cc
  net/url_request/url_request_intercepting_job_factory.cc
  net/url_request/url_request_job_factory.cc
  net/url_request/url_request_job_factory_impl.cc
  net/url_request/url_request_simple_job.cc
  net/socket/udp_server_socket.cc
  net/ssl/default_channel_id_store.cc
  net/ssl/ssl_config_service_defaults.cc
  net/third_party/quic/core/chlo_extractor.cc
  net/third_party/quic/core/http/quic_spdy_client_session.cc
  net/third_party/quic/core/http/quic_spdy_client_stream.cc
  net/third_party/quic/core/http/quic_spdy_server_stream_base.cc
  net/third_party/quic/core/quic_dispatcher.cc
  net/third_party/quic/core/quic_packet_writer_wrapper.cc
  net/third_party/quic/core/quic_time_wait_list_manager.cc
  net/third_party/quic/core/stateless_rejector.cc
  net/third_party/quic/tools/quic_backend_response.cc
  net/third_party/quic/tools/quic_client_base.cc
  net/third_party/quic/tools/quic_memory_cache_backend.cc
  net/third_party/quic/tools/quic_simple_client_session.cc
  net/third_party/quic/tools/quic_simple_client_stream.cc
  net/third_party/quic/tools/quic_simple_crypto_server_stream_helper.cc
  net/third_party/quic/tools/quic_simple_dispatcher.cc
  net/third_party/quic/tools/quic_simple_server_session.cc
  net/third_party/quic/tools/quic_simple_server_stream.cc
  net/third_party/quic/tools/quic_spdy_client_base.cc
  net/third_party/quic/tools/quic_url.cc
  net/tools/quic/quic_client_message_loop_network_helper.cc
  net/tools/quic/quic_http_proxy_backend.cc
  net/tools/quic/quic_http_proxy_backend_stream.cc
  net/tools/quic/quic_simple_client.cc
  net/tools/quic/quic_simple_per_connection_packet_writer.cc
  net/tools/quic/quic_simple_server.cc
  net/tools/quic/quic_simple_server_packet_writer.cc
  net/tools/quic/quic_simple_server_session_helper.cc
  net/tools/quic/synchronous_host_resolver.cc
)

LIST_PREFIX(CHROMIUM_NET_QUIC_SIMPLE_TOOLS_SOURCE_FILES ${CHROMIUM_SOURCE_DIR} ${CHROMIUM_NET_QUIC_SIMPLE_TOOLS_SOURCE_FILES})

add_library(quic_chromium_simple_tools SHARED
  ${CHROMIUM_NET_QUIC_SIMPLE_TOOLS_SOURCE_FILES}
)

target_link_libraries(quic_chromium_simple_tools
  quic_chromium_net
  ${ICU_STATIC_LIBRARIES}
)

add_executable(quic_simple_client
    ${CHROMIUM_SOURCE_DIR}/net/tools/quic/quic_simple_client_bin.cc
)

target_link_libraries(quic_simple_client
  quic_chromium_simple_tools
)


add_executable(quic_simple_server
  ${CHROMIUM_SOURCE_DIR}/net/tools/quic/quic_simple_server_bin.cc
)

target_link_libraries(quic_simple_server
  quic_chromium_simple_tools
)

set(CHROMIUM_NET_QUIC_EPOOL_TOOLS_SOURCE_FILES
  net/third_party/quic/core/quic_default_packet_writer.cc
  net/third_party/quic/core/quic_default_packet_writer.h
  net/third_party/quic/core/quic_epoll_alarm_factory.cc
  net/third_party/quic/core/quic_epoll_alarm_factory.h
  net/third_party/quic/core/quic_epoll_connection_helper.cc
  net/third_party/quic/core/quic_epoll_connection_helper.h
  net/third_party/quic/core/quic_packet_reader.cc
  net/third_party/quic/core/quic_packet_reader.h
  net/third_party/quic/platform/impl/batch_writer/quic_batch_writer_base.cc
  net/third_party/quic/platform/impl/batch_writer/quic_batch_writer_base.h
  net/third_party/quic/platform/impl/batch_writer/quic_batch_writer_buffer.cc
  net/third_party/quic/platform/impl/batch_writer/quic_batch_writer_buffer.h
  net/third_party/quic/platform/impl/batch_writer/quic_gso_batch_writer.cc
  net/third_party/quic/platform/impl/batch_writer/quic_gso_batch_writer.h
  net/third_party/quic/platform/impl/batch_writer/quic_sendmmsg_batch_writer.cc
  net/third_party/quic/platform/impl/batch_writer/quic_sendmmsg_batch_writer.h
  net/third_party/quic/platform/impl/quic_epoll_clock.cc
  net/third_party/quic/platform/impl/quic_epoll_clock.h
  net/third_party/quic/platform/impl/quic_linux_socket_utils.cc
  net/third_party/quic/platform/impl/quic_linux_socket_utils.h
  net/third_party/quic/platform/impl/quic_socket_utils.cc
  net/third_party/quic/platform/impl/quic_socket_utils.h
  net/third_party/quic/tools/quic_client.cc
  net/third_party/quic/tools/quic_client.h
  net/third_party/quic/tools/quic_client_epoll_network_helper.cc
  net/third_party/quic/tools/quic_client_epoll_network_helper.h
  net/third_party/quic/tools/quic_server.cc
  net/third_party/quic/tools/quic_server.h

  net/tools/epoll_server/epoll_server.cc
)

LIST_PREFIX(CHROMIUM_NET_QUIC_EPOOL_TOOLS_SOURCE_FILES ${CHROMIUM_SOURCE_DIR} ${CHROMIUM_NET_QUIC_EPOOL_TOOLS_SOURCE_FILES})

add_library(quic_chromium_epoll_tools SHARED
  ${CHROMIUM_NET_QUIC_EPOOL_TOOLS_SOURCE_FILES}
)

target_link_libraries(quic_chromium_epoll_tools
  quic_chromium_simple_tools
)

# target_link_libraries(quic_server
#   quic_chromium_base
#   quic_chromium_net