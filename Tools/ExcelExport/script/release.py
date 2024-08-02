# -*- coding: utf-8 -*-
'''
Created on 2014-2-18

@author: Administrator
'''

import os,shutil,glob

if __name__ == '__main__':
    os.chdir("../src")
    os.system("python pack.py py2exe")
    
    files = glob.glob( u"./dist/*.*" )
    for f in files:
       shutil.copy(f, "../release/")
       pass
    pass

'''
预发布：
http://svn.yuxiang.com:8080/project/cx/branch/doc/design/resConfig/export
内网的trunk版本：
http://svn.yuxiang.com:8080/project/cx/trunk/doc/design/resConfig/export
修改的导表工具：
http://svn.yuxiang.com:8080/project/branch_jailbreak/code/backup/new_export_tools/sdb_tools/release
'''
