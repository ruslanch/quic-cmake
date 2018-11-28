project(quic_chromium_net)

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/net_buildflags.h.inc
  ${QUIC_EXTRA_INC_DIR}/net/net_buildflags.h COPYONLY)

set(QUIC_CORE_PROTO_SOURCE_FILES
  net/third_party/quic/core/proto/cached_network_parameters.proto
  net/third_party/quic/core/proto/source_address_token.proto
  net/third_party/quic/core/proto/crypto_server_config.proto
  net/nqe/proto/network_id_proto.proto
)

foreach(_SRC_FILE ${QUIC_CORE_PROTO_SOURCE_FILES})
  get_filename_component(_SRC_FILE_FULL_PATH ${CHROMIUM_SOURCE_DIR}/${_SRC_FILE} ABSOLUTE)
  get_filename_component(_SRC_FILE_FULL_DIR_PATH ${_SRC_FILE_FULL_PATH} PATH)
  get_filename_component(_SRC_FILE_NAME_WE ${_SRC_FILE} NAME_WE)
  get_filename_component(_SRC_FILE_DIR ${_SRC_FILE} DIRECTORY)

  set(_GEN_OUT_DIR ${QUIC_EXTRA_INC_DIR}/${_SRC_FILE_DIR})

  list(APPEND QUIC_CORE_PROTO_RESULTS "${_GEN_OUT_DIR}/${_SRC_FILE_NAME_WE}.pb.cc")
  list(APPEND QUIC_CORE_PROTO_RESULTS "${_GEN_OUT_DIR}/${_SRC_FILE_NAME_WE}.pb.h")

  add_custom_command(
    OUTPUT
    "${_GEN_OUT_DIR}/${_SRC_FILE_NAME_WE}.pb.cc"
    "${_GEN_OUT_DIR}/${_SRC_FILE_NAME_WE}.pb.h"
    COMMAND ${CMAKE_COMMAND} -E make_directory ${_GEN_OUT_DIR}
    COMMAND  ${PROTOBUF_PROTOC_EXECUTABLE}
    ARGS --cpp_out ${_GEN_OUT_DIR} -I${_SRC_FILE_FULL_DIR_PATH} ${_SRC_FILE_FULL_PATH}
    DEPENDS ${_SRC_FILE_FULL_PATH} ${PROTOBUF_PROTOC_EXECUTABLE}
    VERBATIM
  )
endforeach()

add_custom_command(
  OUTPUT "${QUIC_EXTRA_INC_DIR}/net/base/registry_controlled_domains/effective_tld_names-inc.cc"
  COMMAND ${CMAKE_COMMAND} -E make_directory "${QUIC_EXTRA_INC_DIR}/net/base/registry_controlled_domains"
  COMMAND ${CHROMIUM_SOURCE_DIR}/net/tools/dafsa/make_dafsa.py
  ARGS
    "${CHROMIUM_SOURCE_DIR}/net/base/registry_controlled_domains/effective_tld_names.gperf"
    "${QUIC_EXTRA_INC_DIR}/net/base/registry_controlled_domains/effective_tld_names-inc.cc"
  DEPENDS
    ${CHROMIUM_SOURCE_DIR}/net/tools/dafsa/make_dafsa.py
    "${CHROMIUM_SOURCE_DIR}/net/base/registry_controlled_domains/effective_tld_names.gperf"
)

include(AddFileDependencies)

add_file_dependencies(
  "${CHROMIUM_SOURCE_DIR}/net/base/registry_controlled_domains/registry_controlled_domain.cc"
  "${QUIC_EXTRA_INC_DIR}/net/base/registry_controlled_domains/effective_tld_names-inc.cc"
)

