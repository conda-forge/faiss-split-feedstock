@echo on

SetLocal EnableDelayedExpansion

if "%cuda_compiler_version%"=="None" (
    set "FAISS_ENABLE_GPU=OFF"
    set "CUDA_CONFIG_ARGS="
) else (
    set "FAISS_ENABLE_GPU=ON"

    REM for documentation see e.g.
    REM docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html#building-for-maximum-compatibility
    REM docs.nvidia.com/cuda/cuda-compiler-driver-nvcc/index.html#ptxas-options-gpu-name
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
        if "%cuda_compiler_version:~0,4%"=="11.0" (
            REM cuda 11.0 deprecates arches 35, 50
            set "CMAKE_CUDA_ARCHS=52-virtual;60-virtual;61-virtual;70-virtual;75-virtual;80-virtual;80-real"
        ) else (
            REM cuda>=11.1 adds arch 86
            set "CMAKE_CUDA_ARCHS=52-virtual;60-virtual;61-virtual;70-virtual;75-virtual;80-virtual;86-virtual;86-real"
        )
    )

    REM See more extensive comment in build-lib.sh
    REM TODO: Fix this in nvcc-feedstock or cmake-feedstock.
    del %BUILD_PREFIX%\bin\nvcc.bat

    REM ... and another workaround just to cover more bases
    set "CudaToolkitDir=%CUDA_PATH%"
    set "CUDAToolkit_ROOT=%CUDA_PATH%"

    set CUDA_CONFIG_ARGS=-DCMAKE_CUDA_ARCHITECTURES=!CMAKE_CUDA_ARCHS!
    REM cmake does not generate output for the call below; echo some info
    echo Set up extra cmake-args: CUDA_CONFIG_ARGS=!CUDA_CONFIG_ARGS!
)

:: workaround for https://github.com/conda-forge/vc-feedstock/issues/21
set "CMAKE_GENERATOR=Visual Studio 16 2019"

:: Build vanilla faiss.dll (no avx2)
cmake -B _build_generic ^
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

cmake --build _build_generic --config Release -j %CPU_COUNT%
if %ERRORLEVEL% neq 0 exit 1

cmake --install _build_generic --config Release --prefix %PREFIX%
if %ERRORLEVEL% neq 0 exit 1
:: will be reused in build-pkg.bat
cmake --install _build_generic --config Release --prefix _libfaiss_stage
if %ERRORLEVEL% neq 0 exit 1


:: Build faiss.dll with avx2 support
cmake -B _build_avx2 ^
    -DBUILD_SHARED_LIBS=ON ^
    -DBUILD_TESTING=OFF ^
    -DFAISS_OPT_LEVEL=avx2 ^
    -DFAISS_ENABLE_GPU=OFF ^
    -DFAISS_ENABLE_PYTHON=OFF ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_BINDIR="%LIBRARY_BIN%" ^
    -DCMAKE_INSTALL_LIBDIR="%LIBRARY_LIB%" ^
    -DCMAKE_INSTALL_INCLUDEDIR="%LIBRARY_INC%" ^
    .
if %ERRORLEVEL% neq 0 exit 1

cmake --build _build_avx2 --config Release -j %CPU_COUNT%
if %ERRORLEVEL% neq 0 exit 1

cmake --install _build_avx2 --config Release --prefix %PREFIX%
if %ERRORLEVEL% neq 0 exit 1
:: will be reused in build-pkg.bat
cmake --install _build_avx2 --config Release --prefix _libfaiss_avx2_stage
if %ERRORLEVEL% neq 0 exit 1
