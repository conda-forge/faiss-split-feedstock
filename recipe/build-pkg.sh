#!/bin/bash
set -ex

FAISS_ENABLE_GPU=""
if [ ${cuda_compiler_version} != "None" ]; then
    FAISS_ENABLE_GPU="ON"
else
    FAISS_ENABLE_GPU="OFF"
fi

# see https://github.com/swig/swig/issues/568
if [[ "${target_platform}" == linux-* ]]; then
    export CXXFLAGS="$CXXFLAGS -DSWIGWORDSIZE64"
fi

# Build vanilla version (no avx2), see build-lib.sh
cmake -G Ninja \
    ${CMAKE_ARGS} \
    -Dfaiss_ROOT=_libfaiss_stage/ \
    -DCMAKE_BUILD_TYPE=Release \
    -DPython_NumPy_INCLUDE_DIR=$SP_DIR/numpy/core/include \
    -B _build_python \
    faiss/python
cmake --build _build_python --target swigfaiss -j $CPU_COUNT

# Build actual python module.
pushd _build_python
$PYTHON setup.py install --single-version-externally-managed --record=record.txt --prefix=$PREFIX
popd
# clean up cmake-cache between builds
rm -r _build_python
