from setuptools import find_packages, setup
import os

setup(
    name='dataprocessing',
    version='0.3.0',
    packages=find_packages(),
    package_data={
        'dataprocessing': [os.path.join('sql_snippets','*.sql')]
    },
    url='https://github.com/openego/dataprocessing',
    license='GNU GENERAL PUBLIC LICENSE Version 3',
    author='open_eGo development group',
    author_email='',
    description='Data processing related to the research project open_eGo',
    install_requires=[
        'pandas',
        'workalendar',
        'oemof.db',
        'demandlib',
        "pyyaml",
        "geopandas"
        'egoio @ git+https://github.com/openego/ego.io.git@features/use-one-Base-definition',
        'oedialect @ git+https://github.com/OpenEnergyPlatform/oedialect.git@4957e63ca46a976e35eecf84036466cb624e6bfe',
        'geoalchemy2 < 0.7.0',
    ],
    extras_require={
        'docs': [
            'sphinx >= 1.4',
            'sphinx_rtd_theme',
'sphinxcontrib-httpdomain']},
    entry_points={
        'console_scripts': [
            'ego_data_processing = dataprocessing.eGo_data_processing:data_processing', ]}
)
