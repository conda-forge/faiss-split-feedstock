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

    if "%cuda_compiler_version%"=="11.8" (
        set "CMAKE_CUDA_ARCHS=53-real;62-real;72-real;75-real;80-real;86-real;89"
    ) else if "%cuda_compiler_version%"=="12.0" (
        set "CMAKE_CUDA_ARCHS=53-real;62-real;72-real;75-real;80-real;86-real;89-real;90"
    )
    REM turn off _extremely_ noisy nvcc warnings
    set "CUDAFLAGS=-w"

    set CUDA_CONFIG_ARGS=-DCMAKE_CUDA_ARCHITECTURES=!CMAKE_CUDA_ARCHS!
    REM cmake does not generate output for the call below; echo some info
    echo Set up extra cmake-args: CUDA_CONFIG_ARGS=!CUDA_CONFIG_ARGS!
)

mkdir build
cd build

cmake -G Ninja ^
    %CMAKE_ARGS% ^
    -DBUILD_SHARED_LIBS=ON ^
    -DBUILD_TESTING=OFF ^
    -DFAISS_ENABLE_PYTHON=OFF ^
    -DFAISS_ENABLE_GPU=!FAISS_ENABLE_GPU! ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_BINDIR="%LIBRARY_BIN%" ^
    -DCMAKE_INSTALL_LIBDIR="%LIBRARY_LIB%" ^
    -DCMAKE_INSTALL_INCLUDEDIR="%LIBRARY_INC%" ^
    !CUDA_CONFIG_ARGS! ^
    ..
if %ERRORLEVEL% neq 0 exit 1

cmake --build . --target faiss --config Release -j %CPU_COUNT%
if %ERRORLEVEL% neq 0 exit 1

cmake --install . --config Release --prefix %PREFIX%
if %ERRORLEVEL% neq 0 exit 1

:: we patched the CMake build to install faiss_gpu.lib, but we only want this for
:: _libfaiss_stage, not the actual output; normally, this library is supposed to
:: be consumed completely, however due to the way that `LINK_LIBRARY:WHOLE_ARCHIVE`
:: works on windows, it still needs to be available when we want to link swigfaiss; c.f.
:: https://cmake.org/cmake/help/latest/manual/cmake-generator-expressions.7.html#link-features
del %LIBRARY_LIB%\faiss_gpu.lib

:: will be reused in build-pkg.bat
cmake --install . --config Release --prefix _libfaiss_stage
if %ERRORLEVEL% neq 0 exit 1
