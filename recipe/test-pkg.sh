#!/bin/bash
set -ex

if [[ ${HAS_AVX2} == "YES" ]]; then
    python -c "from numpy.core._multiarray_umath import __cpu_features__; print(f'Testing version with AVX2-support - ' + str(__cpu_features__['AVX2']))"
    pytest tests --log-file-level=INFO --log-file=log.txt
    # print logfile for completeness (sleep so log has time to print)
    cat log.txt && sleep 2

    # ensure that expected logger-messages from loader.py is present;
    # avoid final '\n', as well as the first 35 = len('INFO     faiss.loader:loader.py:51 ')
    python -c "q = open('log.txt').readlines(); import sys; sys.exit(0 if 'Successfully loaded faiss with AVX2 support.' in [x[35:-1] for x in q] else 1)"
fi

# OTOH, we also want to test the packaged library without AVX2 support;
# the advantage of the CPU feature detection in numpy is that it can be
# deactivated, see documentation of NPY_DISABLE_CPU_FEATURES upstream
export NPY_DISABLE_CPU_FEATURES=AVX2

python -c "from numpy.core._multiarray_umath import __cpu_features__; print(f'Testing version with AVX2-support - ' + str(__cpu_features__['AVX2']))"
# rerun test suite again without AVX2 support
pytest tests --log-file-level=INFO --log-file=log.txt
cat log.txt && sleep 2

# this should have run without AVX2
python -c "q = open('log.txt').readlines(); import sys; sys.exit(0 if 'Successfully loaded faiss.' in [x[35:-1] for x in q] else 1)"
