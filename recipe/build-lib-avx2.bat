@echo on

:: same build script, only difference through CF_FAISS_BUILD
copy "%RECIPE_DIR%\build-lib.bat" .
set CF_FAISS_BUILD=avx2
call build-lib.bat
