import setuptools


NAME = 'pkg4'


def main():
    setuptools.setup(
        name=NAME,
        version='0.0.1',
        description='Some text',
        long_description='README',
        install_requires=[],
        namespace_packages=[
            'pkg1_ns',
            'pkg1_ns.pkg4_ns',
        ],
        packages=setuptools.find_packages('src'),
        package_dir={'': 'src'},
    )


if __name__ == '__main__':
    main()
