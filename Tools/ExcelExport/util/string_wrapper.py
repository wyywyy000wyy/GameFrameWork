# coding=utf8
# $Id$
# process string task.
#

'''
转换字符串
propItem=>prop_item.lua
'''
def gen_lua_filename(_tbl_name):
    import re
    remain = _tbl_name
    result = re.search(u"[A-Z]", remain )
    file_name = u""
    if result == None:
        file_name = _tbl_name
        pass
    else:
        while result != None:
            if result.start() == 0:
                file_name = file_name + remain[:result.start()] + remain[ result.start():result.start()+1 ]
                pass
            else:
                file_name = file_name + remain[:result.start()] + "_" + remain[ result.start():result.start()+1 ]
                pass
            remain = remain[result.start()+1:]
            result = re.search(u"[A-Z]", remain )
            if result == None:
                file_name += remain
                break
            pass
    file_name += u".lua"
    file_name = file_name.lower()
    return file_name

'''

'''

'''
检查EXCEL是无用的单元格
'''
def is_blank_str(_str):
    if _str == u"" or _str.find(u"//") == 0:
        return True
    return False

'''
转换EXCEL中的数字，防止出错
填的整数，导表可能读成浮点类型 1.0 需要处理一下
'''
def convert_num(_raw_str):
    if type(_raw_str) != float:
        return _raw_str
    i_val = int(_raw_str)
    f_val = _raw_str - i_val
    f_val = int(f_val * 1000)
    if f_val != 0 :
        return str(_raw_str)
    return str(int(_raw_str))

'''
处理中文问题，将python的encoding强制设置为UTF-8
'''
def set_default_encoding():
    import sys
    # reload(sys)
    # sys.setdefaultencoding('utf-8')
    print(u"initialize> set default encoding done.")
    pass

def replace_all(_raw_text,_raw_tag,_replace_tag):
    ret_str = _raw_text
    while ret_str.find(_raw_tag) != -1:
        ret_str = ret_str.replace(_raw_tag,_replace_tag)
        pass
    return ret_str

def my_trim(_raw_text):
    if len(_raw_text) == 0 or _raw_text[:1] != u'"' or _raw_text[len(_raw_text)-1] != u'"':
        return _raw_text
    return replace_all(_raw_text,u" ",u"")

def is_number(_raw_text):
    try:
        float(_raw_text)
        pass
    except ValueError:
        return False
    return True

'''
将配置表中的TEXT转换成为可以放到XML中；
重点能替换掉其中包含 Define_Data中的内容
1.是通过递归函数来做实现；
2.对于自己需要处理的事情将使用分类来做处理；
'''
def convert_xml_text(_raw_text,_define_num_mng):
    ret_str = my_trim(_raw_text)
    if ret_str == u"":
        return ret_str
    if ret_str == u"=":
        return u"-1"
    if ret_str[:1] == u'"' or ret_str[len(ret_str)-1] == u'"':
        return replace_all(ret_str,u'"',u'')
    if ret_str == u'true' or ret_str == u'false':
        return ret_str
    if ret_str[:1] == u'{' or ret_str[len(ret_str)-1] == u'}':
        tmp_str = u""
        sub_str = u""
        for i in range(0,len(ret_str)):
            cur_char = ret_str[i]
            if cur_char == u'"' and 0 != len(sub_str):
                tmp_str += sub_str + cur_char
                sub_str = u''
                pass
            if cur_char == u'{' or cur_char == u'}' or cur_char == u',':
                if sub_str != u'':
                    tmp_str +=  convert_xml_text(sub_str,_define_num_mng)
                    sub_str =   u''
                    pass
                tmp_str += cur_char
                pass
            else:
                sub_str += cur_char
                pass
            pass
        return tmp_str
    if is_number(ret_str):
        return ret_str
    element = _define_num_mng.get_val(ret_str)
    if element != None:
        ret_str = element.val_
        pass
    return ret_str
