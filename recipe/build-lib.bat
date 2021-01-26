:: Build faiss.dll
cmake -B _build ^
    -DBUILD_SHARED_LIBS=ON ^
    -DBUILD_TESTING=OFF ^
    -DFAISS_ENABLE_GPU=OFF ^
    -DFAISS_ENABLE_PYTHON=OFF ^
    -DBLA_VENDOR=Intel10_64_dyn ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_BINDIR="%LIBRARY_BIN%" ^
    -DCMAKE_INSTALL_LIBDIR="%LIBRARY_LIB%" ^
    -DCMAKE_INSTALL_INCLUDEDIR="%LIBRARY_INC%" ^
    .
if %ERRORLEVEL% neq 0 exit 1

cmake --build _build --config Release -j %CPU_COUNT%
if %ERRORLEVEL% neq 0 exit 1

cmake --install _build --config Release --prefix %PREFIX%
if %ERRORLEVEL% neq 0 exit 1
