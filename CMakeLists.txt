cmake_minimum_required(VERSION 3.2)

project(quic-cmake)

get_filename_component(CHROMIUM_SOURCE_DIR ${CHROMIUM_DIR} ABSOLUTE)

set(QUIC_EXTRA_INC_DIR ${CMAKE_BINARY_DIR}/extra)
set(QUIC_EXTRA_INC_THIRD_PARTY_GTEST_DIR ${QUIC_EXTRA_INC_DIR}/third_party/googletest/src/googletest/include)
set(QUIC_EXTRA_INC_THIRD_PARTY_BORINGSSL_DIR ${QUIC_EXTRA_INC_DIR}/third_party/boringssl/src/include)
set(QUIC_EXTRA_INC_ICU_COMMON_DIR  ${QUIC_EXTRA_INC_DIR}/third_party/icu/source/common)

find_package(Threads)

include(cmake/external/zlib.cmake)
include(cmake/external/boringssl.cmake)
include(cmake/external/gtest.cmake)
include(cmake/external/protobuf.cmake)
include(cmake/external/libevent.cmake)
include(cmake/external/icu.cmake)
include(cmake/utils.cmake)

include_directories(${ZLIB_INCLUDE_DIR})
include_directories(${BORINGSSL_INCLUDE_DIR})
include_directories(${PROTOBUF_INCLUDE_DIR})
include_directories(${LIBEVENT_INCLUDE_DIRS})
include_directories(${QUIC_EXTRA_INC_DIR})
include_directories(${CHROMIUM_SOURCE_DIR})

