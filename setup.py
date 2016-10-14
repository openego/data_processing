from distutils.core import setup

setup(
    name='data_processing',
    version='0.1-pre',
    packages=['data_processing'],
    url='https://github.com/openego/data_processing',
    license='GNU GENERAL PUBLIC LICENSE Version 3',
    author='open_eGo development group',
    author_email='',
    description='Data processing related to the research project open_eGo',
    install_requires=[
        'pandas',
        'workalendar',
        'oemof.db',
        'demandlib',
        'ego.io >=0.0.1rc3, <= 0.0.1rc3',
        'geoalchemy2'
    ]
)

