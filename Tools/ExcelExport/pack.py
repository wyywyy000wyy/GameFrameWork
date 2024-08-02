# coding=utf8
# $Id: pack.py 269 2013-03-07 08:40:10Z abel $
# to package python script to executable file.
#

from distutils.core import setup
import py2exe

# # dummy syntax
# py2exe=py2exe
# setup(
#     options = {'py2exe': {'bundle_files': 1, 'compressed': True, 'dll_excludes': ['w9xpopen.exe']}},
#     console = ["main.py"],
#     zipfile = None,
#     )
# setup(console=["main.py"]) 

setup(
    # name='config_exporter',
    # version='1.0',
    # description='export config from excel',
    # author='focus',
    console=['main.py'],
    # py_modules = ['main'],
    options={
        'py2exe': {
            'bundle_files': 1,
            'compressed': True,
        }
    },
    zipfile=None,
)
