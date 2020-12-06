set -e

FAISS_ENABLE_GPU=""
if [ ${cuda_compiler_version} != "None" ]; then
    FAISS_ENABLE_GPU="ON"
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
rm -r _build_python
