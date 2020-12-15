SetLocal EnableDelayedExpansion

if "%cuda_compiler_version%"=="None" (
    set FAISS_ENABLE_GPU="OFF"
) else (
    set FAISS_ENABLE_GPU="ON"

    REM workaround for https://github.com/conda-forge/nvcc-feedstock/issues/53
    set "CUDA_PATH=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v%cuda_compiler_version%"
    echo "Setting workaround CUDA_PATH=!CUDA_PATH!"
    set "CUDA_HOME=!CUDA_PATH!"
    REM With %MY_VAR:\=/% we replace backslashes with forward slashes
    REM set "CUDA_TOOLKIT_ROOT_DIR=!CUDA_PATH:\=/!"

    set "CUDA_CONFIG_ARGS=-DCUDA_TOOLKIT_ROOT_DIR=!CUDA_PATH!"

    REM cmake does not generate output for the call below; echo some info
    echo "Set up extra cmake-args: CUDA_CONFIG_ARGS=!CUDA_CONFIG_ARGS!"
)

:: Build vanilla version (no avx2).
:: Do not use the Python3_* variants for cmake
cmake -B _build_python ^
    -DFAISS_ENABLE_GPU=!FAISS_ENABLE_GPU! ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DPython_EXECUTABLE="%PYTHON%" ^
    !CUDA_CONFIG_ARGS! ^
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
