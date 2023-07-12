This guide presents an overview of installing Python packages and running Python scripts on the Longleaf and Dogwood clusters. 

## System-wide versions of Python

On Longleaf and Dogwood, there are several pre-installed versions of Python available as [modulefiles](https://help.rc.unc.edu/modules/). To view the available versions of Python, run the following command: 

```
$ module avail python

------------------------------------------ /nas/longleaf/apps/lmod/modulefiles/Core -------------------------------------------
   python/2.4.6     python/2.7.13        python/3.6.6    python/3.7.14    python/3.9.6
   python/2.7.12    python/3.5.1  (D)    python/3.7.9    python/3.8.8

  Where:
   D:  Default Module

Use "module spider" to find all possible modules.
Use "module keyword key1 key2 ..." to search for all possible modules matching any of the "keys".
```
To load a specific version of Python to your environment, use the `module load` command. To identify the location of the currently-loaded python executable, you may use the `which` command. 
```
$ module load python/3.9.6
$ which python
/nas/longleaf/rhel8/apps/python/3.9.6/bin/python
```
The system-wide versions of Python often include common scientific packages such as `numpy` and `scipy`, and are sufficient for basic computations; however, most research projects will require users to install additional packages themselves using conda and pip.

## Managing Python environments with conda

In order to manage dependency requirements for multiple projects, we strongly recommend that users install their local packages into isolated "virtual" Python environments. A Python virtual environment is a directory structure that contains all the necessary executables and packages needed to build and run a Python-based project. Using separate virtual environments for each project allows users to install and upgrade Python packages as needed without having to worry about creating dependency conflicts in their other projects. 

Conda is an environment and package manager that allows users to create virtual environments and install a variety of packages from the [Anaconda open-source repository](https://anaconda.org/anaconda). Before loading Anaconda, please ensure that no other Python modulefiles are loaded to your environment as this can create conflicts. The general syntax for creating a conda environment with a specific version of Python and activating/entering that environment is: 

```
$ module load anaconda
$ conda create --name=envName python=3.9
$ conda activate envName
```
By default, the executables and packages associated with this environment will be stored in your home directory under `~/.conda/envs/envName`. Alternatively, users can create an environment in a custom location by using the `--prefix` option to specify the installation directory: 
```
conda create --prefix=/work/users/o/n/onyen/envName python=3.9
```

Using the `pandas` package as an example, users can use the following syntax (from within your conda environmenta) to install packages from the Anaconda repository:

```
$ conda install -c anaconda pandas=1.5
```
Many packages that are not included in the main Anaconda repository can be found on [conda-forge](https://anaconda.org/conda-forge), a community-run repository from which packages can be installed. Using `geopandas` as an example, users can use the following syntax to install packages from conda-forge:
```
$ conda install -c conda-forge geopandas
```

If you need to install a package that is not available in Anaconda or conda-forge, see [Installing local packages using pip](#installing-local-packages-using-pip). Users can view a list of Python packages installed to their active environment with version information using the `conda list` command. Users may exit an active conda environment using the `conda deactivate` command. For more information on managing Python environments using conda, please refer to the conda [user guide](https://docs.conda.io/projects/conda/en/stable/user-guide/index.html) and [cheat sheet](https://docs.conda.io/projects/conda/en/4.6.0/_downloads/52a95608c49671267e40c689e0bc00ca/conda-cheatsheet.pdf).

### Accessing conda environments within a SLURM script

To submit jobs on Longleaf and Dogwood that use specific versions of Python packages, users should include lines in their job submission script to load the Anaconda modulefile and activate their previously-created conda environment. Below is an example SLURM script:

```
#!/bin/bash

#SBATCH -p general
#SBATCH -N 1
#SBATCH --mem 5120
#SBATCH -n 1
#SBATCH -t 2:00:00
#SBATCH --mail-type=end
#SBATCH --mail-user=onyen@email.unc.edu

module load anaconda
conda activate envName
python myscript.py
```

### Accessing conda environments within a Jupyter notebook

To access locally installed packages from within a Jupyter notebook session in [Open OnDemand](https://ondemand.rc.unc.edu/), you may use the following commands to create a kernel from your active conda environment:

```
$ conda activate envName
$ python -m ipykernel install --user --name=envName 
```
The next time you start a Jupyter notebook session in OnDemand, you should be able to select the kernel associated with your conda environment when creating a new notebook. 

## Installing local packages using pip

Occasionally, users may need to install packages which are [not available through conda](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-pkgs.html#installing-non-conda-packages). This typically accomplished using [pip](https://pypi.org/project/pip/), the standard package manager for Python. `pip` uses the Python Package Index ([PyPi](https://pypi.org/)) repository. Unlike conda, pip does not have built-in support for virtual environments; as a result, [issues can arise](https://www.anaconda.com/blog/using-pip-in-a-conda-environment) when conda and pip are used together to create an environment. For this reason, you should *avoid installing conda packages after doing pip installs within a conda environment*.

If a package cannot be installed via conda or conda-forge, you may try to install it with pip using the following syntax: 
```
$ conda activate envName
$ pip install package-name
```
The above commands will pip install the package `package-name` to your active conda environment. For more information on the differences between conda and pip, plase refer this [page](https://www.anaconda.com/blog/understanding-conda-and-pip).

Pip can also be used in conjunction with the system-wide versions of Python to install packages locally using the `--user` flag (see details [here](https://packaging.python.org/en/latest/tutorials/installing-packages/#installing-to-the-user-site)):  

```
module purge
module load python/3.9.6
pip install --user package-name
```

The location of packages depends on the version of Python in use. For example, for Python 3.9.6, system-wide packages are stored in `/nas/longleaf/rhel18/apps/python/3.9.6/lib/python3.9/site-packages`, and locally installed packages are stored in `/nas/longleaf/home/<onyen>/.local/lib/python3.9/site-packages`. You can use the following code to identify these directories: 

```
$ python -m site
sys.path = [
    '/nas/longleaf/home/onyen',
    '/nas/longleaf/rhel8/apps/python/3.9.6/lib/python3.9',
    '/nas/longleaf/rhel8/apps/python/3.9.6/lib/python3.9/site-packages',
    '/nas/longleaf/rhel8/apps/python/3.9.6/lib/python39.zip',
    '/nas/longleaf/rhel8/apps/python/3.9.6/lib/python3.9/lib-dynload',
    '/nas/longleaf/home/onyen/.local/lib/python3.9/site-packages',
    '/nas/longleaf/rhel8/apps/python/3.9.6/lib/python3.9/site-packages/cvxopt-1.2.6-py3.9-linux-x86_64.egg',
]
USER_BASE: '/nas/longleaf/home/onyen/.local' (exists)
USER_SITE: '/nas/longleaf/home/onyen/.local/lib/python3.9/site-packages' (exists)
ENABLE_USER_SITE: True
```
In order to ensure that user-installed packages have higher priority than system packages, it is sometimes necessary to add the following line to your `.bashrc` file: 

```
export PYTHONPATH=$HOME/.local/lib/python3.6/site-packages:$PYTHONPATH
```

Users can view a list of pip-installed local packages with version information using the `pip list` command. For more information on pip, please refer to the [user guide](https://pip.pypa.io/en/stable/user_guide/). 


## Managing Python environments with venv 

`venv` (or `virtualenv` for Python 2) is an alternative virtual environment manager to conda. Documentation for `venv` can be found [here](https://docs.python.org/3/library/venv.html). `venv` virtual environments are created on top of existing "base" Python installation and can optionally be isolated from the packages in the base environment. The syntax for creating a `venv` environment is: 

```
python -m venv /nas/longleaf/onyen/venv
```

This command creates the target directory specified, with a `pyvenv.cfg` file and all necessary subdirectories. The environment can be activated with the `source` command:

```
source /nas/longleaf/home/onyen/venv/bin/activate
```

Activating the environment will prepend the `venv` directory to your `PATH` so you can run installed scripts without having to invoke the full path. `venv` virtual environments do not need to be explicitly activated, as long as you specify the full path to that environment's Python interpreter when invoking Python (i.e. typing `/nas/longleaf/home/onyen/venv/bin/python` at the shell prompt instead of `python`) and scripts installed in the virtual environment have a "shebang" line that points to the environment's Python interpreter (i.e. `#!/nas/longleaf/onyen/venv/bin/python`). You can confirm you're in the virtual environment by checking the location of your Python interpreter: 

```
which python
```

You can use `pip` as described above to install packages in your virtual environment. 
```
python3 -m pip install <package-name> 
```
See [installing packages using pip and virtual environments](https://packaging.python.org/en/latest/guides/installing-using-pip-and-virtual-environments/#) for more detailed instructions.

You can deactivate a virtual environment by typing `deactivate`. 

