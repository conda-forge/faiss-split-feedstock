#!/bin/bash
set -ex

FAISS_ENABLE_GPU=""
if [ ${cuda_compiler_version} != "None" ]; then
    FAISS_ENABLE_GPU="ON"
else
    FAISS_ENABLE_GPU="OFF"
fi

# Build vanilla version (no avx2), see build-lib.sh
cmake -G Ninja \
    ${CMAKE_ARGS} \
    -Dfaiss_ROOT:PATH=_libfaiss_generic_stage/ \
    -DFAISS_ENABLE_GPU:BOOL=${FAISS_ENABLE_GPU} \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DPython_EXECUTABLE:PATH="${PREFIX}/bin/python" \
    -DPython_ROOT_DIR:PATH="${PREFIX}" \
    -DPython_INCLUDE_DIR:PATH=$(${PYTHON} -c 'from sysconfig import get_paths; print(get_paths()["include"])') \
    -DPython_INCLUDE_DIRS:PATH=$(${PYTHON} -c 'from sysconfig import get_paths; print(get_paths()["include"])') \
    -DPython_LIBRARY:PATH="${PREFIX}/lib/libpython${PY_VER}.dylib" \
    -DPython_LIBRARIES:PATH="${PREFIX}/lib/libpython${PY_VER}.dylib" \
    -DPython_NumPy_INCLUDE_DIR:PATH=$(${PYTHON} -c 'import numpy; print(numpy.get_include())') \
    -DPython_NumPy_INCLUDE_DIRS:PATH=$(${PYTHON} -c 'import numpy; print(numpy.get_include())') \
    -B _build_python_generic \
    faiss/python
cmake --build _build_python_generic --target swigfaiss -j $CPU_COUNT

# Build version with avx2 support, see build-lib.sh
if [[ "${target_platform}" == *-64 ]]; then
    cmake -G Ninja \
        ${CMAKE_ARGS} \
        -Dfaiss_ROOT:PATH=_libfaiss_avx2_stage/ \
        -DFAISS_OPT_LEVEL:STRING=avx2 \
        -DFAISS_ENABLE_GPU:BOOL=${FAISS_ENABLE_GPU} \
        -DCMAKE_BUILD_TYPE:STRING=Release \
        -DPython_EXECUTABLE:PATH="${PREFIX}/bin/python" \
        -DPython_ROOT_DIR:PATH="${PREFIX}" \
        -DPython_INCLUDE_DIR:PATH=$(${PYTHON} -c 'from sysconfig import get_paths; print(get_paths()["include"])') \
        -DPython_INCLUDE_DIRS:PATH=$(${PYTHON} -c 'from sysconfig import get_paths; print(get_paths()["include"])') \
        -DPython_LIBRARY:PATH="${PREFIX}/lib/libpython${PY_VER}.dylib" \
        -DPython_LIBRARIES:PATH="${PREFIX}/lib/libpython${PY_VER}.dylib" \
        -DPython_NumPy_INCLUDE_DIR:PATH=$(${PYTHON} -c 'import numpy; print(numpy.get_include())') \
        -DPython_NumPy_INCLUDE_DIRS:PATH=$(${PYTHON} -c 'import numpy; print(numpy.get_include())') \
        -B _build_python_avx2 \
        faiss/python
    cmake --build _build_python_avx2 --target swigfaiss_avx2 -j $CPU_COUNT

    # copy generated swig module with avx2-support to specifically named file, cf.
    # https://github.com/facebookresearch/faiss/blob/v1.7.1/faiss/python/setup.py#L37-L40
    cp _build_python_avx2/swigfaiss_avx2.py _build_python_generic/swigfaiss_avx2.py
    cp _build_python_avx2/_swigfaiss_avx2.so _build_python_generic/_swigfaiss_avx2.so
fi

# Build actual python module.
pushd _build_python_generic
$PYTHON setup.py install --single-version-externally-managed --record=record.txt --prefix=$PREFIX
popd
# clean up cmake-cache between builds
rm -r _build_python_*
