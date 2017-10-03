# Namespace Package Fail

Reproducible error(s) with `pip==9.0.1` and namespace packages

## Example 1

```
$ ./example01.sh
+ VENV=venv1
+ PYTHON=python3.6
+ FIRST_PKG=pkg1
+ SECOND_PKG=pkg2
+ virtualenv --python=python3.6 venv1
...
+ venv1/bin/pip show pip
Name: pip
Version: 9.0.1
...
+ venv1/bin/pip install pkg1-dir/
...
Successfully installed pkg1-0.0.1
+ venv1/bin/pip freeze
pkg1==0.0.1
+ ls -1 venv1/lib/python3.6/site-packages/
+ grep -e 'pth$'
pkg1-0.0.1-py3.6-nspkg.pth
+ ls -1 venv1/lib/python3.6/site-packages/pkg1_ns/
foo.py
__pycache__
+ venv1/bin/pip install pkg2-dir/
...
Successfully installed pkg2-0.0.1
+ venv1/bin/pip freeze
Failed to import the site module
Traceback (most recent call last):
  File ".../venv1/lib/python3.6/site.py", line 703, in <module>
    main()
  File ".../venv1/lib/python3.6/site.py", line 683, in main
    paths_in_sys = addsitepackages(paths_in_sys)
  File ".../venv1/lib/python3.6/site.py", line 282, in addsitepackages
    addsitedir(sitedir, known_paths)
  File ".../venv1/lib/python3.6/site.py", line 204, in addsitedir
    addpackage(sitedir, name, known_paths)
  File ".../venv1/lib/python3.6/site.py", line 173, in addpackage
    exec(line)
  File "<string>", line 1, in <module>
  File "<frozen importlib._bootstrap>", line 557, in module_from_spec
AttributeError: 'NoneType' object has no attribute 'loader'
+ ls -1 venv1/lib/python3.6/site-packages/
+ grep -e 'pth$'
pkg1-0.0.1-py3.6-nspkg.pth
pkg2-0.0.1-py3.6-nspkg.pth
+ ls -1 venv1/lib/python3.6/site-packages/pkg2_ns/
ls: cannot access 'venv1/lib/python3.6/site-packages/pkg2_ns/': No such file or directory
+ rm -fr venv1
```

This [failure][1] occurs at the `importlib` line:

```python
hasattr(spec.loader, 'create_module'):
```

It's caused by the fact that `pkg2` registers a namespace package (`pkg2_ns`)
but doesn't include any files (from above):

```
+ ls -1 venv1/lib/python3.6/site-packages/pkg2_ns/
ls: cannot access 'venv1/lib/python3.6/site-packages/pkg2_ns/': No such file or directory
```

## Example 2

This example is "identical" to the one [above][2], but it uses `pkg3` instead
of `pkg2`, which actually does include files. When using `pip` alone to
install it, there are no issues:

```
$ ./example02.sh
+ VENV=venv2
+ PYTHON=python3.6
+ FIRST_PKG=pkg1
+ SECOND_PKG=pkg3
+ virtualenv --python=python3.6 venv2
...
+ venv2/bin/pip show pip
Name: pip
Version: 9.0.1
...
+ venv2/bin/pip install pkg1-dir/
...
Installing collected packages: pkg1
Successfully installed pkg1-0.0.1
+ venv2/bin/pip freeze
pkg1==0.0.1
+ ls -1 venv2/lib/python3.6/site-packages/
+ grep -e 'pth$'
pkg1-0.0.1-py3.6-nspkg.pth
+ ls -1 venv2/lib/python3.6/site-packages/pkg1_ns/
foo.py
__pycache__
+ venv2/bin/pip install pkg3-dir/
...
Successfully installed pkg3-0.0.1
+ venv2/bin/pip freeze
pkg1==0.0.1
pkg3==0.0.1
+ grep -e 'pth$'
+ ls -1 venv2/lib/python3.6/site-packages/
pkg1-0.0.1-py3.6-nspkg.pth
pkg3-0.0.1-py3.6-nspkg.pth
+ ls -1 venv2/lib/python3.6/site-packages/pkg3_ns/
bar.py
__pycache__
+ rm -fr venv2
```

## Example 3

This example installs `pkg1` and `pkg3` just like [Example 2][3],
but it installs `pkg3` via `setuptools` (i.e. with `python setup.py install`).

As with Example 2, this works "just fine", though it shows that
`setuptools` installs an `egg` rather than just adding the source into
`site-packages`:

