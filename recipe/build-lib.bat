SetLocal EnableDelayedExpansion

if "%cuda_compiler_version%"=="None" (
    set "FAISS_ENABLE_GPU=OFF"
    set "CUDA_CONFIG_ARGS="
) else (
    set "FAISS_ENABLE_GPU=ON"

    REM for documentation see e.g.
    REM docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html#building-for-maximum-compatibility
    REM docs.nvidia.com/cuda/cuda-toolkit-release-notes/index.html#major-components__table-cuda-toolkit-driver-versions
    REM docs.nvidia.com/cuda/cuda-compiler-driver-nvcc/index.html#gpu-feature-list

    REM for -real vs. -virtual, see cmake.org/cmake/help/latest/prop_tgt/CUDA_ARCHITECTURES.html
    REM this is to support PTX JIT compilation; see first link above or cf.
    REM devblogs.nvidia.com/cuda-pro-tip-understand-fat-binaries-jit-caching

    REM windows support start with cuda 10.0
    REM %MY_VAR:~0,2% selects first two characters
    if "%cuda_compiler_version:~0,2%"=="10" (
        set "CMAKE_CUDA_ARCHS=35-virtual;50-virtual;52-virtual;60-virtual;61-virtual;70-virtual;75-virtual;75-real"
    )
    if "%cuda_compiler_version:~0,2%"=="11" (
        REM cuda 11.0 deprecates arches 35, 50
        set "CMAKE_CUDA_ARCHS=52-virtual;60-virtual;61-virtual;70-virtual;75-virtual;80-virtual;80-real"
    )

    REM workaround for https://github.com/conda-forge/nvcc-feedstock/issues/53
    set "CUDA_PATH=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v%cuda_compiler_version%"
    echo "Setting workaround CUDA_PATH=!CUDA_PATH!"
    set "CUDA_HOME=!CUDA_PATH!"
    REM With %MY_VAR:\=/% we replace backslashes with forward slashes
    REM set "CUDA_TOOLKIT_ROOT_DIR=!CUDA_PATH:\=/!"

    set "CUDA_CONFIG_ARGS=-DCMAKE_CUDA_ARCHITECTURES=!CMAKE_CUDA_ARCHS! -DCUDA_TOOLKIT_ROOT_DIR=!CUDA_PATH!"

    REM cmake does not generate output for the call below; echo some info
    echo "Set up extra cmake-args: CUDA_CONFIG_ARGS=!CUDA_CONFIG_ARGS!"
)

:: Build faiss.dll
cmake -B _build ^
    -DBUILD_SHARED_LIBS=ON ^
    -DBUILD_TESTING=OFF ^
    -DFAISS_ENABLE_PYTHON=OFF ^
    -DFAISS_ENABLE_GPU=!FAISS_ENABLE_GPU! ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_BINDIR="%LIBRARY_BIN%" ^
    -DCMAKE_INSTALL_LIBDIR="%LIBRARY_LIB%" ^
    -DCMAKE_INSTALL_INCLUDEDIR="%LIBRARY_INC%" ^
    !CUDA_CONFIG_ARGS! ^
    .
if %ERRORLEVEL% neq 0 exit 1

cmake --build _build --config Release -j %CPU_COUNT%
if %ERRORLEVEL% neq 0 exit 1

cmake --install _build --config Release --prefix %PREFIX%
if %ERRORLEVEL% neq 0 exit 1
