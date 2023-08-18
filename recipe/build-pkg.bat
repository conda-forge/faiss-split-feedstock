@echo on

SetLocal EnableDelayedExpansion

if "%cuda_compiler_version%"=="None" (
    set FAISS_ENABLE_GPU="OFF"
) else (
    set FAISS_ENABLE_GPU="ON"
)

:: Build vanilla version (no avx2), see build-lib.bat
cmake -G Ninja ^
    -B _build_python_generic ^
    -Dfaiss_ROOT:PATH=_libfaiss_generic_stage ^
    -DFAISS_ENABLE_GPU:BOOL=!FAISS_ENABLE_GPU! ^
    -DCMAKE_BUILD_TYPE:STRING=Release ^
    -DPYTHON_EXECUTABLE:FILEPATH="%PYTHON%" ^
    -DPYTHON_LIBRARY:FILEPATH="%PYTHON_LIBRARY%" ^
    -DPYTHON_INCLUDE_DIR:PATH="%PREFIX%\include" ^
    faiss/python
if %ERRORLEVEL% neq 0 exit 1

cmake --build _build_python_generic --target swigfaiss --config Release -j %CPU_COUNT%
if %ERRORLEVEL% neq 0 exit 1

:: Build version with avx2 support, see build-lib.bat
cmake -G Ninja ^
    -B _build_python_avx2 ^
    -Dfaiss_ROOT:PATH=_libfaiss_avx2_stage ^
    -DFAISS_OPT_LEVEL:STRING=avx2 ^
    -DFAISS_ENABLE_GPU:BOOL=!FAISS_ENABLE_GPU! ^
    -DCMAKE_BUILD_TYPE:STRING=Release ^
    -DPYTHON_EXECUTABLE:FILEPATH="%PYTHON%" ^
    -DPYTHON_LIBRARY:FILEPATH="%PYTHON_LIBRARY%" ^
    -DPYTHON_INCLUDE_DIR:PATH="%PREFIX%\include" ^
    faiss/python
if %ERRORLEVEL% neq 0 exit 1

cmake --build _build_python_avx2 --target swigfaiss_avx2 --config Release -j %CPU_COUNT%
if %ERRORLEVEL% neq 0 exit 1

:: copy generated swig module with avx2-support to specifically named file, cf.
:: https://github.com/facebookresearch/faiss/blob/v1.7.1/faiss/python/setup.py#L37-L40
copy _build_python_avx2\swigfaiss_avx2.py _build_python_generic\swigfaiss_avx2.py
copy _build_python_avx2\_swigfaiss_avx2.pyd _build_python_generic\_swigfaiss_avx2.pyd
if %ERRORLEVEL% neq 0 exit 1

:: Build actual python module.
pushd _build_python_generic
%PYTHON% setup.py install --single-version-externally-managed --record=record.txt --prefix=%PREFIX%
if %ERRORLEVEL% neq 0 exit 1
popd
:: clean up cmake-cache between builds
rd /S /Q _build_python_generic
rd /S /Q _build_python_avx2
