from setuptools import setup, Extension

source_path = './source/'

source_files = ['EnvManagerWrapper.cpp',
            source_path+'EnvManager.cpp',
            source_path+'Simulation.cpp',
            source_path+'Distances.cpp',
            source_path+'PredatorSwarm.cpp',
            source_path+'PreySwarm.cpp',
            source_path+'LSTM.cpp',
            source_path+'RNN.cpp',
            source_path+'json11.cpp',
            source_path+'INetwork.cpp']

module = Extension('EnvManager',
                    include_dirs=['./packages/Eigen.3.3.3/build/native/include'],
                    sources=source_files)

setup(
    name='EnvManagerPkg',
    version='1.0',
    description='Master Thesis simulation environment',
    ext_modules=[module])

# python setup.py build
