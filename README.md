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
+ ls -1 venv1/lib/python3.6/site-packages/pkg1-0.0.1-py3.6-nspkg.pth
venv1/lib/python3.6/site-packages/pkg1-0.0.1-py3.6-nspkg.pth
+ ls -1 venv1/lib/python3.6/site-packages/pkg1/
foo.py
__pycache__
+ venv1/bin/pip install pkg2-dir/
...
Successfully installed pkg2-0.0.1
+ ls -1 venv1/lib/python3.6/site-packages/pkg2/
ls: cannot access 'venv1/lib/python3.6/site-packages/pkg2/': No such file or directory
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
+ rm -fr venv1
```

This [failure][1] occurs at the `importlib` line:

```python
hasattr(spec.loader, 'create_module'):
```

It's caused by the fact that `pkg2` registers a namespace package but doesn't
include any files (from above):

```
+ ls -1 venv1/lib/python3.6/site-packages/pkg2/
ls: cannot access 'venv1/lib/python3.6/site-packages/pkg2/': No such file or directory
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
Successfully installed pkg1-0.0.1
+ venv2/bin/pip freeze
pkg1==0.0.1
+ ls -1 venv2/lib/python3.6/site-packages/pkg1-0.0.1-py3.6-nspkg.pth
venv2/lib/python3.6/site-packages/pkg1-0.0.1-py3.6-nspkg.pth
+ ls -1 venv2/lib/python3.6/site-packages/pkg1/
foo.py
__pycache__
+ venv2/bin/pip install pkg3-dir/
...
Successfully installed pkg3-0.0.1
+ ls -1 venv2/lib/python3.6/site-packages/pkg3/
bar.py
__pycache__
+ venv2/bin/pip freeze
pkg1==0.0.1
pkg3==0.0.1
+ rm -fr venv2
```

[1]: https://github.com/python/cpython/blob/v3.6.2/Lib/importlib/_bootstrap.py#L557
[2]: #example-1
