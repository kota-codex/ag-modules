#!/bin/bash

# To be replaced with github actions soon.

git submodule update --init --recursive

: "${VCPKG_ROOT:?Error: VCPKG_ROOT must be set to your vcpkg installation path}"
: "${ANDROID_NDK_HOME:=}"  # Optional but required for Android builds

MODULES=$(find external -maxdepth 1 -mindepth 1 -type d -printf "%f\n")

TRIPLES=(
#  x64-windows
#  arm64-windows
  x64-linux
#  arm64-linux
#  x64-osx
#  arm64-osx
#  arm64-ios
#  x64-ios
#  arm64-android
#  x64-android
)

CONFIGS=(Release Debug)

GENERATOR="Ninja"

for module in $MODULES; do
  for triple in "${TRIPLES[@]}"; do
    for config in "${CONFIGS[@]}"; do
      BUILD_DIR="build/${module}-${triple}-${config}"
      OUT_DIR="../../out/${module}"  # relative to build dir
      echo "Building module ${module} for triple: ${triple}, config: ${config} in ${BUILD_DIR}"

      mkdir -p "${BUILD_DIR}"

      cmake -S "external/${module}" -B "${BUILD_DIR}" -G "${GENERATOR}" \
        -DCMAKE_TOOLCHAIN_FILE="${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake" \
        -DVCPKG_TARGET_TRIPLET="${triple}" \
        -DCMAKE_BUILD_TYPE="${config}" \
        -DAG_OUT_DIR="${OUT_DIR}" \
        -DAG_TRIPLE="${triple}"
      cmake --build "${BUILD_DIR}" --parallel "$(nproc || sysctl -n hw.logicalcpu || echo 4)"
    done
  done
done

echo "All builds completed. Outputs are in each build-*/out/<module>/<triple>/<config>/"