```
$ ./example03.sh
+ VENV=venv3
+ PYTHON=python3.6
+ FIRST_PKG=pkg1
+ SECOND_PKG=pkg3
+ virtualenv --python=python3.6 venv3
...
+ venv3/bin/pip show pip
Name: pip
Version: 9.0.1
...
+ venv3/bin/pip install pkg1-dir/
...
Successfully installed pkg1-0.0.1
+ venv3/bin/pip freeze
pkg1==0.0.1
+ ls -1 venv3/lib/python3.6/site-packages/
+ grep -e 'pth$'
pkg1-0.0.1-py3.6-nspkg.pth
+ ls -1 venv3/lib/python3.6/site-packages/pkg1_ns/
foo.py
__pycache__
+ cd pkg3-dir/
+ ../venv3/bin/python setup.py install
...
Extracting pkg3-0.0.1-py3.6.egg to .../venv3/lib/python3.6/site-packages
Adding pkg3 0.0.1 to easy-install.pth file

Installed .../venv3/lib/python3.6/site-packages/pkg3-0.0.1-py3.6.egg
Processing dependencies for pkg3==0.0.1
Finished processing dependencies for pkg3==0.0.1
+ venv3/bin/pip freeze
pkg1==0.0.1
pkg3==0.0.1
+ ls -1 venv3/lib/python3.6/site-packages/
+ grep -e 'pth$'
easy-install.pth
pkg1-0.0.1-py3.6-nspkg.pth
+ ls -1 venv3/lib/python3.6/site-packages/pkg3-0.0.1-py3.6.egg/pkg3_ns/
bar.py
__init__.py
__pycache__
+ rm -fr venv3
+ rm -fr pkg3-dir/build/
+ rm -fr pkg3-dir/dist/
+ rm -fr pkg3-dir/src/pkg3.egg-info/
```

## Example 4

This example installs `pkg1` and `pkg4`, and like [Example 2][3]
it uses `pip` for both (and does not cause any issues). It is
unique because `pkg4` has both `pkg1` and `pkg1.pkg4_ns` as
namespace packages (i.e. it "collides" with `pkg1`).

```
$ ./example04.sh
+ VENV=venv4
+ PYTHON=python3.6
+ FIRST_PKG=pkg1
+ SECOND_PKG=pkg4
+ virtualenv --python=python3.6 venv4
...
+ venv4/bin/pip show pip
Name: pip
Version: 9.0.1
...
+ venv4/bin/pip install pkg1-dir/
...
Successfully installed pkg1-0.0.1
+ venv4/bin/pip freeze
pkg1==0.0.1
+ ls -1 venv4/lib/python3.6/site-packages/
+ grep -e 'pth$'
pkg1-0.0.1-py3.6-nspkg.pth
+ ls -1 venv4/lib/python3.6/site-packages/pkg1_ns/
foo.py
__pycache__
+ venv4/bin/pip install pkg4-dir/
...
Successfully installed pkg4-0.0.1
+ venv4/bin/pip freeze
pkg1==0.0.1
pkg4==0.0.1
+ ls -1 venv4/lib/python3.6/site-packages/
+ grep -e 'pth$'
pkg1-0.0.1-py3.6-nspkg.pth
pkg4-0.0.1-py3.6-nspkg.pth
+ tree -a venv4/lib/python3.6/site-packages/pkg1_ns/
venv4/lib/python3.6/site-packages/pkg1_ns/
├── foo.py
├── pkg4_ns
│   ├── __pycache__
│   │   └── quux.cpython-36.pyc
│   └── quux.py
└── __pycache__
    └── foo.cpython-36.pyc

3 directories, 4 files
+ rm -fr venv4
```

## Example 5

This example installs `pkg1` and `pkg4` just like [Example 4][4],
but it uses `setuptools` to install `pkg4` (like [Example 3][5]).
The namespace collision between `pkg1` and `pkg4`
causes an error that has been reported many times over:

