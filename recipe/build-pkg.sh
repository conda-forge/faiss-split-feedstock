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

PYTHON_LIB="${PREFIX}/lib/libpython${PY_VER}${SHLIB_EXT}"
PYTHON_INC="$PREFIX/include/python${PY_VER}"
NUMPY_INC=$(python -c 'import numpy;print(numpy.get_include())')

# Build vanilla version (no avx2), see build-lib.sh
cmake -G Ninja \
    ${CMAKE_ARGS} \
    -Dfaiss_ROOT=_libfaiss_stage/ \
    -DCMAKE_BUILD_TYPE=Release \
    -DPython_INCLUDE_DIRS="${PYTHON_INC}" \
    -DPython_LIBRARIES="${PYTHON_LIB}" \
    -DPython_NumPy_INCLUDE_DIRS=${NUMPY_INC} \
    -B _build_python \
    faiss/python
cmake --build _build_python --target swigfaiss -j $CPU_COUNT

# Build actual python module.
pushd _build_python
$PYTHON setup.py install --single-version-externally-managed --record=record.txt --prefix=$PREFIX
popd
# clean up cmake-cache between builds
rm -r _build_python
