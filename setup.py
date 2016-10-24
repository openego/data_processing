from setuptools import find_packages, setup
import os

setup(
    name='dataprocessing',
    version='0.1-pre',
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
        'ego.io >=0.0.1rc4, <= 0.0.1rc4',
        'geoalchemy2'
    ],
    entry_points={
        'console_scripts': [
            'ego_data_processing = dataprocessing.eGo_data_processing:data_processing', ]}
)
