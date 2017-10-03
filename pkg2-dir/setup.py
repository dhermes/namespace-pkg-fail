import setuptools


NAME = 'pkg2'


def main():
    setuptools.setup(
        name=NAME,
        version='0.0.1',
        description='Some text',
        long_description='README',
        install_requires=[],
        namespace_packages=[NAME],
        packages=[NAME],
        package_dir={'': 'src'},
    )


if __name__ == '__main__':
    main()
