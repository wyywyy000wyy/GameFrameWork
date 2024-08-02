# coding=utf8
# $Id$
#
import glob,shutil,os,logging
import src.CFG as CFG

def clean_output_path():
    files = glob.glob(CFG.OUTPUT_PATH+u"client/*.*")
    for f in files: os.remove(f)
    files = glob.glob(CFG.OUTPUT_PATH+u"server/*.*")
    for f in files: os.remove(f)
    logging.info(u"initialize> clean output path done.")
    pass

def mkdirs(_paths):
    for path in _paths:
        if not os.path.isdir(path):
            os.mkdir(path)
            pass
        pass
    pass

#def raw_file(_sub):
#    root    = CFG.OUTPUT_PATH+ _sub + u"/"
#    dst     = "../data/" + _sub + u"/"
#    fnames  = glob.glob1( root, u"*.*" )
#    for f in fnames:
#        shutil.copyfile(root+f, dst+f)
#        pass
#    pass

def raw_file(_sub):
    #root    = CFG.OUTPUT_PATH+ _sub + u"/"
    #if _sub == "client":
    #    dst = "../../slg_client/Assets/Lua/data/"
    #elif _sub == "server":
    #    dst = "../../../server/service/game/script/data/"
    #fnames  = glob.glob1( root, u"*.*" )
    #for f in fnames:
    #    shutil.copyfile(root+f, dst+f)
    #    pass
    pass