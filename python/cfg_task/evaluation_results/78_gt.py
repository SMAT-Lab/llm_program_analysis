import os
import pathlib
import sys
def get_frontend_path() -> pathlib.Path:
    if getattr(sys, 'frozen', False):
        datadir = pathlib.Path(os.path.dirname(sys.executable)) / 'example_files'
    else:
        filedir = os.path.dirname(__file__)
        datadir = pathlib.Path(filedir).parent.parent.parent / 'example_files'
    return pathlib.Path(datadir)
getattr(sys, 'frozen', False)
def get_data_path() -> pathlib.Path:
    if getattr(sys, 'frozen', False):
        datadir = os.path.dirname(sys.executable)
    else:
        filedir = os.path.dirname(__file__)
        datadir = pathlib.Path(filedir).parent.parent
    return pathlib.Path(datadir)
getattr(sys, 'frozen', False)
datadir = pathlib.Path(os.path.dirname(sys.executable)) / 'example_files'
filedir = os.path.dirname(__file__)
datadir = pathlib.Path(filedir).parent.parent.parent / 'example_files'
datadir = os.path.dirname(sys.executable)
filedir = os.path.dirname(__file__)
datadir = pathlib.Path(filedir).parent.parent
return pathlib.Path(datadir)
return pathlib.Path(datadir)