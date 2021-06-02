set -e

FAISS_ENABLE_GPU=""
if [ ${cuda_compiler_version} != "None" ]; then
    FAISS_ENABLE_GPU="ON"
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

if [[ $CF_FAISS_BUILD == avx2 ]]; then
    TARGET="swigfaiss_avx2"
else
    TARGET="swigfaiss_avx2"
fi

# Build vanilla version (no avx2), see build-lib.sh
cmake -B _build_python_generic \
      -Dfaiss_ROOT=_libfaiss_generic_stage/ \
      -DFAISS_ENABLE_GPU=${FAISS_ENABLE_GPU} \
      -DCMAKE_BUILD_TYPE=Release \
      -DPython_EXECUTABLE="${PYTHON}" \
      faiss/python
cmake --build _build_python_generic --target ${TARGET} -j $CPU_COUNT

# Build version with avx2 support, see build-lib.sh
cmake -B _build_python_avx2 \
      -Dfaiss_ROOT=_libfaiss_avx2_stage/ \
      -DFAISS_OPT_LEVEL=avx2 \
      -DFAISS_ENABLE_GPU=${FAISS_ENABLE_GPU} \
      -DCMAKE_BUILD_TYPE=Release \
      -DPython_EXECUTABLE="${PYTHON}" \
      faiss/python
cmake --build _build_python_avx2 --target ${TARGET} -j $CPU_COUNT

# copy generated swig module with avx2-support to specifically named file, cf.
# https://github.com/facebookresearch/faiss/blob/v1.7.1/faiss/python/setup.py#L37-L40
cp _build_python_avx2/swigfaiss_avx2.py _build_python_generic/swigfaiss_avx2.py
cp _build_python_avx2/_swigfaiss_avx2.so _build_python_generic/_swigfaiss_avx2.so

# Build actual python module.
pushd _build_python_generic
$PYTHON setup.py install --single-version-externally-managed --record=record.txt --prefix=$PREFIX
popd
# clean up cmake-cache between builds
rm -r _build_python_generic
rm -r _build_python_avx2
