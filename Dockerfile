FROM ubuntu:24.10 AS bare

LABEL "Description"="Build Environment"

# Install vcpkg
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        zip \
        unzip \
        tar \
        git \
        ca-certificates

RUN git clone https://github.com/microsoft/vcpkg.git \
    && cd vcpkg \
    && ./bootstrap-vcpkg.sh \
    && cd ..

ENV VCPKG_ROOT="/vcpkg" \
    CMAKE_TOOLCHAIN_FILE="/vcpkg/scripts/buildsystems/vcpkg.cmake" \
    PATH="/vcpkg:$PATH"

# Install tools
RUN apt-get install -y --no-install-recommends \
        clang-18 \
        libc++-18-dev \
        ninja-build \
        cmake \
        doxygen \
        pkg-config \
        python3

ENV CC="clang-18" \
    CXX="clang++-18" \
    CXXFLAGS="-stdlib=libc++" \
    CMAKE_GENERATOR="Ninja"

# Install dependencies

RUN apt-get install -y --no-install-recommends \
        xorg-dev \
        libwayland-dev \
        autoconf \
        automake \
        autoconf-archive \
        make

WORKDIR /root/src
COPY "vcpkg.json" .
RUN vcpkg install

# Install msdf-atlas-gen
# required by atom_engine
RUN git clone "https://github.com/Chlumsky/msdf-atlas-gen.git" \
        --depth 1 --branch v1.3 --recurse-submodules && \
    cd msdf-atlas-gen && \
    cmake -S . -B build \
        -D MSDF_ATLAS_USE_SKIA=OFF \
        -D MSDF_ATLAS_BUILD_STANDALONE=OFF \
        -D MSDF_ATLAS_INSTALL=ON \
        && \
    cmake --build build && \
    cmake --install build && \
    cd ..

WORKDIR /root

FROM bare AS devenv

RUN apt-get install -y --no-install-recommends \
        clang-format-18 \
        clang-tidy-18 \
        clangd-18 \
        lldb-18 \
        cmake-format \
        vim
