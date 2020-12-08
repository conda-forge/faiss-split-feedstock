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

# Build vanilla version (no avx2), see build-lib.sh
# Do not use the Python3_* variants for cmake
cmake -B _build_python \
      -Dfaiss_ROOT=${PREFIX}\
      -DFAISS_ENABLE_GPU=${FAISS_ENABLE_GPU} \
      -DCMAKE_BUILD_TYPE=Release \
      -DPython_EXECUTABLE="${PYTHON}" \
      faiss/python

cmake --build _build_python -j $CPU_COUNT

# Build actual python module.
pushd _build_python
$PYTHON setup.py install --single-version-externally-managed --record=record.txt --prefix=$PREFIX
popd
# clean up cmake-cache between builds
rm -r _build_python
