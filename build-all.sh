#!/bin/bash

# Unused. Use github ctions instead.

set -e  # Exit on error

# Ensure required env vars are set (adjust defaults as needed)
: "${VCPKG_ROOT:?Error: VCPKG_ROOT must be set to your vcpkg installation path}"
: "${ANDROID_NDK_HOME:=}"  # Optional but required for Android builds

# List of vcpkg triplets
TRIPLES=(
  x64-windows
  arm64-windows
  x64-linux
  arm64-linux
  x64-osx
  arm64-osx
  arm64-ios
  x64-ios
  arm64-android
  x64-android
)

# Configurations
CONFIGS=(Release Debug)

# Generator (Ninja for cross-platform consistency)
GENERATOR="Ninja"

for triple in "${TRIPLES[@]}"; do
  for config in "${CONFIGS[@]}"; do
    BUILD_DIR="build-${triple}-${config}"
    echo "Building all modules for triple: ${triple}, config: ${config} in ${BUILD_DIR}"

    mkdir -p "${BUILD_DIR}"
    pushd "${BUILD_DIR}"

    # Configure CMake on the superbuild root
    cmake .. \
      -G "${GENERATOR}" \
      -DCMAKE_TOOLCHAIN_FILE="${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake" \
      -DVCPKG_TARGET_TRIPLET="${triple}" \
      -DCMAKE_BUILD_TYPE="${config}" \
      -DAG_TRIPLE="${triple}"

    # Build all modules
    cmake --build . --parallel "$(nproc || sysctl -n hw.logicalcpu || echo 4)"

    popd
  done
done

echo "All builds completed. Outputs are in each build-*/out/<module>/<triple>/<config>/"