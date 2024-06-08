#!/bin/bash
set -ex

declare -a CUDA_CONFIG_ARGS
if [ ${cuda_compiler_version} != "None" ]; then
    # for documentation see e.g.
    # docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html#building-for-maximum-compatibility
    # docs.nvidia.com/cuda/cuda-compiler-driver-nvcc/index.html#ptxas-options-gpu-name
    # docs.nvidia.com/cuda/cuda-compiler-driver-nvcc/index.html#gpu-feature-list

    # for -real vs. -virtual, see cmake.org/cmake/help/latest/prop_tgt/CUDA_ARCHITECTURES.html
    # this is to support PTX JIT compilation; see first link above or cf.
    # devblogs.nvidia.com/cuda-pro-tip-understand-fat-binaries-jit-caching

    if [[ ${cuda_compiler_version} == 11.8 ]]; then
        export CMAKE_CUDA_ARCHS="53-real;62-real;72-real;75-real;80-real;86-real;89"
    elif [[ ${cuda_compiler_version} == 12.0 ]]; then
        export CMAKE_CUDA_ARCHS="53-real;62-real;72-real;75-real;80-real;86-real;89-real;90"
    fi

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
