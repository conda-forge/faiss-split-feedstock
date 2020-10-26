# function for facilitate version comparison; cf. https://stackoverflow.com/a/37939589
function version2int { echo "$@" | awk -F. '{ printf("%d%02d\n", $1, $2); }'; }

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
        CUDA_ARCH="${CUDA_ARCH} -gencode=arch=compute_${arch},code=sm_${arch}";
    done
    # to support PTX JIT compilation; see first link above or cf.
    # devblogs.nvidia.com/cuda-pro-tip-understand-fat-binaries-jit-caching
    CUDA_ARCH="${CUDA_ARCH} -gencode=arch=compute_${LATEST_ARCH},code=compute_${LATEST_ARCH}"

    CUDA_CONFIG_ARG="--with-cuda=${CUDA_HOME}"
else
    CUDA_CONFIG_ARG="--without-cuda"
fi

# Build vanilla version (no avx)
./configure --prefix=${PREFIX} --exec-prefix=${PREFIX} \
  --with-blas=-lblas --with-lapack=-llapack \
  ${CUDA_CONFIG_ARG} --with-cuda-arch="${CUDA_ARCH}" || exit 1

# make sets SHAREDEXT correctly for linux/osx
make install

# make builds libfaiss.a & libfaiss.so; we only want the latter
rm ${PREFIX}/lib/libfaiss.a
