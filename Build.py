import subprocess
import os
import ctypes
import sys

CLIENT = False   
arguments = sys.argv
for arg in arguments:
    if arg == "CLIENT":
        CLIENT = True

print("CLIENT", CLIENT)
# exit(0)

if CLIENT:
    plugins = [
        "NFPluginLoader", 
        "NFActorPlugin", 
        "NFConfigPlugin", 
        "NFCore", 
        "NFKernelPlugin", 
        "NFLogPlugin", 
        "NFMessageDefine", 
        "NFLuaScriptPlugin", 
        ]
else:   
    plugins = [
        "NFPluginLoader", 
        "NFActorPlugin", 
        "NFConfigPlugin", 
        "NFCore", 
        "NFKernelPlugin", 
        "NFLogPlugin", 
        "NFMessageDefine", 
        "NFNetPlugin", 
        "NFSecurityPlugin", 
        "NFNavigationPlugin", 
        "NFNoSqlPlugin", 
        "NFLuaScriptPlugin", 
        ]



SolutionDir = (os.path.dirname(os.path.abspath(__file__)))

CommonLuaDir = os.path.join(SolutionDir, "Common", "Lua", "common")

if CLIENT:
    TargetCommonLuaDir = os.path.join(SolutionDir, "Client","Assets","Code","Lua", "common")
else:
    TargetCommonLuaDir = os.path.join(SolutionDir, "Server","Lua","common")
    
TargetLuaPluginDir = os.path.join(TargetCommonLuaDir, "plugins")



    
def run_as_admin():
    if sys.platform.startswith('win'):
        try:
            # 请求管理员权限
            ctypes.windll.shell32.ShellExecuteW(None, "runas", sys.executable, __file__, None, 1)
        except Exception as e:
            sys.exit(1)
    else:
        print("当前操作系统不支持请求管理员权限")

def get_admin():
    if ctypes.windll.shell32.IsUserAnAdmin() == 0:
        run_as_admin()
    # print("需要管理员权限来执行操作")

# else:
    # print("已以管理员权限运行")
    # 在这里执行需要管理员权限的操作
def link_folder(src_folder, link_folder):
    print(f"创建链接? {src_folder} -> {link_folder}")
    if not os.path.exists(link_folder):
        print(f"创建链接 {src_folder} -> {link_folder}")
        get_admin()
        os.symlink(src_folder, link_folder)
def link_folder2(src_folder):
    folder_name = os.path.basename(src_folder)
    link_folder(src_folder, os.path.join(TargetLuaPluginDir, folder_name))

def traverse_directory(directory, callback):
    for root, dirs, files in os.walk(directory):
        for dir in dirs:
            obs_dir = os.path.join(root, dir)
            print(f"删除链接 {obs_dir}")
            callback(obs_dir)

def delete_folder(folder):
    if os.path.exists(folder):
        print(f"删除链接 {folder}")
        get_admin()
        os.rmdir(folder)


# delete_folder(TargetCommonLuaDir)
link_folder(CommonLuaDir, TargetCommonLuaDir)
# traverse_directory(TargetLuaPluginDir, delete_folder)
# traverse_directory(TargetLuaPluginDir, link_folder2)

def add_plugin(plugin_name):
    plugin_path = os.path.join(SolutionDir, "Plugin", plugin_name)
    yield

# for plugin in plugins:
#     add_plugin(plugin)
# exit(0)

# 设置 CMake 命令和参数
cmake_command = ["cmake", "..", "-DBUILD_CLIENT=TRUE", "-DPLUGINS=" + ";".join(plugins)]

# 执行 CMake 命令
process = subprocess.Popen(cmake_command, stdout=subprocess.PIPE, stderr=subprocess.PIPE,)
output, error = process.communicate()

# 检查命令执行结果
if process.returncode == 0:
    print("Command executed successfully. Output:")
    print(output.decode())
else:
    print(f"Command failed with error code: {process.returncode}. Error:")
    print(error.decode())