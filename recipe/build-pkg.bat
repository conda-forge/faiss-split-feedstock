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

:: Build vanilla version (no avx2).
:: Do not use the Python3_* variants for cmake
cmake -B _build_python ^
    -DFAISS_ENABLE_GPU=!FAISS_ENABLE_GPU! ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DPython_EXECUTABLE="%PYTHON%" ^
    faiss/python
if %ERRORLEVEL% neq 0 exit 1

cmake --build _build_python --config Release -j %CPU_COUNT%
if %ERRORLEVEL% neq 0 exit 1

:: Build actual python module.
pushd _build_python
%PYTHON% setup.py install --single-version-externally-managed --record=record.txt --prefix=%PREFIX%
if %ERRORLEVEL% neq 0 exit 1
popd
:: clean up cmake-cache between builds
rd /S /Q _build_python
