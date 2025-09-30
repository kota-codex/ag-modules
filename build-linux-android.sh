#!/usr/bin/env bash
set -euo pipefail

# Update submodules
git submodule update --init --recursive

: "${VCPKG_ROOT:?Error: VCPKG_ROOT must be set to your vcpkg installation path}"
: "${ANDROID_NDK_HOME:=}"  # Required for Android builds

# Collect external modules
MODULES=$(find external -maxdepth 1 -mindepth 1 -type d -printf "%f\n")

# Triples as list of lists: triple;arch
TRIPLES=(
  "x64-linux;x86_64"
  "arm64-linux;arm64"
  "x64-android;x86_64"
  "arm64-android;arm64-v8a"
)

CONFIGS=(Release Debug)
GENERATOR="Ninja"

for module in $MODULES; do
  for tripleEntry in "${TRIPLES[@]}"; do
    IFS=";" read -r triple arch <<< "$tripleEntry"

    for config in "${CONFIGS[@]}"; do
      BUILD_DIR="build/${module}-${triple}-${config}"
      OUT_DIR="../../out/${module}"  # relative to build dir
      echo "Building module ${module} for triple: ${triple}, config: ${config} in ${BUILD_DIR}"
      mkdir -p "${BUILD_DIR}"

      CMAKE_ARGS=(
        -S "external/${module}"
        -B "${BUILD_DIR}"
        -G "${GENERATOR}"
        -DCMAKE_TOOLCHAIN_FILE="${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake"
        -DVCPKG_TARGET_TRIPLET="${triple}"
        -DCMAKE_BUILD_TYPE="${config}"
        -DAG_OUT_DIR="${OUT_DIR}"
        -DAG_TRIPLE="${triple}"
      )

      if [[ "$triple" == *"android"* ]]; then
        if [[ -z "${ANDROID_NDK_HOME}" ]]; then
          echo "Error: ANDROID_NDK_HOME must be set for Android builds"
          exit 1
        fi
        CMAKE_ARGS+=(
          "-DCMAKE_SYSTEM_NAME=Android"
          "-DCMAKE_ANDROID_NDK=${ANDROID_NDK_HOME}"
          "-DCMAKE_ANDROID_ARCH_ABI=${arch}"
          "-DCMAKE_SYSTEM_VERSION=21"
        )
      fi

      cmake "${CMAKE_ARGS[@]}"
      cmake --build "${BUILD_DIR}" --parallel "$(nproc || echo 4)"
    done
  done
done