set(QUIC_CORE_PROTO_SOURCE_FILES
	net/third_party/quic/core/proto/cached_network_parameters.proto
	net/third_party/quic/core/proto/source_address_token.proto
  net/third_party/quic/core/proto/crypto_server_config.proto
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

configure_file(${CMAKE_SOURCE_DIR}/cfi_buildflags.h.inc
  ${QUIC_EXTRA_INC_DIR}/base/cfi_buildflags.h COPYONLY)

configure_file(${CMAKE_SOURCE_DIR}/debugging_buildflags.h.inc
  ${QUIC_EXTRA_INC_DIR}/base/debug/debugging_buildflags.h COPYONLY)

configure_file(${CMAKE_SOURCE_DIR}/synchronization_buildflags.h.inc
  ${QUIC_EXTRA_INC_DIR}/base/synchronization/synchronization_buildflags.h COPYONLY)

configure_file(${CMAKE_SOURCE_DIR}/protected_memory_buildflags.h.inc
  ${QUIC_EXTRA_INC_DIR}/base/memory/protected_memory_buildflags.h COPYONLY)

configure_file(${CMAKE_SOURCE_DIR}/allocator_buildflags.h.inc
  ${QUIC_EXTRA_INC_DIR}/base/allocator/buildflags.h COPYONLY)

configure_file(${CMAKE_SOURCE_DIR}/net_buildflags.h.inc
  ${QUIC_EXTRA_INC_DIR}/net/net_buildflags.h COPYONLY)

find_package(Git)

execute_process(
  COMMAND ${GIT_EXECUTABLE} log -n1 --format="%at"
  WORKING_DIRECTORY ${CHROMIUM_SOURCE_DIR}
  OUTPUT_VARIABLE _build_timestamp
  ERROR_QUIET
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

string(REPLACE "\"" "" _build_timestamp ${_build_timestamp})

add_custom_command(
  OUTPUT ${QUIC_EXTRA_INC_DIR}/base/generated_build_date.h
  COMMAND ${CHROMIUM_SOURCE_DIR}/build/write_build_date_header.py
  ARGS ${QUIC_EXTRA_INC_DIR}/base/generated_build_date.h ${_build_timestamp}
  DEPENDS ${CHROMIUM_SOURCE_DIR}/build/write_build_date_header.py
  VERBATIM
)

if(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
  set(CHROMIUM_BASE_ARCH_SOURCE_FILES
    base/debug/debugger_posix.cc
    base/debug/stack_trace_posix.cc
    base/files/file_descriptor_watcher_posix.cc
    base/files/file_enumerator_posix.cc
    base/files/file_posix.cc
    base/files/file_util_posix.cc
    base/files/memory_mapped_file_posix.cc
    base/memory/platform_shared_memory_region_posix.cc
    base/memory/shared_memory_handle_posix.cc
    base/memory/shared_memory_posix.cc
    base/message_loop/watchable_io_message_pump_posix.cc
    base/posix/can_lower_nice_to.cc
    base/posix/global_descriptors.cc
    base/posix/safe_strerror.cc
    base/process/internal_linux.cc
    base/process/memory_linux.cc
    base/process/process_handle_linux.cc
    base/process/process_handle_posix.cc
    base/process/process_linux.cc
    base/process/process_metrics_linux.cc
    base/process/process_metrics_posix.cc
    base/process/process_posix.cc
    base/rand_util_posix.cc
    base/strings/sys_string_conversions_posix.cc
    base/synchronization/condition_variable_posix.cc
    base/synchronization/lock_impl_posix.cc
    base/synchronization/waitable_event_posix.cc
    base/sys_info_linux.cc
    base/sys_info_posix.cc
    base/task/task_scheduler/task_tracker_posix.cc
    base/threading/platform_thread_internal_posix.cc
    base/threading/platform_thread_linux.cc
    base/threading/platform_thread_posix.cc
    base/threading/thread_local_storage_posix.cc
    base/time/time_conversion_posix.cc
    base/time/time_exploded_posix.cc
    base/time/time_now_posix.cc

    net/base/network_change_notifier_linux.cc
    net/dns/dns_config_service_posix.cc

    net/cert/cert_verify_proc_nss.cc

    # ${CHROMIUM_SOURCE_DIR}/net/tools/epoll_server/epoll_server.cc
  )

  add_definitions(-DUSE_NSS_CERTS=1)

  include(cmake/external/nss.cmake)
  include_directories(${NSS_INCLUDE_DIRS})

elseif(${CMAKE_SYSTEM_NAME} MATCHES "Android")
  set(CHROMIUM_BASE_ARCH_SOURCE_FILES)
elseif(${CMAKE_SYSTEM_NAME} MATCHES "FreeBSD")
  set(CHROMIUM_BASE_ARCH_SOURCE_FILES)
elseif(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
  set(CHROMIUM_BASE_ARCH_SOURCE_FILES)
elseif(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
  set(CHROMIUM_BASE_ARCH_SOURCE_FILES
    net/dns/dns_config_service_win.cc
  )
endif()

set(CHROMIUM_BASE_SOURCE_FILES
  ${CHROMIUM_BASE_ARCH_SOURCE_FILES}
	base/at_exit.cc
	base/base64.cc
	base/base_switches.cc
	base/callback_helpers.cc
	base/callback_internal.cc
	base/logging.cc
	base/md5.cc
	base/rand_util.cc
	base/values.cc
	base/vlog.cc
  base/allocator/allocator_extension.cc
  base/build_time.cc
  base/command_line.cc
  base/feature_list.cc
  base/hash.cc
  base/lazy_instance_helpers.cc
  base/location.cc
  base/observer_list_threadsafe.cc
  base/pending_task.cc
  base/pickle.cc
  base/run_loop.cc
  base/sequence_checker_impl.cc
  base/sequence_token.cc
  base/sequenced_task_runner.cc
  base/sha1.cc
  base/sys_info.cc
  base/task_runner.cc
  base/unguessable_token.cc
  base/value_iterators.cc

	base/debug/activity_tracker.cc
	base/debug/alias.cc
	# base/debug/debugger.cc
  base/debug/stack_trace.cc
  base/debug/crash_logging.cc
  base/debug/task_annotator.cc

	base/files/file.cc
	base/files/file_path.cc
  base/files/file_path_constants.cc
  base/files/file_enumerator.cc
  base/files/file_util.cc
  base/files/important_file_writer.cc
	base/files/file_tracing.cc
	base/files/memory_mapped_file.cc
  base/files/scoped_file.cc

	base/json/json_parser.cc
	base/json/json_reader.cc
	base/json/json_string_value_serializer.cc
	base/json/json_writer.cc
	base/json/string_escape.cc

	base/memory/ref_counted.cc
  base/memory/platform_shared_memory_region.cc
  base/memory/read_only_shared_memory_region.cc
  base/memory/ref_counted_memory.cc
  base/memory/shared_memory_handle.cc
  base/memory/shared_memory_helper.cc
  base/memory/shared_memory_mapping.cc
  base/memory/shared_memory_tracker.cc
  base/memory/weak_ptr.cc

	base/metrics/bucket_ranges.cc
	base/metrics/histogram.cc
	base/metrics/histogram_base.cc
	base/metrics/histogram_samples.cc
	base/metrics/metrics_hashes.cc
	base/metrics/persistent_histogram_allocator.cc
	base/metrics/persistent_memory_allocator.cc
	base/metrics/persistent_sample_map.cc
	base/metrics/sample_map.cc
	base/metrics/sample_vector.cc
	base/metrics/sparse_histogram.cc
  base/metrics/statistics_recorder.cc
  base/metrics/dummy_histogram.cc
  base/metrics/field_trial.cc
  base/metrics/field_trial_param_associator.cc
  base/metrics/field_trial_params.cc
  base/metrics/histogram_functions.cc
  base/metrics/histogram_snapshot_manager.cc

	base/strings/string16.cc
	base/strings/string_number_conversions.cc
	base/strings/string_piece.cc
	base/strings/string_split.cc
	base/strings/string_util.cc
	base/strings/string_util_constants.cc
	base/strings/stringprintf.cc
	base/strings/utf_offset_string_conversions.cc
  base/strings/pattern.cc
  base/strings/utf_string_conversion_utils.cc
  base/strings/utf_string_conversions.cc

  base/synchronization/atomic_flag.cc
  base/synchronization/lock.cc

	base/third_party/dmg_fp/dtoa_wrapper.cc
	base/third_party/icu/icu_utf.cc
  base/third_party/dmg_fp/g_fmt.cc
  base/third_party/nspr/prtime.cc
  base/third_party/superfasthash/superfasthash.c

	base/threading/thread_checker_impl.cc
	base/threading/thread_id_name_manager.cc
	base/threading/thread_local_storage.cc
	base/threading/thread_restrictions.cc

  base/message_loop/message_loop.cc
  base/message_loop/message_loop_current.cc
  base/message_loop/message_loop_impl.cc
  base/message_loop/message_loop_task_runner.cc
  base/message_loop/message_pump.cc
  base/message_loop/message_pump_default.cc
  base/message_loop/message_pump_libevent.cc
  base/message_loop/pending_task_queue.cc

  base/process/memory.cc
  base/process/process_handle.cc
  base/process/process_metrics.cc

  base/task/post_task.cc
  base/task/scoped_set_task_priority_for_current_thread.cc
  base/task/task_executor.cc
  base/task/task_features.cc
  base/task/task_traits.cc

  base/task/sequence_manager/enqueue_order.cc
  base/task/sequence_manager/lazy_now.cc
  base/task/sequence_manager/real_time_domain.cc
  base/task/sequence_manager/sequence_manager.cc
  base/task/sequence_manager/sequence_manager_impl.cc
  base/task/sequence_manager/sequence_manager_impl.cc
  base/task/sequence_manager/task_queue.cc
  base/task/sequence_manager/task_queue_impl.cc
  base/task/sequence_manager/task_queue_proxy.cc
  base/task/sequence_manager/task_queue_selector.cc
  base/task/sequence_manager/task_queue_task_runner.cc
  base/task/sequence_manager/tasks.cc
  base/task/sequence_manager/thread_controller_impl.cc
  base/task/sequence_manager/thread_controller_with_message_pump_impl.cc
  base/task/sequence_manager/time_domain.cc
  base/task/sequence_manager/work_queue.cc
  base/task/sequence_manager/work_queue_sets.cc

  base/task/task_scheduler/delayed_task_manager.cc
  base/task/task_scheduler/environment_config.cc
  base/task/task_scheduler/priority_queue.cc
  base/task/task_scheduler/scheduler_lock_impl.cc
  base/task/task_scheduler/scheduler_parallel_task_runner.cc
  base/task/task_scheduler/scheduler_sequenced_task_runner.cc
  base/task/task_scheduler/scheduler_single_thread_task_runner_manager.cc
  base/task/task_scheduler/scheduler_task_runner_delegate.cc
  base/task/task_scheduler/scheduler_worker.cc
  base/task/task_scheduler/scheduler_worker_pool.cc
  base/task/task_scheduler/scheduler_worker_pool_impl.cc
  base/task/task_scheduler/scheduler_worker_pool_params.cc
  base/task/task_scheduler/scheduler_worker_stack.cc
  base/task/task_scheduler/sequence.cc
  base/task/task_scheduler/sequence_sort_key.cc
  base/task/task_scheduler/service_thread.cc
  base/task/task_scheduler/task.cc
  base/task/task_scheduler/task_scheduler.cc
  base/task/task_scheduler/task_scheduler_impl.cc
  base/task/task_scheduler/task_tracker.cc

  base/threading/post_task_and_reply_impl.cc
  base/threading/scoped_blocking_call.cc
  base/threading/sequence_local_storage_map.cc
  base/threading/sequenced_task_runner_handle.cc
  base/threading/thread.cc
  base/threading/thread_collision_warner.cc
  base/threading/thread_task_runner_handle.cc

  base/time/default_tick_clock.cc
  base/time/tick_clock.cc
  base/time/time_to_iso8601.cc
  base/time/time.cc

  base/timer/timer.cc

	base/trace_event/heap_profiler_allocation_context_tracker.cc
  base/trace_event/blame_context.cc
  base/trace_event/category_registry.cc
  base/trace_event/event_name_filter.cc
  base/trace_event/heap_profiler_allocation_context.cc
  base/trace_event/heap_profiler_event_filter.cc
  base/trace_event/malloc_dump_provider.cc
  base/trace_event/memory_allocator_dump.cc
  base/trace_event/memory_allocator_dump_guid.cc
  base/trace_event/memory_dump_manager.cc
  base/trace_event/memory_dump_provider_info.cc
  base/trace_event/memory_dump_request_args.cc
  base/trace_event/memory_dump_scheduler.cc
  base/trace_event/memory_infra_background_whitelist.cc
  base/trace_event/memory_usage_estimator.cc
  base/trace_event/process_memory_dump.cc
  base/trace_event/trace_buffer.cc
  base/trace_event/trace_config.cc
  base/trace_event/trace_config_category_filter.cc
  base/trace_event/trace_event_filter.cc
  base/trace_event/trace_event_impl.cc
  base/trace_event/trace_event_memory_overhead.cc
  base/trace_event/trace_log.cc
  base/trace_event/trace_log_constants.cc
  base/trace_event/traced_value.cc
)

set(QUIC_SOURCE_FILES
  crypto/openssl_util.cc
  crypto/rsa_private_key.cc
  crypto/signature_verifier.cc
  crypto/sha2.cc

  net/base/address_family.cc
  net/base/address_list.cc
  net/base/auth.cc
	net/base/arena.cc
	net/base/escape.cc
	net/base/host_port_pair.cc
	net/base/ip_address.cc
	net/base/ip_endpoint.cc
	net/base/net_errors.cc
	net/base/parse_number.cc
	net/base/port_util.cc
	net/base/url_util.cc
  net/base/hex_utils.cc
  net/base/io_buffer.cc
  net/base/sockaddr_storage.cc
  net/base/network_change_notifier.cc
  net/base/upload_data_stream.cc
  net/base/hash_value.cc
  net/base/load_timing_info.cc

  # net/base/registry_controlled_domains/registry_controlled_domain.cc

  net/socket/socket.cc
  net/socket/stream_socket.cc
  net/socket/socket_tag.cc
  net/socket/websocket_endpoint_lock_manager.cc

  net/cert/asn1_util.cc
  net/cert/cert_verifier.cc
  net/cert/ocsp_verify_result.cc
  net/cert/pem_tokenizer.cc
  net/cert/signed_certificate_timestamp_and_status.cc
  net/cert/x509_cert_types.cc
  net/cert/x509_certificate.cc
  net/cert/x509_certificate_net_log_param.cc
  net/cert/x509_util.cc
  net/cert/cert_verify_result.cc
  net/cert/symantec_certs.cc
  net/cert/caching_cert_verifier.cc
  net/cert/cert_database.cc
  net/cert/cert_verify_proc.cc
  net/cert/signed_certificate_timestamp.cc
  net/cert/multi_threaded_cert_verifier.cc

  net/cert/internal/cert_errors.cc
  net/cert/internal/signature_algorithm.cc
  net/cert/internal/parse_name.cc

  net/dns/dns_config.cc
  net/dns/dns_util.cc

  net/der/encode_values.cc
  net/der/input.cc
  net/der/parse_values.cc
  net/der/parser.cc
  net/der/tag.cc

  net/extras/preload_data/decoder.cc

  net/http/bidirectional_stream.cc
  net/http/bidirectional_stream_impl.cc
  net/http/bidirectional_stream_request_info.cc
  net/http/http_auth.cc
  net/http/http_auth_cache.cc
  net/http/http_auth_challenge_tokenizer.cc
  net/http/http_auth_controller.cc
  net/http/http_auth_handler_factory.cc
  net/http/http_auth_scheme.cc
  net/http/http_byte_range.cc
  net/http/http_log_util.cc
  net/http/http_network_session.cc
  net/http/http_raw_request_headers.cc
  net/http/http_request_headers.cc
  net/http/http_response_headers.cc
  net/http/http_response_info.cc
  net/http/http_server_properties.cc
  net/http/http_util.cc
  net/http/http_vary_data.cc
  net/http/proxy_client_socket.cc
  net/http/proxy_connect_redirect_http_stream.cc
  net/http/transport_security_state.cc
  net/http/transport_security_state_source.cc
  net/http/http_stream_factory.cc

  net/log/net_log.cc
  net/log/net_log_capture_mode.cc
  net/log/net_log_entry.cc
  net/log/net_log_source.cc
  net/log/net_log_with_source.cc

  net/spdy/http2_priority_dependencies.cc
  net/spdy/multiplexed_http_stream.cc
  net/spdy/multiplexed_session.cc
  net/spdy/spdy_http_utils.cc
  net/spdy/spdy_log_util.cc
  net/spdy/spdy_session_pool.cc
  net/spdy/spdy_session_key.cc
  net/spdy/spdy_session.cc


  net/ssl/ssl_config.cc
  net/ssl/ssl_config_service.cc
  net/ssl/ssl_info.cc
  net/ssl/ssl_client_auth_cache.cc
  net/ssl/ssl_cert_request_info.cc

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
)

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

set(LIBQUIC_SOURCE_FILES
  ${CHROMIUM_BASE_SOURCE_FILES}
  ${CHROMIUM_NET_BASE_SOURCE_FILES}
  ${CHROMIUM_URL_SOURCE_FILES}
  ${QUIC_SOURCE_FILES}

  third_party/modp_b64/modp_b64.cc
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

LIST_PREFIX(LIBQUIC_SOURCE_FILES ${CHROMIUM_SOURCE_DIR} ${LIBQUIC_SOURCE_FILES})

add_definitions(-DUCHAR_TYPE=uint16_t)

add_library(quic SHARED
  ${QUIC_EXTRA_INC_DIR}/base/generated_build_date.h
  ${QUIC_CORE_PROTO_RESULTS}
  ${LIBQUIC_SOURCE_FILES}
)

target_link_libraries(quic
  ${BORINGSSL_STATIC_LIBRARIES}
  ${PROTOBUF_STATIC_LIBRARIES}
  ${LIBEVENT_STATIC_LIBRARIES}
  ${ZLIB_STATIC_LIBRARIES}
  ${ICU_STATIC_LIBRARIES}
  ${NSS_STATIC_LIBRARIES}
  ${CMAKE_THREAD_LIBS_INIT}
  ${CMAKE_DL_LIBS}
)

add_dependencies(quic
  gtest
)