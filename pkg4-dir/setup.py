import setuptools


def main():
    setuptools.setup(
        name='pkg4',
        version='0.0.1',
        description='Some text',
        long_description='README',
        install_requires=[],
        namespace_packages=[
            'pkg1',
            'pkg1.one_more',
        ],
        packages=setuptools.find_packages('src'),
        package_dir={'': 'src'},
    )


if __name__ == '__main__':
    main()
