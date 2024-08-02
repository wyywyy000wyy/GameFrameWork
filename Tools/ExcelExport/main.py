#
# coding=utf8
#


import sys,os,glob,subprocess,logging,re

import src.Loader as Loader
import src.CFG as CFG
import src.Pad as Pad
import util.file_wrapper
import util.log_wrapper
import sys
import traceback

# 其他文件通过execfile执行
# 所有外部文件需要的库要提前打包进来
# import commands
import re
# import threading
import subprocess
# import ctypes
import glob
# import pdb
# import ShowPic
# import win32gui
# import win32con

class Main():
    def __init__(self):
        self.initialize_environment()
        pass
    
    def run(self):
        self.get_prompt_cmd()
        self.export_before()
        self.process()
        self.raw_commit()
        pass
    
    def raw_run_command(self,_cmd):
        try:
            print(_cmd)
            code = subprocess.call(_cmd,shell=True)
            if code < 0:
                logging.error("call cmd: %s fail, with code: %d"%(_cmd,code))
                return False
            pass
        except (OSError) as e:
            logging.error("Execution failed:", e)
            return False
        return True

    def runfile(self, path):
        try:
            gs = {
                "__file__":path,
                "__name__": "__main__",
            }
            ret = execfile(path, gs)
        except SyntaxError as err:
            error_class = err.__class__.__name__
            detail = err.args[0]
            line_number = err.lineno
        except Exception as err:
            error_class = err.__class__.__name__
            detail = ""
            if err.args:
                detail = err.args[0]
            cl, exc, tb = sys.exc_info()
            line_number = traceback.extract_tb(tb)[-1][1]
        else:
            os.chdir(self.root_path)
            return
        os.chdir(self.root_path)
        print("%s at line %s of %s: %s" % (error_class, line_number, path, detail))


    def export_before(self):
        if hasattr(self,'skip_script'):
            root_path = os.getcwd() + "\\"
            # self.runfile(root_path + "exportBefore.py")

    def raw_commit_file(self):
        root_path = os.getcwd() + "\\"
        # self.runfile(root_path + "exportDone.py")

    def raw_check_file(self):
        root_path = os.getcwd() + "\\"
        # self.runfile(root_path + "lua_check.py")

    def export_all(self):
        files = glob.glob( u"../*.xls" )
        for f in files:
            if not self.raw_export_file(f,):
                logging.error(u"export file: %28s fail."%(f))
                return False
            logging.info(u"export file: %28s done."%(f))
            pass
        logging.info(u"export all file complete.")
        return True

    def create_path(self):
        paths = []
        output_path = os.path.join(os.getcwd() , CFG.OUTPUT_PATH ) 
        paths.append(output_path)
        paths.append(output_path + u"client/")
        # print("6666666666666666666666666")
        # print(output_path)
        paths.append(output_path + u"server/")
        util.file_wrapper.mkdirs(paths)

    def show_usage(self):
        logging.info(u"usage:")
        logging.info(u"")
        logging.info(u"export all file:")
        logging.info(u"$python main.py -all")
        logging.info(u"$python main.py -clean")
        logging.info(u"default export by conf.xls configure file.")
        logging.info(u"clean all")
        logging.info(u"")
        pass

    def initialize_environment(self):
        self.create_path()
        self.root_path = os.getcwd() + "\\"
        # util.string_wrapper.set_default_encoding()
        # util.log_wrapper.init_log_setting()
        #util.file_wrapper.clean_output_path()
        pass

    def get_prompt_cmd(self):
        if len(sys.argv) < 2:
            self.module = CFG.FLAG_NONE
            return
            
        self.skip_script = False
        sub = sys.argv[1]
        logging.info(u"argv:")
        for arg in (sys.argv):
            logging.info(arg)
        pass

        if sub == "-all":
            self.module = CFG.FLAG_ALL_FILE
        elif sub == "-clean":
            self.module = CFG.FLAG_CLEAR
        else:

            result = list(sys.argv)
            result.pop(0)  #remove main.exe
            if sub.lower() == "-skipscript":
                result.pop(0)
                self.skip_script = True

            if len(result) == 0:
                self.module = CFG.FLAG_NONE
            else:
                self.module = result
    
    def process(self):
        module      = self.module
        self.can_commit  = True
        #util.file_wrapper.clean_output_path()
        if type(module) == list:
            for filename in (module):
                #if not self.raw_export_file(os.getcwd() + u"\\..\\"+filename):
                if not self.raw_export_file(filename):
                    self.can_commit = False
                    pass
                pass
            pass
        elif module == CFG.FLAG_NONE:
            self.show_usage()
            self.can_commit = False
            pass
        elif module == CFG.FLAG_CLEAR:
            util.file_wrapper.clean_output_path()
            pass
        elif module == CFG.FLAG_ALL_FILE:
            if not self.export_all():
                self.can_commit = False
                pass
            pass
        logging.info(u"export complete.")
        logging.info(u"-------------------------------------------------------------------------")
        if not self.can_commit:
            logging.info(u"can't commit data, cause export failed. please check.")
            os.system("pause")
            pass
        pass
    
    def raw_commit(self):
        if hasattr(self,'skip_script'):
            return
        if not hasattr(self,'can_commit'):
            return
        self.raw_check_file()
        self.raw_commit_file()
        # if not self.no_pause:
        os.system("pause")
        # pass
    
    def raw_export_file(self, _xls_filename):
        loader  = Loader.Porter(_xls_filename)
        loader.process()
        
        lua     = Pad.OldLua(loader)
        if _xls_filename.find("propLanguage.xls") != -1:
            lua = Pad.LanguageLua(loader)
        pass
        if not lua.export_data(CFG.RULE_NUM_SERVER):
            logging.info(u"ERR> export server data fail. filename: %s"%_xls_filename)
            return False
        
        if _xls_filename.find("propLanguage.xls") != -1 :
            lua     = Pad.LanguageLua(loader)
            pass
        else:
            # lua     = Pad.Lua(loader)
            pass
        if not lua.export_data(CFG.RULE_NUM_CLIENT):
            logging.info(u"ERR> export client data fail. filename: %s"%_xls_filename)
            return False
        logging.info(u"DEBUG> export client data done. filename: %s"%_xls_filename)
        return True
    pass

    def copy_file(self):
        util.file_wrapper.raw_file(u"client")
        util.file_wrapper.raw_file(u"server") 
        pass

if __name__ == '__main__':
    print("start export file")
    main = Main()
    main.run()
    pass

