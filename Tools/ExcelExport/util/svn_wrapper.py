# coding=utf8
# $Id$
#

import pysvn
import os

def check_in(_filename,_comment):
    client = pysvn.Client()
    client.checkin([_filename],_comment)
    pass
def update_svn(_path):
    client = pysvn.Client()
    client.update(_path)
    pass
def remove_file(_filename,_comment):
    client = pysvn.Client()
    client.remove(_filename)
    client.checkin([_filename],_comment)
    pass
def get_diff(_filename):
    cmd = "svn diff %s"%_filename
    os.system(cmd)
    pass

def filter_modify_list(_path):
    client = pysvn.Client()
    changes = client.status(_path)
    for f in changes:
        print f.text_status
        pass
    pass
    return [f.path for f in changes if f.text_status == pysvn.wc_status_kind.modified]

def filter_add_list(_path):
    client = pysvn.Client()
    changes = client.status(_path)
    for f in changes:
        print f.text_status
        pass
    pass
    return [f.path for f in changes if f.text_status == pysvn.wc_status_kind.added]

if __name__ == "__main__":
    update_svn("./")
    get_diff("./svn_wrapper.py")
    print( filter_modify_list("./") )
    #check_in("./svn_wrapper.py","导出工具：测试提交功能")
    pass
