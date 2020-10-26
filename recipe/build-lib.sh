# function for facilitate version comparison; cf. https://stackoverflow.com/a/37939589
function version2int { echo "$@" | awk -F. '{ printf("%d%02d\n", $1, $2); }'; }

set -e

CUDA_CONFIG_ARG=""
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
        CUDA_ARCHS="${CUDA_ARCHS} ${arch}-virtual";
    done
    # to support PTX JIT compilation; see first link above or cf.
    # devblogs.nvidia.com/cuda-pro-tip-understand-fat-binaries-jit-caching
    # see also cmake.org/cmake/help/latest/prop_tgt/CUDA_ARCHITECTURES.html
    CUDA_ARCHS="${CUDA_ARCHS} ${LATEST_ARCH}-real"

    FAISS_ENABLE_GPU="ON"
    CUDA_CONFIG_ARG="-DCMAKE_CUDA_ARCHITECTURES=\"${CUDA_ARCHS}\" "
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
      ${CUDA_CONFIG_ARG} \
      .

cmake --build _build_generic -j $CPU_COUNT
cmake --install _build_generic --prefix $PREFIX
