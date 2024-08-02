# coding=utf8
# $Id: Loader.py 1421 2013-04-02 06:52:10Z abel $
# load export rule information, record etc.
#

import re,os,logging

import util.excel_wrapper
import util.string_wrapper
import src.CFG as CFG


# 加载器状态机
LOADER_STATE_HEAD   = 0
LOADER_STATE_NAME   = 1
LOADER_STATE_RULE   = 2
LOADER_STATE_TYPEINFO = 3 # 加载类型定义
LOADER_STATE_DATA   = 4
LOADER_STATE_ENDING = 5


class DefineInformation(object):
    def __init__(self):
        self.client_fn_             = u""
        self.srv_fn_                = u""
        self.as_classname_          = u""
        self.as_namespace_          = u""
        pass

    def set_client_fn(self,_fn):
        self.client_fn_             = CFG.OUTPUT_PATH + u"Client/Assets/Code/Lua/config/" + _fn
        pass

    def set_svr_fn(self,_fn):
        self.srv_fn_                = CFG.OUTPUT_PATH + u"Server/Lua/config/" + _fn
        pass

    def set_define_filename(self,_table_name):
        raw_fn = util.string_wrapper.gen_lua_filename(_table_name)
        # raw_fn = raw_fn.replace("prop","define", 1)
        if "prop" in raw_fn:
            raw_fn = raw_fn.replace("prop", "define", 1)
        else:
            raw_fn = "define_" + raw_fn

        logging.info("set_define_filename raw_fn:%s"%raw_fn)
        self.set_client_fn(raw_fn)
        self.set_svr_fn(raw_fn)
    pass

class Header(object):
    def __init__(self):
        self.need_export_define_    = False
        self.need_export_spec_      = False
        self.define_information_    = DefineInformation()
        self.table_name_            = u""
        self.table_header_          = TableHeader()
        self.srv_fn_                = u""
        self.client_fn_          = u""
        pass
    # 设置导出luatable 名
    def set_table_name(self,_text):
        self.table_name_            = _text
        # self.define_information_.set_define_filename(self.table_name_)
        pass
    # 设置导出文件名，包括define文件名和真实lua文件名
    def set_file_name(self,_text):
        self.client_fn_          = CFG.OUTPUT_PATH + u"Client/Assets/Code/Lua/config/" + util.string_wrapper.gen_lua_filename(_text)
        self.srv_fn_                = CFG.OUTPUT_PATH + u"Server/Lua/config/" + util.string_wrapper.gen_lua_filename(_text)
        self.define_information_.set_define_filename(_text)
        pass
    pass

class TableHeader(object):
    def __init__(self):
        self.color_rule_            = {}
        self.field_name_            = {}
        self.server_field_count_    = 0
        self.client_field_count_    = 0
        self.field_count_           = 0
        # 类型定义
        self.typeinfo = {}
        pass

    def append_field(self,_column,_field,_rule):
        k = self.raw_color_key(_column,_field)
        self.color_rule_[k]                 = _rule
        self.field_name_[_column]           = _field

        if (_rule & CFG.RULE_NUM_CLIENT) == CFG.RULE_NUM_CLIENT:
            self.client_field_count_    += 1
            pass
        if (_rule & CFG.RULE_NUM_SERVER) == CFG.RULE_NUM_SERVER:
            self.server_field_count_    += 1
            pass
        self.field_count_               += 1
        pass

    def check_color_rule(self,_column,_field,_col):
        k       = self.raw_color_key(_column,_field)
        rule    = self.color_rule_[k]
        return( rule & _col ) == _col

    def raw_color_key(self,_column,_field):
        k = "%s:%d"%(_field,_column)
        return k

    def set_typeinfo(self, _column, typeinfo):
        self.typeinfo[_column] = typeinfo

    pass