if(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
  set(CHROMIUM_NET_ARCH_SOURCE_FILES
    net/base/address_tracker_linux.cc
    net/base/net_errors_posix.cc
    net/base/network_change_notifier_linux.cc
    net/base/network_interfaces_linux.cc
    net/base/network_interfaces_posix.cc

    net/cert/cert_verify_proc_nss.cc
    net/cert/internal/trust_store_nss.cc
    net/cert/known_roots_nss.cc
    net/cert/x509_util_nss.cc

    net/cert_net/nss_ocsp.cc

    net/disk_cache/blockfile/file_posix.cc
    net/disk_cache/blockfile/mapped_file_posix.cc
    net/disk_cache/cache_util_posix.cc
    net/disk_cache/simple/simple_index_file_posix.cc
    net/disk_cache/simple/simple_util_posix.cc

    net/dns/dns_config_service_posix.cc

    net/proxy_resolution/proxy_config_service_linux.cc

    net/socket/socket_posix.cc
    net/socket/tcp_socket_posix.cc
    net/socket/udp_socket_posix.cc

    net/http/http_auth_handler_ntlm_portable.cc
  )
  include_directories(${NSS_INCLUDE_DIRS})
elseif(${CMAKE_SYSTEM_NAME} MATCHES "Android")
  set(CHROMIUM_NET_ARCH_SOURCE_FILES
    base/base_paths_android.cc
  )
elseif(${CMAKE_SYSTEM_NAME} MATCHES "FreeBSD")
  set(CHROMIUM_NET_ARCH_SOURCE_FILES)
elseif(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
  set(CHROMIUM_NET_ARCH_SOURCE_FILES)
elseif(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
  set(CHROMIUM_NET_ARCH_SOURCE_FILES
    net/base/net_errors_win.cc
    net/base/network_interfaces_win.cc
    net/cert/known_roots_win.cc
    net/disk_cache/blockfile/file_win.cc
    net/disk_cache/blockfile/mapped_file_win.cc
    net/disk_cache/simple/simple_index_file_win.cc
    net/disk_cache/simple/simple_util_win.cc
    net/dns/dns_config_service_win.cc
    net/http/http_auth_handler_ntlm_win.cc
  )
endif()

set(CHROMIUM_NET_SOURCE_FILES
  ${CHROMIUM_NET_ARCH_SOURCE_FILES}

  net/base/address_family.cc
  net/base/address_list.cc
  net/base/arena.cc
  net/base/auth.cc
  net/base/backoff_entry.cc
  net/base/datagram_buffer.cc
  net/base/elements_upload_data_stream.cc
  net/base/escape.cc
  net/base/features.cc
  net/base/hash_value.cc
  net/base/hex_utils.cc
  net/base/host_mapping_rules.cc
  net/base/host_port_pair.cc
  net/base/io_buffer.cc
  net/base/ip_address.cc
  net/base/ip_endpoint.cc
  net/base/load_timing_info.cc
  net/base/lookup_string_in_fixed_set.cc
  net/base/net_errors.cc
  net/base/net_string_util_icu.cc
  net/base/network_activity_monitor.cc
  net/base/network_change_notifier.cc
  net/base/network_delegate.cc
  net/base/network_interfaces.cc
  net/base/parse_number.cc
  net/base/port_util.cc
  net/base/prioritized_dispatcher.cc
  net/base/prioritized_task_runner.cc
  net/base/proxy_server.cc
  net/base/request_priority.cc
  net/base/sockaddr_storage.cc
  # net/base/trace_constants.cc
  net/base/upload_bytes_element_reader.cc
  net/base/upload_data_stream.cc
  net/base/upload_element_reader.cc
  net/base/url_util.cc

  net/base/registry_controlled_domains/registry_controlled_domain.cc

  net/cert/asn1_util.cc
  net/cert/caching_cert_verifier.cc
  net/cert/cert_database.cc
  net/cert/cert_status_flags.cc
  net/cert/cert_verifier.cc
  net/cert/cert_verify_proc.cc
  net/cert/cert_verify_result.cc
  net/cert/crl_set.cc
  net/cert/ct_verify_result.cc
  net/cert/ev_root_ca_metadata.cc
  net/cert/internal/cert_error_id.cc
  net/cert/internal/cert_error_params.cc
  net/cert/internal/cert_errors.cc
  net/cert/internal/certificate_policies.cc
  net/cert/internal/common_cert_errors.cc
  net/cert/internal/extended_key_usage.cc
  net/cert/internal/general_names.cc
  net/cert/internal/name_constraints.cc
  net/cert/internal/ocsp.cc
  net/cert/internal/parse_certificate.cc
  net/cert/internal/parse_name.cc
  net/cert/internal/parsed_certificate.cc
  net/cert/internal/signature_algorithm.cc
  net/cert/internal/system_trust_store.cc
  net/cert/internal/trust_store.cc
  net/cert/internal/trust_store.cc
  net/cert/internal/trust_store_collection.cc
  net/cert/internal/trust_store_in_memory.cc
  net/cert/internal/verify_name_match.cc
  net/cert/internal/verify_signed_data.cc
  net/cert/known_roots.cc
  net/cert/multi_threaded_cert_verifier.cc
  net/cert/ocsp_verify_result.cc
  net/cert/pem_tokenizer.cc
  net/cert/signed_certificate_timestamp.cc
  net/cert/signed_certificate_timestamp_and_status.cc
  net/cert/symantec_certs.cc
  net/cert/x509_cert_types.cc
  net/cert/x509_certificate.cc
  net/cert/x509_certificate_net_log_param.cc
  net/cert/x509_util.cc

  net/cookies/canonical_cookie.cc
  net/cookies/cookie_constants.cc
  net/cookies/cookie_deletion_info.cc
  net/cookies/cookie_options.cc
  net/cookies/cookie_store.cc
  net/cookies/cookie_util.cc
  net/cookies/parsed_cookie.cc

  net/der/encode_values.cc
  net/der/input.cc
  net/der/parse_values.cc
  net/der/parser.cc
  net/der/tag.cc

  net/disk_cache/backend_cleanup_tracker.cc
  net/disk_cache/blockfile/addr.cc
  net/disk_cache/blockfile/backend_impl.cc
  net/disk_cache/blockfile/bitmap.cc
  net/disk_cache/blockfile/block_files.cc
  net/disk_cache/blockfile/disk_format.cc
  net/disk_cache/blockfile/entry_impl.cc
  net/disk_cache/blockfile/eviction.cc
  net/disk_cache/blockfile/file.cc
  net/disk_cache/blockfile/file_lock.cc
  net/disk_cache/blockfile/in_flight_backend_io.cc
  net/disk_cache/blockfile/in_flight_io.cc
  net/disk_cache/blockfile/mapped_file.cc
  net/disk_cache/blockfile/rankings.cc
  net/disk_cache/blockfile/sparse_control.cc
  net/disk_cache/blockfile/stats.cc
  net/disk_cache/blockfile/trace.cc
  net/disk_cache/blockfile/webfonts_histogram.cc
  net/disk_cache/cache_util.cc
  net/disk_cache/disk_cache.cc
  net/disk_cache/memory/mem_backend_impl.cc
  net/disk_cache/memory/mem_entry_impl.cc
  net/disk_cache/net_log_parameters.cc
  net/disk_cache/simple/simple_backend_impl.cc
  net/disk_cache/simple/simple_entry_format.cc
  net/disk_cache/simple/simple_entry_impl.cc
  net/disk_cache/simple/simple_entry_operation.cc
  net/disk_cache/simple/simple_file_tracker.cc
  net/disk_cache/simple/simple_index.cc
  net/disk_cache/simple/simple_index_file.cc
  net/disk_cache/simple/simple_net_log_parameters.cc
  net/disk_cache/simple/simple_synchronous_entry.cc
  net/disk_cache/simple/simple_util.cc
  net/disk_cache/simple/simple_version_upgrade.cc

  net/dns/dns_config.cc
  net/dns/dns_config_overrides.cc
  net/dns/dns_config_service.cc
  net/dns/dns_hosts.cc
  net/dns/dns_query.cc
  net/dns/dns_reloader.cc
  net/dns/dns_response.cc
  net/dns/dns_util.cc
  net/dns/host_cache.cc
  net/dns/host_resolver.cc
  net/dns/host_resolver_impl.cc
  net/dns/host_resolver_mdns_task.cc
  net/dns/host_resolver_proc.cc
  net/dns/record_rdata.cc
  net/dns/serial_worker.cc
  net/dns/public/dns_query_type.cc

  net/extras/preload_data/decoder.cc

  net/filter/brotli_source_stream.cc
  net/filter/filter_source_stream.cc
  net/filter/gzip_header.cc
  net/filter/gzip_source_stream.cc
  net/filter/source_stream.cc

  net/http/bidirectional_stream.cc
  net/http/bidirectional_stream_impl.cc
  net/http/bidirectional_stream_request_info.cc
  net/http/http_auth.cc
  net/http/http_auth_cache.cc
  net/http/http_auth_challenge_tokenizer.cc
  net/http/http_auth_controller.cc
  net/http/http_auth_handler.cc
  net/http/http_auth_handler_basic.cc
  net/http/http_auth_handler_digest.cc
  net/http/http_auth_handler_factory.cc
  net/http/http_auth_handler_ntlm.cc
  net/http/http_auth_scheme.cc
  net/http/http_basic_state.cc
  net/http/http_basic_stream.cc
  net/http/http_byte_range.cc
  net/http/http_cache.cc
  net/http/http_cache_lookup_manager.cc
  net/http/http_cache_transaction.cc
  net/http/http_cache_writers.cc
  net/http/http_chunked_decoder.cc
  net/http/http_log_util.cc
  net/http/http_network_layer.cc
  net/http/http_network_session.cc
  net/http/http_network_transaction.cc
  net/http/http_proxy_client_socket.cc
  net/http/http_proxy_client_socket_pool.cc
  net/http/http_proxy_client_socket_wrapper.cc
  net/http/http_proxy_client_socket_wrapper.cc
  net/http/http_raw_request_headers.cc
  net/http/http_request_headers.cc
  net/http/http_request_info.cc
  net/http/http_response_body_drainer.cc
  net/http/http_response_headers.cc
  net/http/http_response_info.cc
  net/http/http_security_headers.cc
  net/http/http_server_properties.cc
  net/http/http_stream_factory.cc
  net/http/http_stream_factory_job.cc
  net/http/http_stream_factory_job_controller.cc
  net/http/http_stream_parser.cc
  net/http/http_stream_request.cc
  net/http/http_util.cc
  net/http/http_vary_data.cc
  net/http/partial_data.cc
  net/http/proxy_client_socket.cc
  net/http/proxy_connect_redirect_http_stream.cc
  net/http/proxy_fallback.cc
  net/http/transport_security_state.cc
  net/http/transport_security_state_source.cc

  net/log/net_log.cc
  net/log/net_log_capture_mode.cc
  net/log/net_log_entry.cc
  net/log/net_log_source.cc
  net/log/net_log_with_source.cc

  net/nqe/cached_network_quality.cc
  net/nqe/effective_connection_type.cc
  net/nqe/event_creator.cc
  net/nqe/network_id.cc
  net/nqe/network_quality.cc
  net/nqe/network_quality_estimator.cc
  net/nqe/network_quality_estimator_params.cc
  net/nqe/network_quality_estimator_util.cc
  net/nqe/network_quality_observation.cc
  net/nqe/network_quality_observation_source.cc
  net/nqe/network_quality_store.cc
  net/nqe/observation_buffer.cc
  net/nqe/socket_watcher.cc
  net/nqe/socket_watcher_factory.cc
  net/nqe/throughput_analyzer.cc

  net/ntlm/ntlm.cc
  net/ntlm/ntlm_buffer_reader.cc
  net/ntlm/ntlm_buffer_writer.cc
  net/ntlm/ntlm_client.cc
  net/ntlm/ntlm_constants.cc

  net/proxy_resolution/multi_threaded_proxy_resolver.cc
  net/proxy_resolution/pac_file_data.cc
  net/proxy_resolution/pac_file_decider.cc
  net/proxy_resolution/proxy_bypass_rules.cc
  net/proxy_resolution/proxy_config.cc
  net/proxy_resolution/proxy_config_service_fixed.cc
  net/proxy_resolution/proxy_config_with_annotation.cc
  net/proxy_resolution/proxy_info.cc
  net/proxy_resolution/proxy_list.cc
  net/proxy_resolution/proxy_resolution_service.cc
  net/proxy_resolution/proxy_resolver_factory.cc

  net/socket/client_socket_factory.cc
  net/socket/client_socket_handle.cc
  net/socket/client_socket_pool.cc
  net/socket/client_socket_pool_base.cc
  net/socket/client_socket_pool_manager.cc
  net/socket/client_socket_pool_manager_impl.cc
  net/socket/next_proto.cc
  net/socket/socket.cc
  net/socket/socket_bio_adapter.cc
  net/socket/socket_descriptor.cc
  net/socket/socket_net_log_params.cc
  net/socket/socket_options.cc
  net/socket/socket_tag.cc
  net/socket/socks5_client_socket.cc
  net/socket/socks_client_socket.cc
  net/socket/socks_client_socket_pool.cc
  net/socket/ssl_client_socket.cc
  net/socket/ssl_client_socket_impl.cc
  net/socket/ssl_client_socket_pool.cc
  net/socket/stream_socket.cc
  net/socket/tcp_client_socket.cc
  net/socket/transport_client_socket.cc
  net/socket/transport_client_socket_pool.cc
  net/socket/udp_client_socket.cc
  net/socket/udp_net_log_parameters.cc
  net/socket/websocket_endpoint_lock_manager.cc
  net/socket/websocket_transport_client_socket_pool.cc
  net/socket/websocket_transport_connect_sub_job.cc

  net/spdy/bidirectional_stream_spdy_impl.cc
  net/spdy/buffered_spdy_framer.cc
  net/spdy/header_coalescer.cc
  net/spdy/http2_priority_dependencies.cc
  net/spdy/http2_push_promise_index.cc
  net/spdy/multiplexed_http_stream.cc
  net/spdy/multiplexed_session.cc
  net/spdy/spdy_buffer.cc
  net/spdy/spdy_buffer_producer.cc
  net/spdy/spdy_http_stream.cc
  net/spdy/spdy_http_utils.cc
  net/spdy/spdy_log_util.cc
  net/spdy/spdy_proxy_client_socket.cc
  net/spdy/spdy_read_queue.cc
  net/spdy/spdy_session.cc
  net/spdy/spdy_session_key.cc
  net/spdy/spdy_session_pool.cc
  net/spdy/spdy_stream.cc
  net/spdy/spdy_write_queue.cc

  net/ssl/channel_id_service.cc
  net/ssl/channel_id_store.cc
  net/ssl/openssl_ssl_util.cc
  net/ssl/ssl_cert_request_info.cc
  net/ssl/ssl_cipher_suite_names.cc
  net/ssl/ssl_client_auth_cache.cc
  net/ssl/ssl_client_session_cache.cc
  net/ssl/ssl_config.cc
  net/ssl/ssl_config_service.cc
  net/ssl/ssl_info.cc

  net/quic/bidirectional_stream_quic_impl.cc
  net/quic/crypto/proof_source_chromium.cc
  net/quic/crypto/proof_verifier_chromium.cc
  net/quic/network_connection.cc
  net/quic/properties_based_quic_server_info.cc
  net/quic/quic_address_mismatch.cc
  net/quic/quic_chromium_alarm_factory.cc
  net/quic/quic_chromium_client_session.cc
  net/quic/quic_chromium_client_stream.cc
  net/quic/quic_chromium_connection_helper.cc
  net/quic/quic_chromium_packet_reader.cc
  net/quic/quic_chromium_packet_writer.cc
  net/quic/quic_clock_skew_detector.cc
  net/quic/quic_connection_logger.cc
  net/quic/quic_connectivity_probing_manager.cc
  net/quic/quic_crypto_client_stream_factory.cc
  net/quic/quic_http_stream.cc
  net/quic/quic_http_utils.cc
  net/quic/quic_proxy_client_socket.cc
  net/quic/quic_server_info.cc
  net/quic/quic_session_key.cc
  net/quic/quic_stream_factory.cc
  net/quic/quic_utils_chromium.cc

  net/url_request/redirect_info.cc
  net/url_request/redirect_util.cc
  net/url_request/url_request.cc
  net/url_request/url_request_context.cc
  net/url_request/url_request_error_job.cc
  net/url_request/url_request_http_job.cc
  net/url_request/url_request_job.cc
  net/url_request/url_request_job_manager.cc
  net/url_request/url_request_netlog_params.cc
  net/url_request/url_request_redirect_job.cc
  net/url_request/url_request_status.cc
  net/url_request/url_request_throttler_entry.cc
  net/url_request/url_request_throttler_manager.cc
  net/url_request/websocket_handshake_userdata_key.cc

  net/third_party/http2/decoder/decode_buffer.cc
  net/third_party/http2/decoder/decode_http2_structures.cc
  net/third_party/http2/decoder/decode_status.cc
  net/third_party/http2/decoder/frame_decoder_state.cc
  net/third_party/http2/decoder/http2_frame_decoder.cc
  net/third_party/http2/decoder/http2_frame_decoder_listener.cc
  net/third_party/http2/decoder/http2_structure_decoder.cc
  net/third_party/http2/decoder/payload_decoders/altsvc_payload_decoder.cc
  net/third_party/http2/decoder/payload_decoders/continuation_payload_decoder.cc
  net/third_party/http2/decoder/payload_decoders/data_payload_decoder.cc
  net/third_party/http2/decoder/payload_decoders/goaway_payload_decoder.cc
  net/third_party/http2/decoder/payload_decoders/headers_payload_decoder.cc
  net/third_party/http2/decoder/payload_decoders/ping_payload_decoder.cc
  net/third_party/http2/decoder/payload_decoders/priority_payload_decoder.cc
  net/third_party/http2/decoder/payload_decoders/push_promise_payload_decoder.cc
  net/third_party/http2/decoder/payload_decoders/rst_stream_payload_decoder.cc
  net/third_party/http2/decoder/payload_decoders/settings_payload_decoder.cc
  net/third_party/http2/decoder/payload_decoders/unknown_payload_decoder.cc
  net/third_party/http2/decoder/payload_decoders/window_update_payload_decoder.cc
  net/third_party/http2/hpack/decoder/hpack_block_decoder.cc
  net/third_party/http2/hpack/decoder/hpack_decoder.cc
  net/third_party/http2/hpack/decoder/hpack_decoder_listener.cc
  net/third_party/http2/hpack/decoder/hpack_decoder_state.cc
  net/third_party/http2/hpack/decoder/hpack_decoder_string_buffer.cc
  net/third_party/http2/hpack/decoder/hpack_decoder_tables.cc
  net/third_party/http2/hpack/decoder/hpack_entry_decoder.cc
  net/third_party/http2/hpack/decoder/hpack_entry_decoder_listener.cc
  net/third_party/http2/hpack/decoder/hpack_entry_type_decoder.cc
  net/third_party/http2/hpack/decoder/hpack_string_decoder.cc
  net/third_party/http2/hpack/decoder/hpack_string_decoder_listener.cc
  net/third_party/http2/hpack/decoder/hpack_whole_entry_buffer.cc
  net/third_party/http2/hpack/decoder/hpack_whole_entry_listener.cc
  net/third_party/http2/hpack/hpack_static_table_entries.inc
  net/third_party/http2/hpack/hpack_string.cc
  net/third_party/http2/hpack/http2_hpack_constants.cc
  net/third_party/http2/hpack/huffman/hpack_huffman_decoder.cc
  net/third_party/http2/hpack/huffman/hpack_huffman_encoder.cc
  net/third_party/http2/hpack/huffman/huffman_spec_tables.cc
  net/third_party/http2/hpack/varint/hpack_varint_decoder.cc
  net/third_party/http2/hpack/varint/hpack_varint_encoder.cc
  net/third_party/http2/http2_constants.cc
  net/third_party/http2/http2_structures.cc
  net/third_party/http2/platform/impl/http2_flags_impl.cc

  net/third_party/quic/core/congestion_control/bandwidth_sampler.cc
  net/third_party/quic/core/congestion_control/bbr_sender.cc
  net/third_party/quic/core/congestion_control/cubic_bytes.cc
  net/third_party/quic/core/congestion_control/general_loss_algorithm.cc
  net/third_party/quic/core/congestion_control/hybrid_slow_start.cc
  net/third_party/quic/core/congestion_control/pacing_sender.cc
  net/third_party/quic/core/congestion_control/prr_sender.cc
  net/third_party/quic/core/congestion_control/rtt_stats.cc
  net/third_party/quic/core/congestion_control/send_algorithm_interface.cc
  net/third_party/quic/core/congestion_control/tcp_cubic_sender_bytes.cc

  net/third_party/quic/core/crypto/aead_base_decrypter.cc
  net/third_party/quic/core/crypto/aead_base_encrypter.cc
  net/third_party/quic/core/crypto/aes_128_gcm_12_decrypter.cc
  net/third_party/quic/core/crypto/aes_128_gcm_12_encrypter.cc
  net/third_party/quic/core/crypto/aes_128_gcm_decrypter.cc
  net/third_party/quic/core/crypto/aes_128_gcm_encrypter.cc
  net/third_party/quic/core/crypto/aes_256_gcm_decrypter.cc
  net/third_party/quic/core/crypto/aes_256_gcm_encrypter.cc
  net/third_party/quic/core/crypto/cert_compressor.cc
  net/third_party/quic/core/crypto/chacha20_poly1305_decrypter.cc
  net/third_party/quic/core/crypto/chacha20_poly1305_encrypter.cc
  net/third_party/quic/core/crypto/chacha20_poly1305_tls_decrypter.cc
  net/third_party/quic/core/crypto/chacha20_poly1305_tls_encrypter.cc
  net/third_party/quic/core/crypto/channel_id.cc
  net/third_party/quic/core/crypto/common_cert_set.cc
  net/third_party/quic/core/crypto/crypto_framer.cc
  net/third_party/quic/core/crypto/crypto_handshake.cc
  net/third_party/quic/core/crypto/crypto_handshake_message.cc
  net/third_party/quic/core/crypto/crypto_secret_boxer.cc
  net/third_party/quic/core/crypto/crypto_utils.cc
  net/third_party/quic/core/crypto/curve25519_key_exchange.cc
  net/third_party/quic/core/crypto/null_decrypter.cc
  net/third_party/quic/core/crypto/null_encrypter.cc
  net/third_party/quic/core/crypto/p256_key_exchange.cc
  net/third_party/quic/core/crypto/proof_source.cc
  net/third_party/quic/core/crypto/quic_compressed_certs_cache.cc
  net/third_party/quic/core/crypto/quic_crypto_client_config.cc
  net/third_party/quic/core/crypto/quic_crypto_proof.cc
  net/third_party/quic/core/crypto/quic_crypto_server_config.cc
  net/third_party/quic/core/crypto/quic_decrypter.cc
  net/third_party/quic/core/crypto/quic_encrypter.cc
  net/third_party/quic/core/crypto/quic_hkdf.cc
  net/third_party/quic/core/crypto/quic_random.cc
  net/third_party/quic/core/crypto/quic_tls_adapter.cc
  net/third_party/quic/core/crypto/transport_parameters.cc

  net/third_party/quic/core/frames/quic_ack_frame.cc
  net/third_party/quic/core/frames/quic_application_close_frame.cc
  net/third_party/quic/core/frames/quic_blocked_frame.cc
  net/third_party/quic/core/frames/quic_connection_close_frame.cc
  net/third_party/quic/core/frames/quic_crypto_frame.cc
  net/third_party/quic/core/frames/quic_frame.cc
  net/third_party/quic/core/frames/quic_goaway_frame.cc
  net/third_party/quic/core/frames/quic_max_stream_id_frame.cc
  net/third_party/quic/core/frames/quic_message_frame.cc
  net/third_party/quic/core/frames/quic_new_connection_id_frame.cc
  net/third_party/quic/core/frames/quic_new_token_frame.cc
  net/third_party/quic/core/frames/quic_padding_frame.cc
  net/third_party/quic/core/frames/quic_path_challenge_frame.cc
  net/third_party/quic/core/frames/quic_path_response_frame.cc
  net/third_party/quic/core/frames/quic_ping_frame.cc
  net/third_party/quic/core/frames/quic_retire_connection_id_frame.cc
  net/third_party/quic/core/frames/quic_rst_stream_frame.cc
  net/third_party/quic/core/frames/quic_stop_sending_frame.cc
  net/third_party/quic/core/frames/quic_stop_waiting_frame.cc
  net/third_party/quic/core/frames/quic_stream_frame.cc
  net/third_party/quic/core/frames/quic_stream_id_blocked_frame.cc
  net/third_party/quic/core/frames/quic_window_update_frame.cc

  net/third_party/quic/core/http/http_decoder.cc
  net/third_party/quic/core/http/http_encoder.cc
  net/third_party/quic/core/http/quic_client_promised_info.cc
  net/third_party/quic/core/http/quic_client_push_promise_index.cc
  net/third_party/quic/core/http/quic_header_list.cc
  net/third_party/quic/core/http/quic_headers_stream.cc
  net/third_party/quic/core/http/quic_server_session_base.cc
  net/third_party/quic/core/http/quic_spdy_client_session_base.cc
  net/third_party/quic/core/http/quic_spdy_session.cc
  net/third_party/quic/core/http/quic_spdy_stream.cc
  net/third_party/quic/core/http/spdy_utils.cc

  net/third_party/quic/core/qpack/qpack_decoder.cc
  net/third_party/quic/core/qpack/qpack_encoder.cc
  net/third_party/quic/core/qpack/qpack_encoder_stream_receiver.cc
  net/third_party/quic/core/qpack/qpack_encoder_stream_sender.cc
  net/third_party/quic/core/qpack/qpack_header_table.cc
  net/third_party/quic/core/qpack/qpack_static_table.cc

  net/third_party/quic/core/quic_ack_listener_interface.cc
  net/third_party/quic/core/quic_alarm.cc
  net/third_party/quic/core/quic_bandwidth.cc
  net/third_party/quic/core/quic_buffer_allocator.cc
  net/third_party/quic/core/quic_buffered_packet_store.cc
  net/third_party/quic/core/quic_config.cc
  net/third_party/quic/core/quic_connection.cc
  net/third_party/quic/core/quic_connection_stats.cc
  net/third_party/quic/core/quic_constants.cc
  net/third_party/quic/core/quic_control_frame_manager.cc
  net/third_party/quic/core/quic_crypto_client_handshaker.cc
  net/third_party/quic/core/quic_crypto_client_stream.cc
  net/third_party/quic/core/quic_crypto_handshaker.cc
  net/third_party/quic/core/quic_crypto_server_handshaker.cc
  net/third_party/quic/core/quic_crypto_server_stream.cc
  net/third_party/quic/core/quic_crypto_stream.cc
  net/third_party/quic/core/quic_data_reader.cc
  net/third_party/quic/core/quic_data_writer.cc
  net/third_party/quic/core/quic_error_codes.cc
  net/third_party/quic/core/quic_flow_controller.cc
  net/third_party/quic/core/quic_framer.cc
  net/third_party/quic/core/quic_packet_creator.cc
  net/third_party/quic/core/quic_packet_generator.cc
  net/third_party/quic/core/quic_packets.cc
  net/third_party/quic/core/quic_received_packet_manager.cc
  net/third_party/quic/core/quic_sent_packet_manager.cc
  net/third_party/quic/core/quic_server_id.cc
  net/third_party/quic/core/quic_session.cc
  net/third_party/quic/core/quic_simple_buffer_allocator.cc
  net/third_party/quic/core/quic_socket_address_coder.cc
  net/third_party/quic/core/quic_stream.cc
  net/third_party/quic/core/quic_stream_send_buffer.cc
  net/third_party/quic/core/quic_stream_sequencer.cc
  net/third_party/quic/core/quic_stream_sequencer_buffer.cc
  net/third_party/quic/core/quic_sustained_bandwidth_recorder.cc
  net/third_party/quic/core/quic_tag.cc
  net/third_party/quic/core/quic_time.cc
  net/third_party/quic/core/quic_transmission_info.cc
  net/third_party/quic/core/quic_types.cc
  net/third_party/quic/core/quic_unacked_packet_map.cc
  net/third_party/quic/core/quic_utils.cc
  net/third_party/quic/core/quic_version_manager.cc
  net/third_party/quic/core/quic_versions.cc
  net/third_party/quic/core/quic_write_blocked_list.cc
  net/third_party/quic/core/tls_client_handshaker.cc
  net/third_party/quic/core/tls_handshaker.cc
  net/third_party/quic/core/tls_server_handshaker.cc

  net/third_party/quic/platform/api/quic_clock.cc
  net/third_party/quic/platform/api/quic_hostname_utils.cc
  net/third_party/quic/platform/api/quic_ip_address.cc
  net/third_party/quic/platform/api/quic_mutex.cc
  net/third_party/quic/platform/api/quic_socket_address.cc
  net/third_party/quic/platform/impl/quic_chromium_clock.cc
  net/third_party/quic/platform/impl/quic_flags_impl.cc
  net/third_party/quic/platform/impl/quic_hostname_utils_impl.cc
  net/third_party/quic/platform/impl/quic_ip_address_impl.cc
  net/third_party/quic/platform/impl/quic_mem_slice_impl.cc
  net/third_party/quic/platform/impl/quic_mem_slice_span_impl.cc
  net/third_party/quic/platform/impl/quic_mem_slice_storage_impl.cc
  net/third_party/quic/platform/impl/quic_mutex_impl.cc
  net/third_party/quic/platform/impl/quic_socket_address_impl.cc

  net/third_party/quic/quartc/quartc_factory.cc
  net/third_party/quic/quartc/quartc_packet_writer.cc
  net/third_party/quic/quartc/quartc_session.cc
  net/third_party/quic/quartc/quartc_stream.cc

  net/third_party/spdy/core/hpack/hpack_constants.cc
  net/third_party/spdy/core/hpack/hpack_decoder_adapter.cc
  net/third_party/spdy/core/hpack/hpack_encoder.cc
  net/third_party/spdy/core/hpack/hpack_entry.cc
  net/third_party/spdy/core/hpack/hpack_header_table.cc
  net/third_party/spdy/core/hpack/hpack_huffman_table.cc
  net/third_party/spdy/core/hpack/hpack_output_stream.cc
  net/third_party/spdy/core/hpack/hpack_static_table.cc
  net/third_party/spdy/core/http2_frame_decoder_adapter.cc
  net/third_party/spdy/core/spdy_alt_svc_wire_format.cc
  net/third_party/spdy/core/spdy_frame_builder.cc
  net/third_party/spdy/core/spdy_frame_reader.cc
  net/third_party/spdy/core/spdy_framer.cc
  net/third_party/spdy/core/spdy_header_block.cc
  net/third_party/spdy/core/spdy_pinnable_buffer_piece.cc
  net/third_party/spdy/core/spdy_prefixed_buffer_reader.cc
  net/third_party/spdy/core/spdy_protocol.cc

  net/third_party/spdy/platform/impl/spdy_flags_impl.cc
  net/third_party/spdy/platform/impl/spdy_mem_slice_impl.cc
  net/third_party/spdy/platform/impl/spdy_string_utils_impl.cc

  net/third_party/uri_template/uri_template.cc

  third_party/zlib/adler32.c
  third_party/zlib/compress.c
  third_party/zlib/crc32.c
  third_party/zlib/deflate.c
  third_party/zlib/gzclose.c
  third_party/zlib/gzlib.c
  third_party/zlib/gzread.c
  third_party/zlib/gzwrite.c
  third_party/zlib/infback.c
  third_party/zlib/inffast.c
  third_party/zlib/inflate.c
  third_party/zlib/inftrees.c
  third_party/zlib/simd_stub.c
  third_party/zlib/trees.c
  third_party/zlib/uncompr.c
  third_party/zlib/zutil.c
)

LIST_PREFIX(CHROMIUM_NET_SOURCE_FILES ${CHROMIUM_SOURCE_DIR} ${CHROMIUM_NET_SOURCE_FILES})

add_library(${PROJECT_NAME} SHARED
  ${QUIC_CORE_PROTO_RESULTS}
  ${CHROMIUM_NET_SOURCE_FILES})

target_link_libraries(${PROJECT_NAME}
  quic_chromium_base
  quic_chromium_crypto
  quic_chromium_url
  ${PROTOBUF_STATIC_LIBRARIES}
  ${BROTLI_STATIC_LIBRARIES}
)
