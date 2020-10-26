:: Build faiss.dll
cmake -B _build ^
    -DBUILD_SHARED_LIBS=ON ^
    -DBUILD_TESTING=OFF ^
    -DFAISS_ENABLE_GPU=OFF ^
    -DFAISS_ENABLE_PYTHON=OFF .
if %ERRORLEVEL% neq 0 exit 1

cmake --build _build --config Release -j %CPU_COUNT%
if %ERRORLEVEL% neq 0 exit 1

cmake --install _build --config Release --prefix %PREFIX%
if %ERRORLEVEL% neq 0 exit 1