class Porter(object):
    def __init__(self,_xls_filename):
        self.reader_                = util.excel_wrapper.Reader(_xls_filename)
        self.cur_row_num_           = 0
        self.current_state_         = LOADER_STATE_HEAD
        self.header_                = Header()
        self.records_               = []
        self.xls_filename_          = _xls_filename
        self.out_filename_          = u"" # 输出文件名
        pass

    def process(self):
        # 发现一个问题，有的excel结束的黑色存在问题，会造成导表程序死机
        while self.current_state_ != LOADER_STATE_ENDING:
            if self.current_state_ == LOADER_STATE_HEAD:
                if not self.read_head():
                    self.current_state_ = LOADER_STATE_NAME
                    pass
                pass
            elif self.current_state_ == LOADER_STATE_NAME:
                if not self.read_name():
                    self.current_state_ = LOADER_STATE_RULE
                pass
            elif self.current_state_ == LOADER_STATE_RULE:
                if not self.read_rule():
                    self.current_state_ = LOADER_STATE_TYPEINFO
                    pass
            elif self.current_state_ == LOADER_STATE_TYPEINFO:
                if not self.read_typeinfo():
                    self.current_state_ = LOADER_STATE_DATA
                pass
            elif self.current_state_ == LOADER_STATE_DATA:
                if not self.read_data():
                    self.current_state_ = LOADER_STATE_ENDING
            elif self.current_state_ == LOADER_STATE_ENDING:
                break
            self.cur_row_num_ += 1
            if self.cur_row_num_ > 1000000:
                logging.warn(u"data line huge filename: %s"%self.xls_filename_)
                break
            pass
        pass

    def read_head(self):
        text = self.reader_.get_cell_value( self.cur_row_num_, 0 )
        head = re.compile("^//")
        if not head.match( text ):
            self.cur_row_num_ -= 1
            return False

        val = self.reader_.get_cell_value( self.cur_row_num_, 1 )
        color = self.reader_.extract_cell_color( self.cur_row_num_, 1 )

        if u"//AS文件头" == text:
            self.header_.define_information_.as_namespace_  = val
            return False

        define_info = self.header_.define_information_

        if u"//同时导出Define" == text:
            if val != u"":
                if type(val) == int:
                    self.header_.need_export_define_ = bool(val)
                    pass
                else:
                    self.header_.need_export_define_ = bool(val.lower() == "true")
                    pass
                pass
            pass
        elif text.find(u"导出文件名") != -1:
            if val != u"":
                self.out_filename_ = val
                logging.log(logging.INFO, "out_filename_:%s"%self.out_filename_)
                pass
            pass
        elif text.find(u"客户端导出文件名") != -1:
            if val != u"":
                define_info.set_client_fn( val )
                pass
            pass
        elif text.find(u"服务端导出文件名") != -1:
            if val != u"":
                define_info.set_svr_fn( val )
                pass
            pass
        elif text.find(u"Special") != -1:
            if val != u"":
                if type(val) == int:
                    self.header_.need_export_spec_ = bool(val)
                    pass
                else:
                    self.header_.need_export_spec_ = bool(val.lower() == "true")
                    pass
                pass
            pass
        elif u"//服务器和客户端公用" == text:
            CFG.COL_TBL_RAW[color] = CFG.RULE_NUM_BOTH
            pass
        elif u"//服务器端专用" == text:
            CFG.COL_TBL_RAW[color] = CFG.RULE_NUM_SERVER
            pass
        elif u"//客户端专用" == text:
            CFG.COL_TBL_RAW[color] = CFG.RULE_NUM_CLIENT
            pass
        elif u"//客户端专用多语言字段" == text:
            CFG.COL_TBL_RAW[color] = CFG.RULE_NUM_LANG
            pass
        elif u"//客户端专用函数字段" == text:
            CFG.COL_TBL_RAW[color] = CFG.RULE_NUM_FUNC
            pass
        elif u"//不导出" == text:
            CFG.COL_TBL_RAW[color] = CFG.RULE_NUM_USELESS
            pass
        elif u"//结束标志" == text:
            CFG.COL_TBL_RAW[color] = CFG.RULE_NUM_ENDING
        elif u"//客户端行不导出" == text:
            CFG.COL_TBL_RAW[color] = CFG.RULE_NUM_CLI_USELESS
        elif u"//类型定义" == text:
            CFG.COL_TBL_RAW[color] = CFG.RULE_NUM_TYPEINFO
        pass
        return True

    def read_name(self):
        text = self.reader_.get_cell_value( self.cur_row_num_, 0 )
        if util.string_wrapper.is_blank_str(text):
            return True
        #设置luatable 名字
        self.header_.set_table_name(text)
        #设置导出文件名
        if self.out_filename_ == u"":
            self.header_.set_file_name(text)
        else:
            self.header_.set_file_name(self.out_filename_)

        return False

    def read_rule(self):
        text    = self.reader_.get_cell_value( self.cur_row_num_, 0 )
        if util.string_wrapper.is_blank_str(text):
            return True
        color   = self.reader_.extract_cell_color( self.cur_row_num_, 0 )
        if self.raw_color_rule(color) == CFG.RULE_NUM_NONE:
            return True
        self.raw_read_table_header()
        return False

    # 读取类型定义信息，补充header
    def read_typeinfo(self):
        color   = self.reader_.extract_cell_color( self.cur_row_num_, 0 )
        if self.raw_color_rule(color) != CFG.RULE_NUM_TYPEINFO:
            self.cur_row_num_ -= 1
            return False

        for idx, name in self.header_.table_header_.field_name_.items():      
            text = self.reader_.get_cell_value(self.cur_row_num_, idx)
            if not util.string_wrapper.is_blank_str(text):
                self.header_.table_header_.set_typeinfo(idx, text)
        return False

    def read_data(self):
        color       = self.reader_.extract_cell_color( self.cur_row_num_, 0 )
        color_num   = self.raw_color_rule(color)
        if color_num == CFG.RULE_NUM_ENDING:
            logging.info("load %d record"%len(self.records_))
            return False
        elif color_num == CFG.RULE_NUM_USELESS:
            return True
        text = self.reader_.get_cell_value( self.cur_row_num_, 0 )
        text = util.string_wrapper.convert_num(text)
        if util.string_wrapper.is_blank_str(text):
            return True

        '''
        这儿不需要 严格安照是否 同时导出Define 来配置
        if not self.header_.need_export_define_:
            #第一行为非数字和非字符串，第二行为数字，则need_export_define_为true
            if not util.string_wrapper.is_number(text) and text.find(u"\'") == -1 and text.find(u"\"") == -1:
                second_text = self.reader_.get_cell_value( self.cur_row_num_, 1 )
                if util.string_wrapper.is_number(second_text):
                    self.header_.need_export_define_ = True
                pass
            pass
        '''

        record = {}
        for idx, name in self.header_.table_header_.field_name_.items():
            cell_val        = self.reader_.get_cell_value( self.cur_row_num_, idx )
            key             = "%s:%d"%(name,idx)
            record[key]     = util.string_wrapper.convert_num(cell_val)
            pass
        if color_num == CFG.RULE_NUM_CLI_USELESS:
            record["cli_useless"] = True
        pass
        self.records_.append(record)
        return True

    def debug_info_base(self):
        s = u'\nexcel filename: %s'%self.xls_filename_
        return s

    def debug_info_define(self):
        s = self.debug_info_base()
        s += u'\nclient_filename_: %s'%self.header_.define_information_.client_fn_
        s += u'\nsrv_fn_: %s'%self.header_.define_information_.srv_fn_
        s += u'\nas_classname_: %s'%self.header_.define_information_.as_classname_
        s += u'\nas_namespace_: %s'%self.header_.define_information_.as_namespace_
        return s

    #
    # 原生函数
    #
    def raw_color_rule(self,_color):
        if _color in CFG.COL_TBL_RAW:
            return CFG.COL_TBL_RAW[_color]
        return CFG.RULE_NUM_NONE

    def raw_read_table_header(self):
        for column in range( 0, self.reader_.sheet_.ncols, 1 ):
            bc      = self.reader_.extract_cell_color( self.cur_row_num_, column )
            rule    = self.raw_color_rule(bc)
            if rule == CFG.RULE_NUM_NONE:
                break
            field = self.reader_.get_cell_value( self.cur_row_num_, column )
            self.header_.table_header_.append_field(column,field,rule)
            pass
        pass
    pass

