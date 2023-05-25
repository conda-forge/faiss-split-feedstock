@echo on

SetLocal EnableDelayedExpansion

if "%HAS_AVX2%"=="NO" (
    GOTO Generic
)

:AVX2
python -c "from numpy.core._multiarray_umath import __cpu_features__; print(f'Testing version with AVX2-support - ' + str(__cpu_features__['AVX2']))"
:: TestComputeGT switches between CPU & GPU implementation depending on availability;
:: GPU device detection (on win) currently seems broken in CUDA, and segfaults the test suite
pytest tests --log-file-level=INFO --log-file=log.txt -k "not (TestComputeGT or test_RQ6x8)"
if %ERRORLEVEL% neq 0 exit 1
:: print logfile for completeness
type log.txt

:: ensure that expected logger-messages from loader.py is present;
:: avoid final '\n', as well as the first 35 = len('INFO     faiss.loader:loader.py:51 ')
python -c "q = open('log.txt').readlines(); import sys; sys.exit(0 if 'Successfully loaded faiss with AVX2 support.' in [x[35:-1] for x in q] else 1)"
if %ERRORLEVEL% neq 0 exit 1

:: Continues with :Generic if coming from :AVX2

:Generic
:: OTOH, we also want to test the packaged library without AVX2 support;
:: the advantage of the CPU feature detection in numpy is that it can be
:: deactivated, see documentation of NPY_DISABLE_CPU_FEATURES upstream
set NPY_DISABLE_CPU_FEATURES=AVX2

python -c "from numpy.core._multiarray_umath import __cpu_features__; print(f'Testing version with AVX2-support - ' + str(__cpu_features__['AVX2']))"
:: rerun test suite again without AVX2 support
pytest tests --log-file-level=INFO --log-file=log.txt -k "not (TestComputeGT or test_RQ6x8)"
if %ERRORLEVEL% neq 0 exit 1
type log.txt

:: this should have run without AVX2
python -c "q = open('log.txt').readlines(); import sys; sys.exit(0 if 'Successfully loaded faiss.' in [x[35:-1] for x in q] else 1)"
if %ERRORLEVEL% neq 0 exit 1