```
$ ./example05.sh
+ VENV=venv5
+ PYTHON=python3.6
+ FIRST_PKG=pkg1
+ SECOND_PKG=pkg4
+ virtualenv --python=python3.6 venv5
...
+ venv5/bin/pip show pip
Name: pip
Version: 9.0.1
...
+ venv5/bin/pip install pkg1-dir/
...
Successfully installed pkg1-0.0.1
+ venv5/bin/pip freeze
pkg1==0.0.1
+ ls -1 venv5/lib/python3.6/site-packages/
+ grep -e 'pth$'
pkg1-0.0.1-py3.6-nspkg.pth
+ ls -1 venv5/lib/python3.6/site-packages/pkg1_ns/
foo.py
__pycache__
+ cd pkg4-dir/
+ ../venv5/bin/python setup.py install
...
Extracting pkg4-0.0.1-py3.6.egg to .../venv5/lib/python3.6/site-packages
Adding pkg4 0.0.1 to easy-install.pth file

Installed .../venv5/lib/python3.6/site-packages/pkg4-0.0.1-py3.6.egg
Processing dependencies for pkg4==0.0.1
Finished processing dependencies for pkg4==0.0.1
+ venv5/bin/pip freeze
Traceback (most recent call last):
  File "venv5/bin/pip", line 7, in <module>
    from pip import main
  File ".../venv5/lib/python3.6/site-packages/pip/__init__.py", line 26, in <module>
    from pip.utils import get_installed_distributions, get_prog
  File ".../venv5/lib/python3.6/site-packages/pip/utils/__init__.py", line 27, in <module>
    from pip._vendor import pkg_resources
  File ".../venv5/lib/python3.6/site-packages/pip/_vendor/pkg_resources/__init__.py", line 3018, in <module>
    @_call_aside
  File ".../venv5/lib/python3.6/site-packages/pip/_vendor/pkg_resources/__init__.py", line 3004, in _call_aside
    f(*args, **kwargs)
  File ".../venv5/lib/python3.6/site-packages/pip/_vendor/pkg_resources/__init__.py", line 3046, in _initialize_master_working_set
    dist.activate(replace=False)
  File ".../venv5/lib/python3.6/site-packages/pip/_vendor/pkg_resources/__init__.py", line 2578, in activate
    declare_namespace(pkg)
  File ".../venv5/lib/python3.6/site-packages/pip/_vendor/pkg_resources/__init__.py", line 2152, in declare_namespace
    _handle_ns(packageName, path_item)
  File ".../venv5/lib/python3.6/site-packages/pip/_vendor/pkg_resources/__init__.py", line 2092, in _handle_ns
    _rebuild_mod_path(path, packageName, module)
  File ".../venv5/lib/python3.6/site-packages/pip/_vendor/pkg_resources/__init__.py", line 2121, in _rebuild_mod_path
    orig_path.sort(key=position_in_sys_path)
AttributeError: '_NamespacePath' object has no attribute 'sort'
+ ls -1 venv5/lib/python3.6/site-packages/
+ grep -e 'pth$'
easy-install.pth
pkg1-0.0.1-py3.6-nspkg.pth
+ ls -1 venv5/lib/python3.6/site-packages/pkg1_ns/
foo.py
__pycache__
+ tree -a venv5/lib/python3.6/site-packages/pkg1_ns/
venv5/lib/python3.6/site-packages/pkg1_ns/
├── foo.py
└── __pycache__
    └── foo.cpython-36.pyc

1 directory, 2 files
+ tree -a venv5/lib/python3.6/site-packages/pkg4-0.0.1-py3.6.egg/pkg1_ns/
venv5/lib/python3.6/site-packages/pkg4-0.0.1-py3.6.egg/pkg1_ns/
├── __init__.py
├── pkg4_ns
│   ├── __init__.py
│   ├── __pycache__
│   │   ├── __init__.cpython-36.pyc
│   │   └── quux.cpython-36.pyc
│   └── quux.py
└── __pycache__
    └── __init__.cpython-36.pyc

3 directories, 6 files
+ rm -fr venv5
+ rm -fr pkg4-dir/build/
+ rm -fr pkg4-dir/dist/
+ rm -fr pkg4-dir/src/pkg4.egg-info/
```

The issue is that the `pip` added a namespace package doesn't
live in the same place as the one added by `setuptools`:

```
+ tree -a venv5/lib/python3.6/site-packages/pkg1_ns/
venv5/lib/python3.6/site-packages/pkg1_ns/
├── foo.py
└── __pycache__
    └── foo.cpython-36.pyc

1 directory, 2 files
+ tree -a venv5/lib/python3.6/site-packages/pkg4-0.0.1-py3.6.egg/pkg1_ns/
venv5/lib/python3.6/site-packages/pkg4-0.0.1-py3.6.egg/pkg1_ns/
├── __init__.py
├── pkg4_ns
│   ├── __init__.py
│   ├── __pycache__
│   │   ├── __init__.cpython-36.pyc
│   │   └── quux.cpython-36.pyc
│   └── quux.py
└── __pycache__
    └── __init__.cpython-36.pyc
```

[1]: https://github.com/python/cpython/blob/v3.6.2/Lib/importlib/_bootstrap.py#L557
[2]: #example-1
[3]: #example-2
[4]: #example-4
[5]: #example-3
