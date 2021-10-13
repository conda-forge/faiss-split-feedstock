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

:: Set EXT_SUFFIX for swig extension (not strictly necessary, but allows uniform handling in patched CMakeLists.txt)
for /f "delims=" %%i in ('python -c "import sysconfig; print(sysconfig.get_config_var('EXT_SUFFIX'))"') do set "EXT_SUFFIX=%%i"
echo Setting environment variable EXT_SUFFIX to "%EXT_SUFFIX%" (from python-sysconfig)


:: Build vanilla version (no avx2), see build-lib.bat
cmake -B _build_python_generic ^
    -Dfaiss_ROOT=_libfaiss_generic_stage ^
    -DFAISS_ENABLE_GPU=!FAISS_ENABLE_GPU! ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DPython_EXECUTABLE="%PYTHON%" ^
    faiss/python
if %ERRORLEVEL% neq 0 exit 1

cmake --build _build_python_generic --target swigfaiss --config Release -j %CPU_COUNT%
if %ERRORLEVEL% neq 0 exit 1

:: Build version with avx2 support, see build-lib.bat
cmake -B _build_python_avx2 ^
    -Dfaiss_ROOT=_libfaiss_avx2_stage ^
    -DFAISS_OPT_LEVEL=avx2 ^
    -DFAISS_ENABLE_GPU=!FAISS_ENABLE_GPU! ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DPython_EXECUTABLE="%PYTHON%" ^
    faiss/python
if %ERRORLEVEL% neq 0 exit 1

cmake --build _build_python_avx2 --target swigfaiss_avx2 --config Release -j %CPU_COUNT%
if %ERRORLEVEL% neq 0 exit 1

:: copy generated swig module with avx2-support to specifically named file, cf.
:: https://github.com/facebookresearch/faiss/blob/v1.7.1/faiss/python/setup.py#L37-L40
copy _build_python_avx2\swigfaiss_avx2.py _build_python_generic\swigfaiss_avx2.py
copy _build_python_avx2\Release\_swigfaiss_avx2.%EXT_SUFFIX% _build_python_generic\Release\_swigfaiss_avx2.%EXT_SUFFIX%
if %ERRORLEVEL% neq 0 exit 1

:: Build actual python module.
pushd _build_python_generic
%PYTHON% setup.py install --single-version-externally-managed --record=record.txt --prefix=%PREFIX%
if %ERRORLEVEL% neq 0 exit 1
popd
:: clean up cmake-cache between builds
rd /S /Q _build_python_generic
rd /S /Q _build_python_avx2
