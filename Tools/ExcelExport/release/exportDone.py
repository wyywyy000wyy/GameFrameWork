# -*- coding:UTF-8 -*- 

import os

client_path = "/../../slg_client/Assets/Lua/data"

cmd_pull = "git pull"
cmd_add  = "git add ."
cmd_ci   = "git commit -m configAutoCit"
cmd_push = "git push"

root_path = os.getcwd()

def concatPath(path):
    return root_path + path

def commit_client():
    path = concatPath(client_path)
    print ("path: ", root_path)
    print ("path: ", path)
    os.chdir(path)
    '''
    result = os.system(cmd_add)
    if result != 0:
        print(u"客户端配置脚本暂存失败！")
        os.system('pause')
        exit(1)
        pass
    result = os.system(cmd_ci)
    if result != 0:
        print(u"客户端配置脚本提交失败！")
        os.system('pause')
        exit(1)
        pass
    result = os.system(cmd_push)
    if result != 0:
        print(u"客户端配置脚本推送失败！")
        os.system('pause')
        exit(1)
        pass
    '''
    pass

if __name__ == "__main__":
    # commit_client()
    # os.chdir(root_path)
    print(u"执行成功！")
    os.system('pause')
    pass
