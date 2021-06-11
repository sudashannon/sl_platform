if (SL_PLATFORM_POSIX)

    sl_sources(
        sl_platform
        posix_atomic.c posix_file.c posix_log.c posix_os.c posix_socket.c
    )

endif ()