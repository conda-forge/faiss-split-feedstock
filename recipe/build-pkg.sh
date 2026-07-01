#!/bin/bash
set -ex

FAISS_ENABLE_GPU=""
if [ "${cuda_compiler_version}" != "None" ]; then
    export FAISS_ENABLE_GPU="ON"
else
    export FAISS_ENABLE_GPU="OFF"
fi

if [[ "${target_platform}" == "osx-arm64" ]]; then
    export FAISS_ENABLE_METAL="ON"
else
    export FAISS_ENABLE_METAL="OFF"
fi

# see https://github.com/swig/swig/issues/568
if [[ "${target_platform}" == linux-* ]]; then
    export CXXFLAGS="$CXXFLAGS -DSWIGWORDSIZE64"
fi

mkdir build_python
pushd build_python

# Build vanilla version (no avx2), see build-lib.sh
Python_NumPy_INCLUDE_DIR="$(python -c 'import numpy; print(numpy.get_include())')"
cmake -G Ninja \
    ${CMAKE_ARGS} \
    -Dfaiss_ROOT=_libfaiss_stage/ \
    -DFAISS_ENABLE_GPU=${FAISS_ENABLE_GPU} \
    -DFAISS_ENABLE_METAL=${FAISS_ENABLE_METAL} \
    -DCMAKE_BUILD_TYPE=Release \
    -DPython_NumPy_INCLUDE_DIR=${Python_NumPy_INCLUDE_DIR} \
    ../faiss/python

cmake --build . --target swigfaiss faiss_example_external_module -j $CPU_COUNT

# Build actual python module.
$PYTHON setup.py install --single-version-externally-managed --record=record.txt --prefix=$PREFIX

popd
# clean up cmake-cache between builds
rm -r build_python
