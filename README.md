About faiss-split
=================

Home: https://github.com/facebookresearch/faiss

Package license: MIT

Feedstock license: [BSD-3-Clause](https://github.com/conda-forge/faiss-split-feedstock/blob/master/LICENSE.txt)

Summary: A library for efficient similarity search and clustering of dense vectors.

Development: https://github.com/facebookresearch/faiss

Documentation: https://rawgit.com/facebookresearch/faiss/master/docs/html/annotated.html

Faiss is a library for efficient similarity search and clustering of dense vectors.
It contains algorithms that search in sets of vectors of any size, up to ones that
possibly do not fit in RAM. It also contains supporting code for evaluation and
parameter tuning. Faiss is written in C++ with complete wrappers for Python/numpy.
Some of the most useful algorithms are implemented on the GPU. It is developed by
[Facebook AI Research](https://research.fb.com/category/facebook-ai-research-fair/).

For best performance, the maintainers of the package
[recommend](https://github.com/conda-forge/staged-recipes/pull/11337#issuecomment-623718460)
using the MKL implementation of blas/lapack. You can ensure that this is installed
by adding "libblas =*=*mkl" to your dependencies.


Current build status
====================


<table>
    
  <tr>
    <td>Azure</td>
    <td>
      <details>
        <summary>
          <a href="https://dev.azure.com/conda-forge/feedstock-builds/_build/latest?definitionId=9713&branchName=master">
            <img src="https://dev.azure.com/conda-forge/feedstock-builds/_apis/build/status/faiss-split-feedstock?branchName=master">
          </a>
        </summary>
        <table>
          <thead><tr><th>Variant</th><th>Status</th></tr></thead>
          <tbody><tr>
              <td>linux_64_cuda_compiler_version10.2</td>
              <td>
                <a href="https://dev.azure.com/conda-forge/feedstock-builds/_build/latest?definitionId=9713&branchName=master">
                  <img src="https://dev.azure.com/conda-forge/feedstock-builds/_apis/build/status/faiss-split-feedstock?branchName=master&jobName=linux&configuration=linux_64_cuda_compiler_version10.2" alt="variant">
                </a>
              </td>
            </tr><tr>
              <td>linux_64_cuda_compiler_version11.0</td>
              <td>
                <a href="https://dev.azure.com/conda-forge/feedstock-builds/_build/latest?definitionId=9713&branchName=master">
                  <img src="https://dev.azure.com/conda-forge/feedstock-builds/_apis/build/status/faiss-split-feedstock?branchName=master&jobName=linux&configuration=linux_64_cuda_compiler_version11.0" alt="variant">
                </a>
              </td>
            </tr><tr>
              <td>linux_64_cuda_compiler_version11.1</td>
              <td>
                <a href="https://dev.azure.com/conda-forge/feedstock-builds/_build/latest?definitionId=9713&branchName=master">
                  <img src="https://dev.azure.com/conda-forge/feedstock-builds/_apis/build/status/faiss-split-feedstock?branchName=master&jobName=linux&configuration=linux_64_cuda_compiler_version11.1" alt="variant">
                </a>
              </td>
            </tr><tr>
              <td>linux_64_cuda_compiler_version11.2</td>
              <td>
                <a href="https://dev.azure.com/conda-forge/feedstock-builds/_build/latest?definitionId=9713&branchName=master">
                  <img src="https://dev.azure.com/conda-forge/feedstock-builds/_apis/build/status/faiss-split-feedstock?branchName=master&jobName=linux&configuration=linux_64_cuda_compiler_version11.2" alt="variant">
                </a>
              </td>
            </tr><tr>
              <td>linux_64_cuda_compiler_versionNone</td>
              <td>
                <a href="https://dev.azure.com/conda-forge/feedstock-builds/_build/latest?definitionId=9713&branchName=master">
                  <img src="https://dev.azure.com/conda-forge/feedstock-builds/_apis/build/status/faiss-split-feedstock?branchName=master&jobName=linux&configuration=linux_64_cuda_compiler_versionNone" alt="variant">
                </a>
              </td>
            </tr><tr>
              <td>osx_64</td>
              <td>
                <a href="https://dev.azure.com/conda-forge/feedstock-builds/_build/latest?definitionId=9713&branchName=master">
                  <img src="https://dev.azure.com/conda-forge/feedstock-builds/_apis/build/status/faiss-split-feedstock?branchName=master&jobName=osx&configuration=osx_64_" alt="variant">
                </a>
              </td>
            </tr><tr>
              <td>win_64_cuda_compiler_version10.2</td>
              <td>
                <a href="https://dev.azure.com/conda-forge/feedstock-builds/_build/latest?definitionId=9713&branchName=master">
                  <img src="https://dev.azure.com/conda-forge/feedstock-builds/_apis/build/status/faiss-split-feedstock?branchName=master&jobName=win&configuration=win_64_cuda_compiler_version10.2" alt="variant">
                </a>
              </td>
            </tr><tr>
              <td>win_64_cuda_compiler_version11.0</td>
              <td>
                <a href="https://dev.azure.com/conda-forge/feedstock-builds/_build/latest?definitionId=9713&branchName=master">
                  <img src="https://dev.azure.com/conda-forge/feedstock-builds/_apis/build/status/faiss-split-feedstock?branchName=master&jobName=win&configuration=win_64_cuda_compiler_version11.0" alt="variant">
                </a>
              </td>
            </tr><tr>
              <td>win_64_cuda_compiler_version11.1</td>
              <td>
                <a href="https://dev.azure.com/conda-forge/feedstock-builds/_build/latest?definitionId=9713&branchName=master">
                  <img src="https://dev.azure.com/conda-forge/feedstock-builds/_apis/build/status/faiss-split-feedstock?branchName=master&jobName=win&configuration=win_64_cuda_compiler_version11.1" alt="variant">
                </a>
              </td>
            </tr><tr>
              <td>win_64_cuda_compiler_version11.2</td>
              <td>
                <a href="https://dev.azure.com/conda-forge/feedstock-builds/_build/latest?definitionId=9713&branchName=master">
                  <img src="https://dev.azure.com/conda-forge/feedstock-builds/_apis/build/status/faiss-split-feedstock?branchName=master&jobName=win&configuration=win_64_cuda_compiler_version11.2" alt="variant">
                </a>
              </td>
            </tr><tr>
              <td>win_64_cuda_compiler_versionNone</td>
              <td>
                <a href="https://dev.azure.com/conda-forge/feedstock-builds/_build/latest?definitionId=9713&branchName=master">
                  <img src="https://dev.azure.com/conda-forge/feedstock-builds/_apis/build/status/faiss-split-feedstock?branchName=master&jobName=win&configuration=win_64_cuda_compiler_versionNone" alt="variant">
                </a>
              </td>
            </tr>
          </tbody>
        </table>
      </details>
    </td>
  </tr>
</table>

Current release info
====================

| Name | Downloads | Version | Platforms |
| --- | --- | --- | --- |
| [![Conda Recipe](https://img.shields.io/badge/recipe-faiss-green.svg)](https://anaconda.org/conda-forge/faiss) | [![Conda Downloads](https://img.shields.io/conda/dn/conda-forge/faiss.svg)](https://anaconda.org/conda-forge/faiss) | [![Conda Version](https://img.shields.io/conda/vn/conda-forge/faiss.svg)](https://anaconda.org/conda-forge/faiss) | [![Conda Platforms](https://img.shields.io/conda/pn/conda-forge/faiss.svg)](https://anaconda.org/conda-forge/faiss) |
| [![Conda Recipe](https://img.shields.io/badge/recipe-faiss--cpu-green.svg)](https://anaconda.org/conda-forge/faiss-cpu) | [![Conda Downloads](https://img.shields.io/conda/dn/conda-forge/faiss-cpu.svg)](https://anaconda.org/conda-forge/faiss-cpu) | [![Conda Version](https://img.shields.io/conda/vn/conda-forge/faiss-cpu.svg)](https://anaconda.org/conda-forge/faiss-cpu) | [![Conda Platforms](https://img.shields.io/conda/pn/conda-forge/faiss-cpu.svg)](https://anaconda.org/conda-forge/faiss-cpu) |
| [![Conda Recipe](https://img.shields.io/badge/recipe-faiss--gpu-green.svg)](https://anaconda.org/conda-forge/faiss-gpu) | [![Conda Downloads](https://img.shields.io/conda/dn/conda-forge/faiss-gpu.svg)](https://anaconda.org/conda-forge/faiss-gpu) | [![Conda Version](https://img.shields.io/conda/vn/conda-forge/faiss-gpu.svg)](https://anaconda.org/conda-forge/faiss-gpu) | [![Conda Platforms](https://img.shields.io/conda/pn/conda-forge/faiss-gpu.svg)](https://anaconda.org/conda-forge/faiss-gpu) |
| [![Conda Recipe](https://img.shields.io/badge/recipe-faiss--proc-green.svg)](https://anaconda.org/conda-forge/faiss-proc) | [![Conda Downloads](https://img.shields.io/conda/dn/conda-forge/faiss-proc.svg)](https://anaconda.org/conda-forge/faiss-proc) | [![Conda Version](https://img.shields.io/conda/vn/conda-forge/faiss-proc.svg)](https://anaconda.org/conda-forge/faiss-proc) | [![Conda Platforms](https://img.shields.io/conda/pn/conda-forge/faiss-proc.svg)](https://anaconda.org/conda-forge/faiss-proc) |
| [![Conda Recipe](https://img.shields.io/badge/recipe-libfaiss-green.svg)](https://anaconda.org/conda-forge/libfaiss) | [![Conda Downloads](https://img.shields.io/conda/dn/conda-forge/libfaiss.svg)](https://anaconda.org/conda-forge/libfaiss) | [![Conda Version](https://img.shields.io/conda/vn/conda-forge/libfaiss.svg)](https://anaconda.org/conda-forge/libfaiss) | [![Conda Platforms](https://img.shields.io/conda/pn/conda-forge/libfaiss.svg)](https://anaconda.org/conda-forge/libfaiss) |

Installing faiss-split
======================

Installing `faiss-split` from the `conda-forge` channel can be achieved by adding `conda-forge` to your channels with:

```
conda config --add channels conda-forge
```

Once the `conda-forge` channel has been enabled, `faiss, faiss-cpu, faiss-gpu, faiss-proc, libfaiss` can be installed with:

```
conda install faiss faiss-cpu faiss-gpu faiss-proc libfaiss
```

It is possible to list all of the versions of `faiss` available on your platform with:

```
conda search faiss --channel conda-forge
```


About conda-forge
=================

[![Powered by NumFOCUS](https://img.shields.io/badge/powered%20by-NumFOCUS-orange.svg?style=flat&colorA=E1523D&colorB=007D8A)](http://numfocus.org)

conda-forge is a community-led conda channel of installable packages.
In order to provide high-quality builds, the process has been automated into the
conda-forge GitHub organization. The conda-forge organization contains one repository
for each of the installable packages. Such a repository is known as a *feedstock*.

A feedstock is made up of a conda recipe (the instructions on what and how to build
the package) and the necessary configurations for automatic building using freely
available continuous integration services. Thanks to the awesome service provided by
[CircleCI](https://circleci.com/), [AppVeyor](https://www.appveyor.com/)
and [TravisCI](https://travis-ci.com/) it is possible to build and upload installable
packages to the [conda-forge](https://anaconda.org/conda-forge)
[Anaconda-Cloud](https://anaconda.org/) channel for Linux, Windows and OSX respectively.

To manage the continuous integration and simplify feedstock maintenance
[conda-smithy](https://github.com/conda-forge/conda-smithy) has been developed.
Using the ``conda-forge.yml`` within this repository, it is possible to re-render all of
this feedstock's supporting files (e.g. the CI configuration files) with ``conda smithy rerender``.

For more information please check the [conda-forge documentation](https://conda-forge.org/docs/).

Terminology
===========

**feedstock** - the conda recipe (raw material), supporting scripts and CI configuration.

**conda-smithy** - the tool which helps orchestrate the feedstock.
                   Its primary use is in the construction of the CI ``.yml`` files
                   and simplify the management of *many* feedstocks.

**conda-forge** - the place where the feedstock and smithy live and work to
                  produce the finished article (built conda distributions)


Updating faiss-split-feedstock
==============================

If you would like to improve the faiss-split recipe or build a new
package version, please fork this repository and submit a PR. Upon submission,
your changes will be run on the appropriate platforms to give the reviewer an
opportunity to confirm that the changes result in a successful build. Once
merged, the recipe will be re-built and uploaded automatically to the
`conda-forge` channel, whereupon the built conda packages will be available for
everybody to install and use from the `conda-forge` channel.
Note that all branches in the conda-forge/faiss-split-feedstock are
immediately built and any created packages are uploaded, so PRs should be based
on branches in forks and branches in the main repository should only be used to
build distinct package versions.

In order to produce a uniquely identifiable distribution:
 * If the version of a package **is not** being increased, please add or increase
   the [``build/number``](https://conda.io/docs/user-guide/tasks/build-packages/define-metadata.html#build-number-and-string).
 * If the version of a package **is** being increased, please remember to return
   the [``build/number``](https://conda.io/docs/user-guide/tasks/build-packages/define-metadata.html#build-number-and-string)
   back to 0.

Feedstock Maintainers
=====================

* [@h-vetinari](https://github.com/h-vetinari/)

