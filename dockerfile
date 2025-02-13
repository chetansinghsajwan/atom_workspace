FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu-24.04

ARG DEPS_SOURCE_DIR="/sources"
ARG CLANG_VERSION="18"
ARG FMT_VERSION="11.1.3"
ARG CPPTRACE_VERSION="0.7.5"
ARG ENTT_VERSION="3.14.0"
ARG MSDF_ATLAS_GEN_VERSION="1.3"
ARG IMGUI_VERSION="docking"

# -------------------------------------------------------------------------------------------------
# Install tools
# -------------------------------------------------------------------------------------------------

RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
    clang-$CLANG_VERSION \
    clang-format-$CLANG_VERSION \
    clang-tidy-$CLANG_VERSION \
    clangd-$CLANG_VERSION \
    lldb-$CLANG_VERSION \
    libc++-$CLANG_VERSION-dev \
    ninja-build \
    cmake \
    cmake-format \
    pkg-config \
    doxygen \
    vim \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ENV CC="clang-$CLANG_VERSION" \
    CXX="clang++-$CLANG_VERSION" \
    CXXFLAGS="-stdlib=libc++" \
    CMAKE_GENERATOR="Ninja"

# -------------------------------------------------------------------------------------------------
# Install dependencies
# -------------------------------------------------------------------------------------------------

RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
    libmagicenum-dev \
    libglm-dev \
    libglfw3-dev \
    libbox2d-dev \
    libtinyxml2-dev \
    glslang-dev \
    glslang-tools \
    && rm -rf /var/lib/apt/lists/*

# xorg-dev \
# libwayland-dev \
# autoconf \
# automake \
# autoconf-archive \
# make

# -------------------------------------------------------------------------------------------------
# Install cpptrace, required by
# - atom_core
# -------------------------------------------------------------------------------------------------

RUN git clone "https://github.com/fmtlib/fmt.git" \
    --depth 1 --branch $FMT_VERSION \
    && cd fmt \
    && cmake -S . -B build \
    && cmake --build build \
    && cmake --install build \
    && cd .. \
    && rm -r fmt

# -------------------------------------------------------------------------------------------------
# Install cpptrace, required by
# - atom_core
# -------------------------------------------------------------------------------------------------

RUN git clone "https://github.com/jeremy-rifkin/cpptrace.git" \
    --depth 1 --branch v$CPPTRACE_VERSION \
    && cd cpptrace \
    && cmake -S . -B build \
    && cmake --build build \
    && cmake --install build \
    && cd .. \
    && rm -r cpptrace

# -------------------------------------------------------------------------------------------------
# Install entt, required by
# - atom_engine
# -------------------------------------------------------------------------------------------------

RUN git clone "https://github.com/skypjack/entt.git" \
    --depth 1 --branch v$ENTT_VERSION\
    && cd entt \
    && cmake -S . -B build \
    && cmake --build build \
    && cmake --install build \
    && cd .. \
    && rm -r entt

# -------------------------------------------------------------------------------------------------
# Install msdf-atlas-gen, required by
# - atom_engine
# -------------------------------------------------------------------------------------------------

# Dependencies required for installing msdf-atals-gen
RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
    libfreetype-dev \
    && rm -rf /var/lib/apt/lists/*

RUN git clone "https://github.com/Chlumsky/msdf-atlas-gen.git" \
    --depth 1 --branch v$MSDF_ATLAS_GEN_VERSION --recurse-submodules \
    && cd msdf-atlas-gen \
    && cmake -S . -B build \
    -D MSDF_ATLAS_USE_VCPKG=OFF \
    -D MSDF_ATLAS_USE_SKIA=OFF \
    -D MSDF_ATLAS_BUILD_STANDALONE=OFF \
    -D MSDF_ATLAS_INSTALL=ON \
    && cmake --build build \
    && cmake --install build \
    && cd .. \
    && rm -r msdf-atlas-gen

# -------------------------------------------------------------------------------------------------
# Install imgui source, required by
# - atom_engine
# -------------------------------------------------------------------------------------------------

WORKDIR $DEPS_SOURCE_DIR
RUN git clone "https://github.com/ocornut/imgui.git" \
    --depth 1 --branch $IMGUI_VERSION
ENV IMGUI_SOURCE="$DEPS_SOURCE_DIR/imgui"

# -------------------------------------------------------------------------------------------------
# Install stb source, required by
# - atom_engine
# -------------------------------------------------------------------------------------------------

WORKDIR $DEPS_SOURCE_DIR
RUN git clone "https://github.com/nothings/stb.git" \
    --depth 1
ENV STB_SOURCE="$DEPS_SOURCE_DIR/stb"

# -------------------------------------------------------------------------------------------------

WORKDIR /app
