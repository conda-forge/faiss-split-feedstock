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
        set "CMAKE_CUDA_ARCHS=35-real;50-real;52-real;60-real;61-real;70-real;75"
    )
    if "%cuda_compiler_version:~0,2%"=="11" (
        if "%cuda_compiler_version:~0,4%"=="11.0" (
            REM cuda 11.0 deprecates arches 35, 50
            set "CMAKE_CUDA_ARCHS=52-real;60-real;61-real;70-real;75-real;80"
        ) else if "%cuda_compiler_version:~0,4%"=="11.1" (
            REM cuda>=11.1 adds arch 86, but we only build that for 11.2+ because 11.1 times out otherwise
            set "CMAKE_CUDA_ARCHS=52-real;60-real;61-real;70-real;75-real;80"
        ) else (
            set "CMAKE_CUDA_ARCHS=52-real;60-real;61-real;70-real;75-real;80-real;86"
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

:: Build faiss.dll depending on $CF_FAISS_BUILD (either "generic" or "avx2")
cmake -B _build_%CF_FAISS_BUILD% ^
    -DBUILD_SHARED_LIBS=ON ^
    -DBUILD_TESTING=OFF ^
    -DFAISS_OPT_LEVEL=%CF_FAISS_BUILD% ^
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

if "%CF_FAISS_BUILD%"=="avx2" (
    set "TARGET=faiss_avx2"
) else (
    set "TARGET=faiss"
)

cmake --build _build_%CF_FAISS_BUILD% --target %TARGET% --config Release -j %CPU_COUNT%
if %ERRORLEVEL% neq 0 exit 1

cmake --install _build_%CF_FAISS_BUILD% --config Release --prefix %PREFIX%
if %ERRORLEVEL% neq 0 exit 1
:: will be reused in build-pkg.bat
cmake --install _build_%CF_FAISS_BUILD% --config Release --prefix _libfaiss_%CF_FAISS_BUILD%_stage
if %ERRORLEVEL% neq 0 exit 1
