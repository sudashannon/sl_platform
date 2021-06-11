include(CheckFunctionExists)
include(CheckSymbolExists)
include(CheckStructHasMember)
include(CheckLibraryExists)
include(CheckCSourceCompiles)

# sl_sources adds library sources using files in the current directory.
function(sl_sources target)
    foreach (f ${ARGN})
        target_sources(${ARGV0} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/${f})
    endforeach ()
endfunction()

# sl_headers adds library sources as public headers taken rooted at the include/ directory.
function(sl_headers target)
    foreach (f ${ARGN})
        target_sources(${ARGV0} PRIVATE ${PROJECT_SOURCE_DIR}/include/${f})
    endforeach ()
endfunction()

# sl_defines adds defines unconditionally.
# The public library keeps these defines private, but the test library exposes these definitions
# as some of our test cases would like to know details about how the library was compiled
# as that may modify the tests themselves.
function(sl_defines target)
    target_compile_definitions(${ARGV0} PRIVATE ${ARGN})
endfunction()

# sl_link_libraries adds link dependencies to the libraries.
function(sl_link_libraries target)
    target_link_libraries(${ARGV0} PRIVATE ${ARGN})
endfunction()

# sl_include_directories adds include directories.
function(sl_include_directories target)
    target_include_directories(${ARGV0} PRIVATE ${ARGN})
endfunction()