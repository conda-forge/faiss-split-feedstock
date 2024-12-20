@echo on

python -c "from numpy.core._multiarray_umath import __cpu_features__; print(f'Testing version with AVX2-support - ' + str(__cpu_features__['AVX2']))"
pytest tests --log-file-level=INFO --log-file=log.txt -k "not %SKIPS%" --durations=50
if %ERRORLEVEL% neq 0 exit 1
