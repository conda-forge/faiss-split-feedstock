# function for facilitate version comparison; cf. https://stackoverflow.com/a/37939589
function version2int { echo "$@" | awk -F. '{ printf("%d%02d\n", $1, $2); }'; }

set -e

declare -a CUDA_CONFIG_ARGS
if [ ${cuda_compiler_version} != "None" ]; then
    # for documentation see e.g.
    # docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html#building-for-maximum-compatibility
    # docs.nvidia.com/cuda/cuda-compiler-driver-nvcc/index.html#ptxas-options-gpu-name
    # docs.nvidia.com/cuda/cuda-compiler-driver-nvcc/index.html#gpu-feature-list

    # the following are all the x86-relevant gpu arches; for building aarch64-packages, add: 53, 62, 72
    ARCHES=(52 60 61 70)
    # cuda 11.0 deprecates arches 35, 50
    DEPRECATED_IN_11=(35 50)
    if [ $(version2int $cuda_compiler_version) -ge $(version2int "11.1") ]; then
        # Ampere support for GeForce 30 (sm_86) needs cuda >= 11.1
        LATEST_ARCH=86
        # ARCHES does not contain LATEST_ARCH; see usage below
        ARCHES=( "${ARCHES[@]}" 75 80 )
    elif [ $(version2int $cuda_compiler_version) -ge $(version2int "11.0") ]; then
        # Ampere support for A100 (sm_80) needs cuda >= 11.0
        LATEST_ARCH=80
        ARCHES=( "${ARCHES[@]}" 75 )
    elif [ $(version2int $cuda_compiler_version) -ge $(version2int "10.0") ]; then
        # Turing support (sm_75) needs cuda >= 10.0
        LATEST_ARCH=75
        ARCHES=( "${DEPRECATED_IN_11[@]}" "${ARCHES[@]}" )
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

    # Acc. to https://cmake.org/cmake/help/v3.19/module/FindCUDAToolkit.html#search-behavior
    # CUDA toolkit is search relative to `nvcc` first before considering
    # "-DCUDAToolkit_ROOT=${CUDA_HOME}". We have multiple workarounds:
    #   - Add symlinks from ${CUDA_HOME} to ${BUILD_PREFIX}
    #   - Add ${CUDA_HOME}/bin to ${PATH}
    #   - Remove `nvcc` wrapper in ${BUILD_PREFIX} so that `nvcc` from ${CUDA_HOME} gets found.
    # TODO: Fix this in nvcc-feedstock or cmake-feedstock.
    # NOTE: It's okay for us to not use the wrapper since CMake adds -ccbin itself.
    rm "${BUILD_PREFIX}/bin/nvcc"
else
    FAISS_ENABLE_GPU="OFF"
fi

if [[ $target_platform == osx-* ]] && [[ $CF_FAISS_BUILD == avx2 ]]; then
    # OSX CI has no AVX2 support
    BUILD_TESTING="OFF"
else
    BUILD_TESTING="ON"
fi

# Build version depending on $CF_FAISS_BUILD (either "generic" or "avx2")
cmake -B _build_${CF_FAISS_BUILD} \
      -DBUILD_SHARED_LIBS=ON \
      -DBUILD_TESTING=${BUILD_TESTING} \
      -DFAISS_OPT_LEVEL=${CF_FAISS_BUILD} \
      -DFAISS_ENABLE_PYTHON=OFF \
      -DFAISS_ENABLE_GPU=${FAISS_ENABLE_GPU} \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_LIBDIR=lib \
      ${CUDA_CONFIG_ARGS+"${CUDA_CONFIG_ARGS[@]}"} \
      .

if [[ $CF_FAISS_BUILD == avx2 ]]; then
    TARGET="faiss_avx2"
else
    TARGET="faiss"
fi

cmake --build _build_${CF_FAISS_BUILD} --target ${TARGET} -j $CPU_COUNT
cmake --install _build_${CF_FAISS_BUILD} --prefix $PREFIX
cmake --install _build_${CF_FAISS_BUILD} --prefix _libfaiss_${CF_FAISS_BUILD}_stage/
