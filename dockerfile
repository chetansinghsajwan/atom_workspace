FROM chetansinghsajwan/cmake-dev AS base

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
ARG ZLIB_VERSION="1.3.1"
ARG PNG_VERSION="1.6.46"
ARG FREETYPE_VERSION="VER-2-13-3"
ARG TINYXML2_VERSION="10.0.0"
ARG MSDF_ATLAS_GEN_VERSION="1.3"
ARG STB_VERSION="master"
ARG INSTALL_DIR="/out"
ARG TOOLCHAIN_LIST="linux-amd64 win-i686 win-amd64 win-armv7 win-aarch64"

ENV CMAKE_GENERATOR="Ninja"

# -------------------------------------------------------------------------------------------------
# Install catch2, required by
# - atom_core
# -------------------------------------------------------------------------------------------------

FROM base AS catch2-builder

RUN git clone "https://github.com/catchorg/catch2.git" . \
    --depth 1 --branch v$CATCH2_VERSION \
    && mkdir build \
    && cd build \
    && for TOOLCHAIN in $TOOLCHAIN_LIST; do \
    echo "Building for $TOOLCHAIN..." \
    && cmake .. \
    -D CMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN_DIR/toolchain-$TOOLCHAIN.cmake \
    && cmake --build . \
    && cmake --install . --prefix $INSTALL_DIR/$TOOLCHAIN \
    && rm -rf * \
    ; done

# -------------------------------------------------------------------------------------------------
# Install cpptrace, required by
# - atom_core
# -------------------------------------------------------------------------------------------------

FROM base AS cpptrace-builder

RUN echo $CPPTRACE_VERSION && git clone "https://github.com/jeremy-rifkin/cpptrace.git" . \
    --depth 1 --branch v$CPPTRACE_VERSION \
    && mkdir build \
    && cd build \
    && for TOOLCHAIN in $TOOLCHAIN_LIST; do \
    echo "Building for $TOOLCHAIN..." \
    && cmake .. \
    -D CMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN_DIR/toolchain-$TOOLCHAIN.cmake \
    && cmake --build . \
    && cmake --install . --prefix $INSTALL_DIR/$TOOLCHAIN \
    && rm -rf * \
    ; done

# -------------------------------------------------------------------------------------------------
# Install fmt, required by
# - atom_core
# -------------------------------------------------------------------------------------------------

FROM base AS fmt-builder

RUN git clone "https://github.com/fmtlib/fmt.git" . \
    --depth 1 --branch $FMT_VERSION \
    && mkdir build \
    && cd build \
    && for TOOLCHAIN in $TOOLCHAIN_LIST; do \
    echo "Building for $TOOLCHAIN..." \
    && cmake .. \
    -D CMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN_DIR/toolchain-$TOOLCHAIN.cmake \
    && cmake --build . --target fmt \
    && cmake --install . --prefix $INSTALL_DIR/$TOOLCHAIN \
    && rm -rf * \
    ; done

# -------------------------------------------------------------------------------------------------
# Install magic_enum, required by
# - atom_core
# -------------------------------------------------------------------------------------------------

FROM base AS magic_enum-builder

# No need to build magic_enum, it is header only
RUN git clone "https://github.com/neargye/magic_enum.git" . \
    --depth 1 --branch v$MAGIC_ENUM_VERSION \
    && mkdir build \
    && cd build \
    && for TOOLCHAIN in $TOOLCHAIN_LIST; do \
    echo "Building for $TOOLCHAIN..." \
    && cmake .. \
    -D CMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN_DIR/toolchain-$TOOLCHAIN.cmake \
    && cmake --install . --prefix $INSTALL_DIR/$TOOLCHAIN \
    && rm -rf * \
    ; done

# -------------------------------------------------------------------------------------------------
# Install box2d, required by
# - atom_engine
# -------------------------------------------------------------------------------------------------

FROM base AS box2d-builder

RUN git clone "https://github.com/erincatto/box2d.git" . \
    --depth 1 --branch v$BOX2D_VERSION \
    && mkdir build \
    && cd build \
    && for TOOLCHAIN in $TOOLCHAIN_LIST; do \
    echo "Building for $TOOLCHAIN..." \
    && cmake .. \
    -D CMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN_DIR/toolchain-$TOOLCHAIN.cmake \
    -D BOX2D_BUILD_UNIT_TESTS=OFF \
    -D BOX2D_BUILD_TESTBED=OFF \
    -D BOX2D_BUILD_DOCS=OFF \
    -D BOX2D_USER_SETTINGS=OFF \
    -D BUILD_SHARED_LIBS=OFF \
    && cmake --build . \
    && cmake --install . --prefix $INSTALL_DIR/$TOOLCHAIN \
    && rm -rf * \
    ; done

# -------------------------------------------------------------------------------------------------
# Install entt, required by
# - atom_engine
# -------------------------------------------------------------------------------------------------

FROM base AS entt-builder

