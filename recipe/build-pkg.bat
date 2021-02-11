@echo on

SetLocal EnableDelayedExpansion

if "%cuda_compiler_version%"=="None" (
    set FAISS_ENABLE_GPU="OFF"
) else (
    set FAISS_ENABLE_GPU="ON"

    REM See more extensive comment in build-pkg.sh
    REM TODO: Fix this in nvcc-feedstock or cmake-feedstock.
    del %BUILD_PREFIX%\bin\nvcc.bat

    REM ... and another workaround just to cover more bases
    set "CudaToolkitDir=%CUDA_PATH%"
    set "CUDAToolkit_ROOT=%CUDA_PATH%"
)

:: workaround for https://github.com/conda-forge/vc-feedstock/issues/21
set "CMAKE_GENERATOR=Visual Studio 16 2019"

:: Build vanilla version (no avx2), see build-lib.bat
cmake -B _build_python_generic ^
    -Dfaiss_ROOT=%PREFIX% ^
    -DFAISS_ENABLE_GPU=!FAISS_ENABLE_GPU! ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DPython_EXECUTABLE="%PYTHON%" ^
    faiss/python
if %ERRORLEVEL% neq 0 exit 1

cmake --build _build_python_generic --config Release -j %CPU_COUNT%
if %ERRORLEVEL% neq 0 exit 1

:: Build version with avx2 support, see build-lib.bat
cmake -B _build_python_avx2 ^
    -Dfaiss_ROOT=_libfaiss_avx2_stage ^
    -DFAISS_ENABLE_GPU=OFF ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DPython_EXECUTABLE="%PYTHON%" ^
    faiss/python
if %ERRORLEVEL% neq 0 exit 1

cmake --build _build_python_avx2 --config Release -j %CPU_COUNT%
if %ERRORLEVEL% neq 0 exit 1

:: copy generated swig module with avx2-support to specifically named file, cf.
:: https://github.com/facebookresearch/faiss/blob/v1.7.0/faiss/python/setup.py#L25-L26
copy _build_python_avx2\swigfaiss.py _build_python_generic\swigfaiss_avx2.py
copy _build_python_avx2\Release\_swigfaiss.pyd _build_python_generic\Release\_swigfaiss_avx2.pyd
if %ERRORLEVEL% neq 0 exit 1

:: Build actual python module.
pushd _build_python_generic
%PYTHON% setup.py install --single-version-externally-managed --record=record.txt --prefix=%PREFIX%
if %ERRORLEVEL% neq 0 exit 1
popd
:: clean up cmake-cache between builds
rd /S /Q _build_python_generic
rd /S /Q _build_python_avx2
