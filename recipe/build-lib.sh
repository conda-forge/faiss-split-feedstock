# function for facilitate version comparison; cf. https://stackoverflow.com/a/37939589
function version2int { echo "$@" | awk -F. '{ printf("%d%02d\n", $1, $2); }'; }

set -e

declare -a CUDA_CONFIG_ARGS
if [ ${cuda_compiler_version} != "None" ]; then
    # for documentation see e.g.
    # docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html#building-for-maximum-compatibility
    # docs.nvidia.com/cuda/cuda-toolkit-release-notes/index.html#major-components__table-cuda-toolkit-driver-versions
    # docs.nvidia.com/cuda/cuda-compiler-driver-nvcc/index.html#gpu-feature-list

    # the following are all the x86-relevant gpu arches; for building aarch64-packages, add: 53, 62, 72
    ARCHES=(35 50 52 60 61 70)
    LATEST_ARCH=70
    if [ $(version2int $cuda_compiler_version) -ge $(version2int "10.0") ]; then
        # cuda >= 10.0 supports Turing (sm_75)
        ARCHES+=(75)
        LATEST_ARCH=75
    fi
    if [ $(version2int $cuda_compiler_version) -ge $(version2int "11.0") ]; then
        # cuda >= 11.0 supports Ampere (sm_80)
        ARCHES+=(80)
        LATEST_ARCH=80
    fi
    for arch in "${ARCHES[@]}"; do
        CMAKE_CUDA_ARCHS="${CMAKE_CUDA_ARCHS+${CMAKE_CUDA_ARCHS};}${arch}-virtual"
    done
    # to support PTX JIT compilation; see first link above or cf.
    # devblogs.nvidia.com/cuda-pro-tip-understand-fat-binaries-jit-caching
    # see also cmake.org/cmake/help/latest/prop_tgt/CUDA_ARCHITECTURES.html
    CMAKE_CUDA_ARCHS="${CMAKE_CUDA_ARCHS+${CMAKE_CUDA_ARCHS};}${LATEST_ARCH}-real"

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

# Build vanilla version (no avx)
cmake -B _build_generic \
      -DBUILD_SHARED_LIBS=ON \
      -DBUILD_TESTING=ON \
      -DFAISS_ENABLE_PYTHON=OFF \
      -DFAISS_ENABLE_GPU=${FAISS_ENABLE_GPU} \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_LIBDIR=lib \
      ${CUDA_CONFIG_ARGS+"${CUDA_CONFIG_ARGS[@]}"} \
      .

cmake --build _build_generic -j $CPU_COUNT
cmake --install _build_generic --prefix $PREFIX
