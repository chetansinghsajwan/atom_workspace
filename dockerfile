FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu-24.04 AS base

ARG DEPS_SOURCE_DIR="/sources"
ARG CLANG_VERSION="18"
ARG CATCH2_VERSION="3.8.0"
ARG CPPTRACE_VERSION="0.7.5"
ARG FMT_VERSION="11.1.3"
ARG MAGIC_ENUM_VERSION="0.9.7"
ARG BOX2D_VERSION="2.4.2"
ARG ENTT_VERSION="3.14.0"
ARG GLFW_VERSION="3.4"
ARG GLM_VERSION="release-1.0.2"
ARG GLSLANG_VERSION="15.1.0"
ARG IMGUI_VERSION="docking"
ARG MSDF_ATLAS_GEN_VERSION="1.3"
ARG STB_VERSION="master"

# -------------------------------------------------------------------------------------------------
# Install build tools
# -------------------------------------------------------------------------------------------------

RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
    clang-$CLANG_VERSION \
    libc++-$CLANG_VERSION-dev \
    ninja-build \
    cmake \
    pkg-config \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ENV CC="clang-$CLANG_VERSION" \
    CXX="clang++-$CLANG_VERSION" \
    CXXFLAGS="-stdlib=libc++" \
    CMAKE_GENERATOR="Ninja"

# -------------------------------------------------------------------------------------------------
# Install catch2, required by
# - atom_core
# -------------------------------------------------------------------------------------------------

FROM base AS catch2-builder

RUN git clone "https://github.com/catchorg/catch2.git" \
    --depth 1 --branch v$CATCH2_VERSION \
    && cd catch2 \
    && cmake -S . -B build \
    && cmake --build build \
    && cmake --install build --prefix /out

# -------------------------------------------------------------------------------------------------
# Install cpptrace, required by
# - atom_core
# -------------------------------------------------------------------------------------------------

FROM base AS cpptrace-builder

RUN git clone "https://github.com/jeremy-rifkin/cpptrace.git" \
    --depth 1 --branch v$CPPTRACE_VERSION \
    && cd cpptrace \
    && cmake -S . -B build \
    && cmake --build build \
    && cmake --install build --prefix /out

# -------------------------------------------------------------------------------------------------
# Install fmt, required by
# - atom_core
# -------------------------------------------------------------------------------------------------

FROM base AS fmt-builder

RUN git clone "https://github.com/fmtlib/fmt.git" \
    --depth 1 --branch $FMT_VERSION \
    && cd fmt \
    && cmake -S . -B build \
    && cmake --build build \
    && cmake --install build --prefix /out

# -------------------------------------------------------------------------------------------------
# Install magic_enum, required by
# - atom_core
# -------------------------------------------------------------------------------------------------

FROM base AS magic_enum-builder

RUN git clone "https://github.com/neargye/magic_enum.git" \
    --depth 1 --branch v$MAGIC_ENUM_VERSION \
    && cd magic_enum \
    && cmake -S . -B build \
    && cmake --build build \
    && cmake --install build --prefix /out

# -------------------------------------------------------------------------------------------------
# Install box2d, required by
# - atom_engine
# -------------------------------------------------------------------------------------------------

FROM base AS box2d-builder

RUN git clone "https://github.com/erincatto/box2d.git" \
    --depth 1 --branch v$BOX2D_VERSION \
    && cd box2d \
    && cmake -S . -B build \
    -D BOX2D_BUILD_UNIT_TESTS=OFF \
    -D BOX2D_BUILD_TESTBED=OFF \
    -D BOX2D_BUILD_DOCS=OFF \
    -D BOX2D_USER_SETTINGS=OFF \
    -D BUILD_SHARED_LIBS=OFF \
    && cmake --build build \
    && cmake --install build --prefix /out

# -------------------------------------------------------------------------------------------------
# Install entt, required by
# - atom_engine
# -------------------------------------------------------------------------------------------------

FROM base AS entt-builder

RUN git clone "https://github.com/skypjack/entt.git" \
    --depth 1 --branch v$ENTT_VERSION \
    && cd entt \
    && cmake -S . -B build \
    && cmake --build build \
    && cmake --install build --prefix /out

# -------------------------------------------------------------------------------------------------
# Install glfw, required by
# - atom_engine
# -------------------------------------------------------------------------------------------------

FROM base AS glfw-builder

