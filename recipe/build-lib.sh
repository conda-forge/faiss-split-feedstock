#!/bin/bash
set -ex

# function for facilitate version comparison; cf. https://stackoverflow.com/a/37939589
function version2int { echo "$@" | awk -F. '{ printf("%d%02d\n", $1, $2); }'; }

declare -a CUDA_CONFIG_ARGS
if [ ${cuda_compiler_version} != "None" ]; then
    # for documentation see e.g.
    # docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html#building-for-maximum-compatibility
    # docs.nvidia.com/cuda/cuda-compiler-driver-nvcc/index.html#ptxas-options-gpu-name
    # docs.nvidia.com/cuda/cuda-compiler-driver-nvcc/index.html#gpu-feature-list

    ARCHES=(53 62 72)
    if [ $(version2int $cuda_compiler_version) -ge $(version2int "11.8") ]; then
        # Hopper support for H100 (sm_90) needs cuda >= 11.8
        LATEST_ARCH=90
        # ARCHES does not contain LATEST_ARCH; see usage below
        ARCHES=( "${ARCHES[@]}" 75 80 86)
    elif [ $(version2int $cuda_compiler_version) -ge $(version2int "11.1") ]; then
        # Ampere support for GeForce 30 (sm_86) needs cuda >= 11.1
        LATEST_ARCH=86
        # ARCHES does not contain LATEST_ARCH; see usage below
        ARCHES=( "${ARCHES[@]}" 75 80 )
    elif [ $(version2int $cuda_compiler_version) -ge $(version2int "11.0") ]; then
        # Ampere support for A100 (sm_80) needs cuda >= 11.0
        LATEST_ARCH=80
        ARCHES=( "${ARCHES[@]}" 75 )
    fi
    for arch in "${ARCHES[@]}"; do
        CMAKE_CUDA_ARCHS="${CMAKE_CUDA_ARCHS+${CMAKE_CUDA_ARCHS};}${arch}-real"
    done
    # for -real vs. -virtual, see cmake.org/cmake/help/latest/prop_tgt/CUDA_ARCHITECTURES.html
    # this is to support PTX JIT compilation; see first link above or cf.
    # devblogs.nvidia.com/cuda-pro-tip-understand-fat-binaries-jit-caching
    CMAKE_CUDA_ARCHS="${CMAKE_CUDA_ARCHS+${CMAKE_CUDA_ARCHS};}${LATEST_ARCH}"

    FAISS_ENABLE_GPU="ON"
    CUDA_CONFIG_ARGS+=(
        -DCMAKE_CUDA_ARCHITECTURES="${CMAKE_CUDA_ARCHS}"
    )
    # cmake does not generate output for the call below; echo some info
    echo "Set up extra cmake-args: CUDA_CONFIG_ARGS=${CUDA_CONFIG_ARGS+"${CUDA_CONFIG_ARGS[@]}"}"
else
    FAISS_ENABLE_GPU="OFF"
fi

if [[ $target_platform == osx-* ]] && [[ $CF_FAISS_BUILD == avx2 ]]; then
    # OSX CI has no AVX2 support
    BUILD_TESTING="OFF"
elif [[ $target_platform == osx-arm64 ]]; then
    # CI has no osx-arm64 machines; cannot test when only cross-compiling
    BUILD_TESTING="OFF"
else
    BUILD_TESTING="ON"
fi

# Build version depending on $CF_FAISS_BUILD (either "generic" or "avx2")
cmake -G Ninja \
    ${CMAKE_ARGS} \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_TESTING=${BUILD_TESTING} \
    -DFAISS_OPT_LEVEL=${CF_FAISS_BUILD} \
    -DFAISS_ENABLE_PYTHON=OFF \
    -DFAISS_ENABLE_GPU=${FAISS_ENABLE_GPU} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_LIBDIR=lib \
    ${CUDA_CONFIG_ARGS+"${CUDA_CONFIG_ARGS[@]}"} \
    -B _build_${CF_FAISS_BUILD} \
    .

if [[ $CF_FAISS_BUILD == avx2 ]]; then
    TARGET="faiss_avx2"
else
    TARGET="faiss"
fi

cmake --build _build_${CF_FAISS_BUILD} --target ${TARGET} -j $CPU_COUNT
cmake --install _build_${CF_FAISS_BUILD} --prefix $PREFIX
cmake --install _build_${CF_FAISS_BUILD} --prefix _libfaiss_${CF_FAISS_BUILD}_stage/
