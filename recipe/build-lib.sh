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
    elif [[ ${cuda_compiler_version} == 12.* ]]; then
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

mkdir build
cd build

cmake -G Ninja \
    ${CMAKE_ARGS} \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_TESTING=${BUILD_TESTING} \
    -DFAISS_ENABLE_PYTHON=OFF \
    -DFAISS_ENABLE_GPU=${FAISS_ENABLE_GPU} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_INSTALL_DATAROOTDIR="${PREFIX}/lib/cmake" \
    ${CUDA_CONFIG_ARGS+"${CUDA_CONFIG_ARGS[@]}"} \
    ..

cmake --build . --target "faiss" -j $CPU_COUNT
cmake --install . --prefix $PREFIX
cmake --install . --prefix _libfaiss_stage/
