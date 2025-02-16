# the name of the target operating system
set(CMAKE_SYSTEM_NAME Windows)

set(TOOLCHAIN_PREFIX "x86_64-w64-mingw32")
set(TOOLCHAIN_PATH "/opt/llvm-mingw/${TOOLCHAIN_PREFIX}")

# which compilers to use for C and C++
# set(CMAKE_C_COMPILER "clang")
# set(CMAKE_CXX_COMPILER "clang++")

set(CMAKE_C_FLAGS "-target ${TOOLCHAIN_PREFIX}")
set(CMAKE_CXX_FLAGS "-target ${TOOLCHAIN_PREFIX}")

set(CMAKE_EXE_LINKER_FLAGS "-static")
# set(CMAKE_EXE_LINKER_FLAGS "-static -static-libgcc -static-libstdc++")

# search programs in the host environment
# search headers and libraries in the target environment
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
