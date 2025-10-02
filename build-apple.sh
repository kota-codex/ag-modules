#!/usr/bin/env bash
set -euo pipefail

# Update submodules
git submodule update --init --recursive

: "${VCPKG_ROOT:?Error: VCPKG_ROOT must be set to your vcpkg installation path}"

# Collect extern modules
MODULES=$(find extern -maxdepth 1 -mindepth 1 -type d -printf "%f\n")

# Triples as: triple;arch;sysroot
TRIPLES=(
  "x64-osx;x86_64;macosx"
  "arm64-osx;arm64;macosx"
  "x64-ios;x86_64;iphonesimulator"
  "arm64-ios;arm64;iphoneos"
)

CONFIGS=(Release Debug)
GENERATOR="Ninja"

for module in $MODULES; do
  for tripleEntry in "${TRIPLES[@]}"; do
    IFS=";" read -r triple arch sysroot <<< "$tripleEntry"

    for config in "${CONFIGS[@]}"; do
      BUILD_DIR="build/${module}-${triple}"
      OUT_DIR="../../out/${module}"  # relative to build dir
      echo "Building module ${module} for triple: ${triple}, config: ${config} in ${BUILD_DIR}"
      mkdir -p "${BUILD_DIR}"

      cmake -S "external/${module}" -B "${BUILD_DIR}" -G "${GENERATOR}" \
        -DCMAKE_TOOLCHAIN_FILE="${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake" \
        -DVCPKG_TARGET_TRIPLET="${triple}" \
        -DCMAKE_BUILD_TYPE="${config}" \
        -DAG_OUT_DIR="${OUT_DIR}" \
        -DAG_TRIPLE="${triple}" \
        -DCMAKE_OSX_ARCHITECTURES="${arch}" \
        -DCMAKE_OSX_SYSROOT="${sysroot}"

      cmake --build "${BUILD_DIR}" --parallel "$(sysctl -n hw.logicalcpu)"
    done
  done
done
