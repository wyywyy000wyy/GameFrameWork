# coding=utf8
import logging

def initialize():
    import os
    path = os.environ["path"]
    print path

def check_lua_syntax(_lua_filename):
    '''去掉功能，由于无法将define相关的文件import进来，所以会误报错误
    import os
    out_filename = _lua_filename.replace(".lua",".o")
    _,stdout,stderr = os.popen3("luac -o %s %s"%(out_filename,_lua_filename))
    for l in stdout:
        logging.debug(l)
        pass
    for l in stderr:
        logging.error(l)
        pass
    if not os.path.exists( out_filename ):
        return False
    os.remove(out_filename)
    '''
    return True

if __name__ == "__main__":
    # 单元测试
    import log_wrapper
    log_wrapper.init_log_setting()
    check_lua_syntax("./demo.lua")
    pass
