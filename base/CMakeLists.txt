project(quic_chromium_base)

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

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/cfi_buildflags.h.inc
  ${QUIC_EXTRA_INC_DIR}/base/cfi_buildflags.h COPYONLY)

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/debugging_buildflags.h.inc
  ${QUIC_EXTRA_INC_DIR}/base/debug/debugging_buildflags.h COPYONLY)

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/synchronization_buildflags.h.inc
  ${QUIC_EXTRA_INC_DIR}/base/synchronization/synchronization_buildflags.h COPYONLY)

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/protected_memory_buildflags.h.inc
  ${QUIC_EXTRA_INC_DIR}/base/memory/protected_memory_buildflags.h COPYONLY)

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/allocator_buildflags.h.inc
  ${QUIC_EXTRA_INC_DIR}/base/allocator/buildflags.h COPYONLY)

if(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
  set(CHROMIUM_BASE_ARCH_SOURCE_FILES
    base/base_paths_posix.cc
    base/debug/debugger_posix.cc
    base/debug/stack_trace_posix.cc
    base/files/file_descriptor_watcher_posix.cc
    base/files/file_enumerator_posix.cc
    base/files/file_path_watcher_linux.cc
    base/files/file_posix.cc
    base/files/file_util_posix.cc
    base/files/memory_mapped_file_posix.cc
    base/memory/platform_shared_memory_region_posix.cc
    base/memory/shared_memory_handle_posix.cc
    base/memory/shared_memory_posix.cc
    base/message_loop/watchable_io_message_pump_posix.cc
    base/nix/xdg_util.cc
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
    base/system/sys_info_linux.cc
    base/system/sys_info_posix.cc
    base/task/task_scheduler/task_tracker_posix.cc
    base/third_party/xdg_user_dirs/xdg_user_dir_lookup.cc
    base/threading/platform_thread_internal_posix.cc
    base/threading/platform_thread_linux.cc
    base/threading/platform_thread_posix.cc
    base/threading/thread_local_storage_posix.cc
    base/time/time_conversion_posix.cc
    base/time/time_exploded_posix.cc
    base/time/time_now_posix.cc
  )

  add_definitions(-DMEMORY_TOOL_REPLACES_ALLOCATOR=1)
elseif(${CMAKE_SYSTEM_NAME} MATCHES "Android")
  set(CHROMIUM_BASE_ARCH_SOURCE_FILES
    base/base_paths_android.cc
  )
elseif(${CMAKE_SYSTEM_NAME} MATCHES "FreeBSD")
  set(CHROMIUM_BASE_ARCH_SOURCE_FILES)
elseif(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
  set(CHROMIUM_BASE_ARCH_SOURCE_FILES)
elseif(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
  set(CHROMIUM_BASE_ARCH_SOURCE_FILES
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

set(CHROMIUM_BASE_SOURCE_FILES
  ${CHROMIUM_BASE_ARCH_SOURCE_FILES}

  base/allocator/allocator_extension.cc
  base/at_exit.cc
  base/base64.cc
  base/base_paths.cc
  base/base_switches.cc
  base/big_endian.cc
  base/build_time.cc
  base/callback_helpers.cc
  base/callback_internal.cc
  base/command_line.cc
  base/environment.cc
  base/feature_list.cc
  base/hash.cc
  base/lazy_instance_helpers.cc
  base/location.cc
  base/logging.cc
  base/md5.cc
  base/observer_list_threadsafe.cc
  base/path_service.cc
  base/pending_task.cc
  base/pickle.cc
  base/rand_util.cc
  base/run_loop.cc
  base/sequence_checker_impl.cc
  base/sequence_token.cc
  base/sequenced_task_runner.cc
  base/sha1.cc
  base/supports_user_data.cc
  base/task_runner.cc
  base/token.cc
  base/unguessable_token.cc
  base/value_iterators.cc
  base/values.cc
  base/vlog.cc

  base/debug/activity_tracker.cc
  base/debug/alias.cc
  base/debug/stack_trace.cc
  base/debug/crash_logging.cc
  base/debug/task_annotator.cc

  base/files/file.cc
  base/files/file_enumerator.cc
  base/files/file_path.cc
  base/files/file_path_constants.cc
  base/files/file_path_watcher.cc
  base/files/file_tracing.cc
  base/files/file_util.cc
  base/files/important_file_writer.cc
  base/files/memory_mapped_file.cc
  base/files/scoped_file.cc

  base/i18n/case_conversion.cc
  base/i18n/i18n_constants.cc
  base/i18n/icu_string_conversions.cc

  base/json/json_parser.cc
  base/json/json_reader.cc
  base/json/json_string_value_serializer.cc
  base/json/json_writer.cc
  base/json/string_escape.cc

  base/memory/memory_pressure_listener.cc
  base/memory/platform_shared_memory_region.cc
  base/memory/read_only_shared_memory_region.cc
  base/memory/ref_counted.cc
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

  base/system/sys_info.cc

  base/third_party/dmg_fp/dtoa_wrapper.cc
  base/third_party/icu/icu_utf.cc
  base/third_party/dmg_fp/g_fmt.cc
  base/third_party/nspr/prtime.cc
  base/third_party/superfasthash/superfasthash.c

  base/threading/platform_thread.cc
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

  base/power_monitor/power_monitor.cc
  base/power_monitor/power_monitor_source.cc

  base/process/memory.cc
  base/process/process_handle.cc
  base/process/process_metrics.cc

  base/task/common/operations_controller.cc
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

  base/time/clock.cc
  base/time/default_clock.cc
  base/time/default_tick_clock.cc
  base/time/tick_clock.cc
  base/time/time.cc
  base/time/time_to_iso8601.cc

  base/timer/elapsed_timer.cc
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

  third_party/modp_b64/modp_b64.cc
)

LIST_PREFIX(CHROMIUM_BASE_SOURCE_FILES ${CHROMIUM_SOURCE_DIR} ${CHROMIUM_BASE_SOURCE_FILES})

add_library(${PROJECT_NAME} SHARED
  ${QUIC_EXTRA_INC_DIR}/base/generated_build_date.h
  ${CHROMIUM_BASE_SOURCE_FILES}
)

target_link_libraries(${PROJECT_NAME}
  ${CMAKE_THREAD_LIBS_INIT}
  ${ICU_STATIC_LIBRARIES}
  ${LIBEVENT_STATIC_LIBRARIES}
)

add_dependencies(
  ${PROJECT_NAME}
  libevent
  icu
)
