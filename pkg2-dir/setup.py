import setuptools


def main():
    setuptools.setup(
        name='pkg2',
        version='0.0.1',
        description='Some text',
        long_description='README',
        install_requires=[],
        namespace_packages=['pkg2'],
        packages=['pkg2'],
        package_dir={'': 'src'},
    )


if __name__ == '__main__':
    main()