RUN git clone "https://github.com/skypjack/entt.git" . \
    --depth 1 --branch v$ENTT_VERSION \
    && rm -r build \
    && mkdir build \
    && cd build \
    && for TOOLCHAIN in $TOOLCHAIN_LIST; do \
    echo "Building for $TOOLCHAIN..." \
    && cmake .. \
    -D CMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN_DIR/toolchain-$TOOLCHAIN.cmake \
    && cmake --build . \
    && cmake --install . --prefix $INSTALL_DIR/$TOOLCHAIN \
    && rm -rf * \
    ; done

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

RUN git clone "https://github.com/glfw/glfw.git" . \
    --depth 1 --branch $GLFW_VERSION \
    && mkdir build \
    && cd build \
    && for TOOLCHAIN in $TOOLCHAIN_LIST; do \
    echo "Building for $TOOLCHAIN..." \
    && cmake .. \
    -D CMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN_DIR/toolchain-$TOOLCHAIN.cmake \
    -D GLFW_BUILD_X11=OFF \
    -D GLFW_BUILD_WAYLAND=ON \
    && cmake --build . --target glfw \
    && cmake --install . --prefix $INSTALL_DIR/$TOOLCHAIN \
    && rm -rf * \
    ; done

# -------------------------------------------------------------------------------------------------
# Install glm, required by
# - atom_engine
# -------------------------------------------------------------------------------------------------

FROM base AS glm-builder

RUN git clone "https://github.com/g-truc/glm.git" . \
    --depth 1 --branch $GLM_VERSION \
    && mkdir build \
    && cd build \
    && for TOOLCHAIN in $TOOLCHAIN_LIST; do \
    echo "Building for $TOOLCHAIN..." \
    && cmake .. \
    -D CMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN_DIR/toolchain-$TOOLCHAIN.cmake \
    -D GLM_ENABLE_CXX_20=ON \
    -D GLM_ENABLE_LANG_EXTENSIONS=ON \
    && cmake --build . \
    && cmake --install . --prefix $INSTALL_DIR/$TOOLCHAIN \
    && rm -rf * \
    ; done

# -------------------------------------------------------------------------------------------------
# Install glslang, required by
# - atom_engine
# -------------------------------------------------------------------------------------------------

FROM base AS glslang-builder

RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
    python3 \
    && rm -rf /var/lib/apt/lists/*

RUN git clone "https://github.com/KhronosGroup/glslang.git" . \
    --depth 1 --branch $GLSLANG_VERSION \
    && ./update_glslang_sources.py \
    && mkdir build \
    && cd build \
    && for TOOLCHAIN in $TOOLCHAIN_LIST; do \
    echo "Building for $TOOLCHAIN..." \
    && cmake .. \
    -D CMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN_DIR/toolchain-$TOOLCHAIN.cmake \
    && cmake --build . \
    && cmake --install . --prefix $INSTALL_DIR/$TOOLCHAIN \
    && rm -rf * \
    ; done

# -------------------------------------------------------------------------------------------------
# Install imgui, required by
# - atom_engine
# -------------------------------------------------------------------------------------------------

FROM base AS imgui-builder

RUN git clone "https://github.com/ocornut/imgui.git" $INSTALL_DIR/src/imgui \
    --depth 1 --branch $IMGUI_VERSION

# -------------------------------------------------------------------------------------------------
# Install zlib, required by
# - png
# - freetype
# -------------------------------------------------------------------------------------------------

FROM base AS zlib-builder

RUN git clone "https://github.com/madler/zlib.git" . \
    --depth 1 --branch v$ZLIB_VERSION \
    && mkdir build \
    && cd build \
    && for TOOLCHAIN in $TOOLCHAIN_LIST; do \
    echo "Building for $TOOLCHAIN..." \
    && cmake .. \
    -D CMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN_DIR/toolchain-$TOOLCHAIN.cmake \
    -D CMAKE_INSTALL_PREFIX=$INSTALL_DIR/$TOOLCHAIN \
    && cmake --build . \
    && cmake --install . \
    && rm -rf * \
    ; done

# Remove the dynamic library
RUN rm -f /out/lib/libzlib.dll.a

# -------------------------------------------------------------------------------------------------
# Install png, required by
# - freetype
# - msdf-atlas-gen
# -------------------------------------------------------------------------------------------------

FROM base AS png-builder

COPY --from=zlib-builder $INSTALL_DIR /usr/local

RUN git clone "https://github.com/pnggroup/libpng.git" . \
    --depth 1 --branch v$PNG_VERSION \
    && mkdir build \
    && cd build \
    && for TOOLCHAIN in $TOOLCHAIN_LIST; do \
    echo "Building for $TOOLCHAIN..." \
    && cmake .. \
    -D CMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN_DIR/toolchain-$TOOLCHAIN.cmake \
    -D PNG_STATIC=ON \
    -D PNG_SHARED=OFF \
    -D PNG_TESTS=OFF \
    && cmake --build . \
    && cmake --install . --prefix $INSTALL_DIR/$TOOLCHAIN \
    && rm -rf * \
    ; done

# -------------------------------------------------------------------------------------------------
# Install freetype, required by
# - msdf-atlas-gen
# -------------------------------------------------------------------------------------------------

FROM base AS freetype-builder

COPY --from=png-builder $INSTALL_DIR /usr/local
COPY --from=zlib-builder $INSTALL_DIR /usr/local

RUN git clone "https://github.com/freetype/freetype.git" . \
    --depth 1 --branch $FREETYPE_VERSION \
    && mkdir build \
    && cd build \
    && for TOOLCHAIN in $TOOLCHAIN_LIST; do \
    echo "Building for $TOOLCHAIN..." \
    && cmake .. \
    -D CMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN_DIR/toolchain-$TOOLCHAIN.cmake \
    -D BUILD_SHARED_LIBS=OFF \
    && cmake --build . \
    && cmake --install . --prefix $INSTALL_DIR/$TOOLCHAIN \
    && rm -rf * \
    ; done

# -------------------------------------------------------------------------------------------------
# Install tinyxml2, required by
# - msdf-atlas-gen
# -------------------------------------------------------------------------------------------------

FROM base AS tinyxml2-builder

RUN git clone "https://github.com/leethomason/tinyxml2.git" . \
    --depth 1 --branch v$TINYXML2_VERSION \
    && mkdir build \
    && cd build \
    && for TOOLCHAIN in $TOOLCHAIN_LIST; do \
    echo "Building for $TOOLCHAIN..." \
    && cmake .. \
    -D CMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN_DIR/toolchain-$TOOLCHAIN.cmake \
    && cmake --build . \
    && cmake --install . --prefix $INSTALL_DIR/$TOOLCHAIN \
    && rm -rf * \
    ; done

# -------------------------------------------------------------------------------------------------
# Install msdf-atlas-gen, required by
# - atom_engine
# -------------------------------------------------------------------------------------------------

FROM base AS msdf-atlas-gen-builder

COPY --from=zlib-builder $INSTALL_DIR /usr/local
COPY --from=png-builder $INSTALL_DIR /usr/local
COPY --from=freetype-builder $INSTALL_DIR /usr/local
COPY --from=tinyxml2-builder $INSTALL_DIR /usr/local

RUN git clone "https://github.com/Chlumsky/msdf-atlas-gen.git" . \
    --depth 1 --branch v$MSDF_ATLAS_GEN_VERSION --recurse-submodules \
    && mkdir build \
    && cd build \
    && for TOOLCHAIN in $TOOLCHAIN_LIST; do \
    echo "Building for $TOOLCHAIN..." \
    && cmake .. \
    -D CMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN_DIR/toolchain-$TOOLCHAIN.cmake \
    -D MSDF_ATLAS_USE_VCPKG=OFF \
    -D MSDF_ATLAS_USE_SKIA=OFF \
    -D MSDF_ATLAS_BUILD_STANDALONE=OFF \
    -D MSDF_ATLAS_INSTALL=ON \
    && cmake --build . \
    && cmake --install . --prefix $INSTALL_DIR/$TOOLCHAIN \
    && rm -rf * \
    ; done

# -------------------------------------------------------------------------------------------------
# Install stb, required by
# - atom_engine
# -------------------------------------------------------------------------------------------------

FROM base AS stb-builder

RUN git clone "https://github.com/nothings/stb.git" $INSTALL_DIR/src/stb \
    --depth 1 --branch $STB_VERSION

# -------------------------------------------------------------------------------------------------
# Development environment
# -------------------------------------------------------------------------------------------------

FROM base AS dev

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
# Install build dependencies
# -------------------------------------------------------------------------------------------------

RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
    libgl1-mesa-dev \
    && rm -rf /var/lib/apt/lists/*

# -------------------------------------------------------------------------------------------------
# Install dependencies
# -------------------------------------------------------------------------------------------------

COPY --from=catch2-builder $INSTALL_DIR /usr/local
COPY --from=cpptrace-builder $INSTALL_DIR /usr/local
COPY --from=fmt-builder $INSTALL_DIR /usr/local
COPY --from=magic_enum-builder $INSTALL_DIR /usr/local
COPY --from=box2d-builder $INSTALL_DIR /usr/local
COPY --from=entt-builder $INSTALL_DIR /usr/local
COPY --from=glfw-builder $INSTALL_DIR /usr/local
COPY --from=glm-builder $INSTALL_DIR /usr/local
COPY --from=glslang-builder $INSTALL_DIR /usr/local
COPY --from=imgui-builder $INSTALL_DIR /usr/local
COPY --from=zlib-builder $INSTALL_DIR /usr/local
COPY --from=png-builder $INSTALL_DIR /usr/local
COPY --from=freetype-builder $INSTALL_DIR /usr/local
COPY --from=tinyxml2-builder $INSTALL_DIR /usr/local
COPY --from=msdf-atlas-gen-builder $INSTALL_DIR /usr/local
COPY --from=stb-builder $INSTALL_DIR /usr/local
