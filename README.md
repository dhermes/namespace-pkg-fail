# Namespace Package Fail

Reproducible error(s) with `pip==9.0.1` and namespace packages

```
$ virtualenv --python=python3.6 venv1
$ venv1/bin/pip show pip
Name: pip
Version: 9.0.1
...
$
$ venv1/bin/pip install pkg1-dir/
$ venv1/bin/pip freeze
pkg1==0.0.1
$ ls -1 venv1/lib/python3.6/site-packages/*pth
venv1/lib/python3.6/site-packages/pkg1-0.0.1-py3.6-nspkg.pth
$
$ venv1/bin/pip install pkg2-dir/
$ venv1/bin/pip freeze
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
```

This [failure][1] occurs because of

```python
hasattr(spec.loader, 'create_module'):
```

[1]: https://github.com/python/cpython/blob/v3.6.2/Lib/importlib/_bootstrap.py#L557