# Dependencies for wayland support
RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
    libwayland-dev \
    libxkbcommon-dev \
    wayland-protocols \
    extra-cmake-modules \
    && rm -rf /var/lib/apt/lists/*

RUN git clone "https://github.com/glfw/glfw.git" \
    --depth 1 --branch $GLFW_VERSION \
    && cd glfw \
    && cmake -S . -B build \
    -D GLFW_BUILD_TESTS=OFF \
    -D GLFW_BUILD_X11=OFF \
    -D GLFW_BUILD_WAYLAND=ON \
    && cmake --build build \
    && cmake --install build --prefix /out

# -------------------------------------------------------------------------------------------------
# Install glm, required by
# - atom_engine
# -------------------------------------------------------------------------------------------------

FROM base AS glm-builder

RUN git clone "https://github.com/g-truc/glm.git" \
    --depth 1 --branch $GLM_VERSION \
    && cd glm \
    && cmake -S . -B build \
    -D GLM_ENABLE_CXX_20=ON \
    -D GLM_ENABLE_LANG_EXTENSIONS=ON \
    && cmake --build build \
    && cmake --install build --prefix /out

# -------------------------------------------------------------------------------------------------
# Install glslang, required by
# - atom_engine
# -------------------------------------------------------------------------------------------------

FROM base AS glslang-builder

RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
    python3 \
    && rm -rf /var/lib/apt/lists/*

RUN git clone "https://github.com/KhronosGroup/glslang.git" \
    --depth 1 --branch $GLSLANG_VERSION \
    && cd glslang \
    && ./update_glslang_sources.py \
    && cmake -S . -B build \
    && cmake --build build \
    && cmake --install build --prefix /out

# -------------------------------------------------------------------------------------------------
# Install imgui, required by
# - atom_engine
# -------------------------------------------------------------------------------------------------

FROM base AS imgui-builder

RUN git clone "https://github.com/ocornut/imgui.git" /out \
    --depth 1 --branch $IMGUI_VERSION

FROM base AS vcpkg

# Set env variables
ENV VCPKG_ROOT=/opt/vcpkg
ENV PATH="$VCPKG_ROOT:$PATH"
ENV CMAKE_TOOLCHAIN_FILE="$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake"

# Install vcpkg
WORKDIR $VCPKG_ROOT
RUN git clone https://github.com/microsoft/vcpkg.git . \
    && ./bootstrap-vcpkg.sh

# Reset working directory
WORKDIR /app

# -------------------------------------------------------------------------------------------------
# Install msdf-atlas-gen, required by
# - atom_engine
# -------------------------------------------------------------------------------------------------

FROM vcpkg AS msdf-atlas-gen-builder

# Dependencies required for installing msdf-atals-gen
RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
    libfreetype-dev \
    && rm -rf /var/lib/apt/lists/*

RUN git clone "https://github.com/Chlumsky/msdf-atlas-gen.git" \
    --depth 1 --branch v$MSDF_ATLAS_GEN_VERSION --recurse-submodules \
    && cd msdf-atlas-gen \
    && cmake -S . -B build \
    -D MSDF_ATLAS_USE_SKIA=OFF \
    -D MSDF_ATLAS_BUILD_STANDALONE=OFF \
    -D MSDF_ATLAS_INSTALL=ON \
    && cmake --build build \
    && cmake --install build --prefix /out

# -------------------------------------------------------------------------------------------------
# Install stb, required by
# - atom_engine
# -------------------------------------------------------------------------------------------------

FROM base AS stb-builder

RUN git clone "https://github.com/nothings/stb.git" /out \
    --depth 1 --branch $STB_VERSION

# -------------------------------------------------------------------------------------------------
# Development environment
# -------------------------------------------------------------------------------------------------

FROM base AS devenv

# -------------------------------------------------------------------------------------------------
# Install dev tools
# -------------------------------------------------------------------------------------------------

RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
    clang-format-$CLANG_VERSION \
    clang-tidy-$CLANG_VERSION \
    clangd-$CLANG_VERSION \
    lldb-$CLANG_VERSION \
    cmake-format \
    doxygen \
    vim \
    && rm -rf /var/lib/apt/lists/*

# -------------------------------------------------------------------------------------------------
# Install configuration dependencies
# -------------------------------------------------------------------------------------------------

RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
    libpng-dev \
    libfreetype-dev \
    libtinyxml2-dev \
    && rm -rf /var/lib/apt/lists/*

# -------------------------------------------------------------------------------------------------
# Install build dependencies
# -------------------------------------------------------------------------------------------------

RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
    libgl1-mesa-dev \
    && rm -rf /var/lib/apt/lists/*

# -------------------------------------------------------------------------------------------------
# Install dependencies
# -------------------------------------------------------------------------------------------------

COPY --from=catch2-builder /out /usr/local
COPY --from=cpptrace-builder /out /usr/local
COPY --from=fmt-builder /out /usr/local
COPY --from=magic_enum-builder /out /usr/local
COPY --from=box2d-builder /out /usr/local
COPY --from=entt-builder /out /usr/local
COPY --from=glfw-builder /out /usr/local
COPY --from=glm-builder /out /usr/local
COPY --from=glslang-builder /out /usr/local
COPY --from=imgui-builder /out $DEPS_SOURCE_DIR/imgui
COPY --from=msdf-atlas-gen-builder /out /usr/local
COPY --from=stb-builder /out $DEPS_SOURCE_DIR/stb

ENV STB_SOURCE="$DEPS_SOURCE_DIR/stb"
ENV IMGUI_SOURCE="$DEPS_SOURCE_DIR/imgui"

# -------------------------------------------------------------------------------------------------
