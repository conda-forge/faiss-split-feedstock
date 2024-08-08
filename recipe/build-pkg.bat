@echo on

SetLocal EnableDelayedExpansion

if "%cuda_compiler_version%"=="None" (
    set FAISS_ENABLE_GPU="OFF"
) else (
    set FAISS_ENABLE_GPU="ON"
)

mkdir build_python
pushd build_python

:: for picking up faiss_gpu.lib from _libfaiss_stage, see build-lib.bat
set "LDFLAGS=%LDFLAGS% /LIBPATH:%SRC_DIR:\=/%/build/_libfaiss_stage"

:: Build vanilla version (no avx2), see build-lib.bat
cmake -G Ninja ^
    -Dfaiss_ROOT=_libfaiss_stage ^
    -DFAISS_ENABLE_GPU=!FAISS_ENABLE_GPU! ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DPython_EXECUTABLE="%PYTHON%" ^
    ../faiss/python
if %ERRORLEVEL% neq 0 exit 1

cmake --build . --target swigfaiss --config Release -j %CPU_COUNT%
if %ERRORLEVEL% neq 0 exit 1

:: Build actual python module.
%PYTHON% setup.py install --single-version-externally-managed --record=record.txt --prefix=%PREFIX%
if %ERRORLEVEL% neq 0 exit 1

popd
:: clean up cmake-cache between builds
rd /S /Q build_python
