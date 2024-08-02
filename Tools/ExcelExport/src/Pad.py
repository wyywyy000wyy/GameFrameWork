# coding=utf8
# $Id$
#

import src.CFG as CFG
import util.string_wrapper
import src.format_config as format_config
import logging,os

class Base(object):
    def __init__( self, _reader ):
        self.reader_    = _reader
        self.export_type_      = CFG.RULE_NUM_NONE
        pass

    def export_data(self,_rule):
        self.export_type_      = _rule
        if not self.export_define():
            logging.error(u"export define failed.")
            return False
        import re
        r = re.findall("(Define[\w\d]+.xls)",self.reader_.xls_filename_)
        if len(r) > 0:
            print ("skip file: %s"%self.reader_.xls_filename_)
            return True
        if not self.export_record(_rule):
            return False
        return True
    
    def get_record_path(self):
        if self.export_type_ == CFG.RULE_NUM_SERVER:
            return self.reader_.header_.srv_fn_
        if self.export_type_ == CFG.RULE_NUM_CLIENT:
            return self.reader_.header_.client_fn_
        raise EOFError
    
    def get_define_path(self):
        define_information  = self.reader_.header_.define_information_
        if self.export_type_ == CFG.RULE_NUM_SERVER:
            return define_information.srv_fn_
        if self.export_type_ == CFG.RULE_NUM_CLIENT:
            return define_information.client_fn_
        raise EOFError
    
    def is_field_empty(self):
        if self.export_type_ == CFG.RULE_NUM_SERVER:
            return self.reader_.header_.table_header_.server_field_count_ == 0
        if self.export_type_ == CFG.RULE_NUM_CLIENT:
            return self.reader_.header_.table_header_.client_field_count_ == 0
        raise EOFError

    def export_define(self):
        if not self.reader_.header_.need_export_define_:
            return True
        define_information  = self.reader_.header_.define_information_
        table_header        = self.reader_.header_.table_header_
        return self.raw_export_define(define_information,table_header)
    
    pass

class OldLua(Base):
    def __init__( self, _reader ):
        Base.__init__(self,_reader)
        pass

    def export_record(self,_rule):
        if self.is_field_empty():
            return True
        table_header = self.reader_.header_.table_header_

        # 检查目录是否存在
        record_path = self.get_record_path()
        directory = os.path.dirname(record_path)
        if not os.path.exists(directory):
            print("Directory does not exist: %s" % directory)
            return  # 目录不存在，退出方法
        
        fd = open(record_path,"wt")
        fd.write(u'--\n-- $Id$\n--\n\n')
        # if self.export_type_ == CFG.RULE_NUM_SERVER:
        #     fd.write("module( \"resmng\" )\n")
        #    fd.write("svnnum(\"$Id$\")\n\n")
        fd.write("module( \"resmng\" )\n")

        if self.export_type_ == CFG.RULE_NUM_CLIENT:
            field_count = 0
            fd.write(u"%sKey = {\n" % self.reader_.header_.table_name_)
            for i in range(0, table_header.field_count_, 1):
                name = table_header.field_name_[i]
                if name == u"FormatDefine" or name == u"IDString":
                    continue
                if table_header.check_color_rule(i, name, _rule):
                    field_count = field_count + 1
                    fd.write(u'%s = %d, ' % (name, field_count))
                    pass
                pass
            fd.write(u'\n}\n\n')

        # 类型信息 xxTypeInfo = {...}
        fd.write(u"%s_TypeInfo = {"%(self.reader_.header_.table_name_))
        for i in range(0, table_header.field_count_, 1):
            name = table_header.field_name_[i]
            if table_header.check_color_rule(i, name, _rule):
                info = table_header.typeinfo.get(i)
                if info:
                    fd.write(" %s = [[%s]], "%(name, info))
        fd.write(u"}\n\n")

        fd.write(u"%s = {\n\n"%self.reader_.header_.table_name_)
        
        #check_dual_map_ = {}
        for item in self.reader_.records_:
            for i in range(0, table_header.field_count_, 1 ):
                name = table_header.field_name_[ i ]
                
                if name == u"FormatDefine" or name == u"IDString":
                    continue
                i_name = "%s:%d"%(name,i)
                if i == 0:
                    fd.write(u"\t[%s] = {"%item[ i_name ])
                    '''if not check_dual_map_.has_key( item[ i_name] ):
                        check_dual_map_[item[ i_name ]] = True
                    else:
                        logging.error("dul index id: "+item[ i_name])'''
                        #raise IndexError
                if table_header.check_color_rule(i,name,_rule):
                    val = item[ i_name ]
                    if name == u"resIds":
                        pass
                    if val == "":
                        val = "nil"
                    fd.write(u" %s = %s,"%(name , val ) )
                    pass
                pass
            fd.write(u"},\n")
            fd.flush()
            pass
        fd.write(u"}\n")
        tn = self.reader_.header_.table_name_
        fd.write(format_config.server_byid%(tn,tn,tn))
        fd.close()
        return True

    def raw_export_define(self,_define_information,_table_header):
        if util.string_wrapper.is_blank_str(self.get_define_path()):
            return True
        fd = open(self.get_define_path(),"wt")
        fd.write(u'--\n-- $Id$\n--\n\n')
        # if self.export_type_ == CFG.RULE_NUM_SERVER:
        #     fd.write("module( \"resmng\" )\n")
        #    fd.write("svnnum(\"$Id$\")\n\n")
        fd.write("module( \"resmng\" )\n")
        
        ret = True
        #check_dual_map_ = {}
        for item in self.reader_.records_:
            key = _table_header.field_name_[0]
            val = _table_header.field_name_[1]
            if util.string_wrapper.is_number(key):
                fd.close()
                os.remove(_define_information.srv_fn_)
                return True
            
            kk = "%s:%d"%(key,0)
            kv = "%s:%d"%(val,1)
            fd.write(u"%s = %s\n"%(item[kk], item[kv]))
            '''if not check_dual_map_.has_key( item[kv] ):
                check_dual_map_[item[kv]] = True
            else:
                ret = False
                print "defined dual key field detected."'''
            pass
        fd.close()
        #ret = util.syntax_checker.check_lua_syntax(self.get_define_path())
        if not ret:
            logging.error("export lua define fail. context information: %s"%self.reader_.debug_info_define())
        return ret
    pass

class Lua(Base):
    def __init__( self, _reader ):
        Base.__init__(self,_reader)
        pass

    def export_record(self,_rule):
        if self.is_field_empty():
            return True
        table_header = self.reader_.header_.table_header_
        fd = open(self.get_record_path(),"wt")
        fd.write(u'--\n-- $Id$\n--\n\n')
        if self.export_type_ == CFG.RULE_NUM_SERVER:
            fd.write("module( \"resmng\" )\n")
        #    fd.write("svnnum(\"$Id$\")\n\n")
            pass
        else:
            fd.write("local getmetatable = getmetatable\nlocal setmetatable = setmetatable\nlocal string = string\nlocal unpack = unpack\n_ENV = resmng\n")
        
        # 类型信息 xxTypeInfo = {...}
        fd.write(u"%s_TypeInfo = {" % (self.reader_.header_.table_name_))
        for i in range(0, table_header.field_count_, 1):
            name = table_header.field_name_[i]
            if table_header.check_color_rule(i, name, _rule):
                info = table_header.typeinfo.get(i)
                if info:
                    fd.write("%s = [[%s]], " % (name, info))
        fd.write(u"}\n\n")

        # 
        field_count = 0
        fd.write(u"%sLANGKey = {\n"%self.reader_.header_.table_name_)
        for i in range(0, table_header.field_count_, 1 ):
            name = table_header.field_name_[ i ]
            if name == u"FormatDefine" or name == u"IDString":
                continue
            if table_header.check_color_rule(i,name,_rule):
                field_count = field_count + 1
            if table_header.check_color_rule(i,name,CFG.RULE_NUM_LANG):
                fd.write(u'%s = %d, '%(name,field_count))
                pass
            pass
        fd.write(u'\n}\n\n')

        field_count = 0
        fd.write(u"%sFUNCKey = {\n"%self.reader_.header_.table_name_)
        for i in range(0, table_header.field_count_, 1 ):
            name = table_header.field_name_[ i ]
            if name == u"FormatDefine" or name == u"IDString":
                continue
            if table_header.check_color_rule(i,name,_rule):
                field_count = field_count + 1
            #if table_header.check_color_rule(i,name,CFG.RULE_NUM_FUNC):
            #    fd.write(u'%s = %d, '%(name,field_count))
                pass
            pass
        fd.write(u'\n}\n\n')
        
        field_count = 0
        fd.write(u"%sKey = {\n"%self.reader_.header_.table_name_)
        for i in range(0, table_header.field_count_, 1 ):
            name = table_header.field_name_[ i ]
            if name == u"FormatDefine" or name == u"IDString":
                continue
            if table_header.check_color_rule(i,name,_rule):
                field_count = field_count + 1
                fd.write(u'%s = %d, '%(name,field_count))
                pass
            pass
        fd.write(u'\n}\n\n')
        

        
        fd.write(u"%sData = {\n\n"%self.reader_.header_.table_name_)
        
        count = 0
        for item in self.reader_.records_:
            if "cli_useless" in item:
                continue
            pass
            for i in range(0, table_header.field_count_, 1 ):
                name = table_header.field_name_[ i ]
                
                if name == u"FormatDefine" or name == u"IDString":
                    continue
                i_name = "%s:%d"%(name,i)
                if i == 0:
                    fd.write(u"\t[%s] = {"%item[ i_name ])
                    pass
                if table_header.check_color_rule(i,name,_rule):
                    val = item[ i_name ]
                    if name == u"resIds":
                        pass
                    if val == "":
                        val = "nil"
                    fd.write(u"%s, "%(val ) )
                    pass
                pass
            fd.write(u"},\n")
            fd.flush()
            count = count + 1
            pass
        fd.write(u"}\n\n")
        #添加行数变量
        fd.write(u"%sDataCount = %d"%(self.reader_.header_.table_name_,count))
        fd.write(u"\n")

        tn = self.reader_.header_.table_name_
        if self.reader_.header_.table_name_ == "propLanguage":
            fd.write(u'''

function %sById(_key_id)
    local id_data = %sData[_key_id]
    if id_data == nil then
        return nil
    end
    if getmetatable(id_data) == nil then
        setmetatable(id_data, %s_mt)
    end
    return id_data[propLanguageKey[LANGUAGE]]
end

'''%(tn,tn,tn))
            pass
        elif self.reader_.header_.need_export_spec_ :
            
            fd.write(u'''
local %s_mt = {}
local skill_lv = -1
%s_mt.__index = function (_table, _key)
	if _key == "LV" then
		return skill_lv
	end

	local function parse_tables( effct_ex, skill_lv)
		if effct_ex and type(effct_ex) == 'table' and #effct_ex > 0 then
			local tbl_effects = {}

			for i,v in ipairs(effct_ex) do
				
				local tbls = {}
                if type(v) == "table" then
					for j,tl in ipairs(v) do

						if type(tl) == "table" then
							table.insert(tbls,tl)
						elseif type(tl) == 'function'  then

						elseif type(tl) == 'string' then
							if string.find(tl,"%%%%d") and string.find(tl,"return") then
								tl = string.format_order(tl,skill_lv)
								tl = loadstring(tl)()
							end
							table.insert(tbls,tl)
						else
							table.insert(tbls,tl)
						end
					end
					table.insert(tbl_effects,tbls)
				else
					return effct_ex
				end
			end
			
			return tbl_effects
		elseif effct_ex and type(effct_ex) == 'string' then
			if string.find(effct_ex,"%%%%d") and string.find(effct_ex,"return") then
				effct_ex = string.format_order(effct_ex,skill_lv)
				effct_ex = loadstring(effct_ex)()
			end
		end
		return effct_ex
	end

    local lang_idx = %sLANGKey[_key]
    if lang_idx then
		local lang_str = propLanguageById(_table[lang_idx])

		local idx_ex = %sKey[_key .. "ARG"]
		local lang_args = _table[idx_ex]
		
		lang_args = parse_tables(lang_args,skill_lv)

		if lang_args then
			local tbls = {}
			for i,v in ipairs(lang_args) do
				table.insert(tbls,v[1])
			end
			
			if tbls and type(tbls) == "table" and #tbls > 0 then
				return string.format_order(lang_str,unpack(tbls))
			end
		else
			return lang_str	
		end
    end

    local idx = %sKey[_key]
    
    if not idx then
        return nil
    end

    if idx then
    	local effct_ex = _table[idx]

    	effct_ex = parse_tables(effct_ex,skill_lv)
 		if effct_ex then
 			return effct_ex
 		end
    end

    return _table[idx]
end'''%(tn,tn,tn,tn,tn))

            fd.write(u'''
function %sById(_key_id)
    local id_data = %sData[_key_id]
	skill_lv = _key_id %% 100
	

        local src_id = math.floor(_key_id / 100)
		
		id_data = %sData[src_id]
		if id_data == nil then
			return nil
		end
		
		local ldx = %sKey["TypeID"]
		if ldx and id_data[ldx] == 1 then
			skill_lv = src_id %% 100
		end
		local ldx = %sKey["MAXLV"]

		if ldx and skill_lv > id_data[ldx] then
			return nil
		end

    if getmetatable(id_data) == nil then
        setmetatable(id_data, %s_mt)
    end
    return id_data
end
'''%(tn,tn,tn,tn,tn,tn))

            pass
        else:
            
            fd.write(u'''

local %s_mt = {}
%s_mt.__index = function (_table, _key)
    local func_idx = %sFUNCKey[_key]
    if func_idx then
        local func_args = _table[func_idx]
        if type(func_args) == "string" then
            return common_config_func( _table, func_args )
        elseif type(func_args) == "table" then
            return common_config_func( _table, unpack(func_args) )
        else
            return nil
        end
    end

    local lang_idx = %sLANGKey[_key]
    if lang_idx then
		local lang_str = propLanguageById(_table[lang_idx])
		local idx_ex = %sKey[_key .. "ARG"]
		local lang_args = _table[idx_ex]
		if lang_args then
			if #lang_args > 0 then
				return string.format_order(lang_str,unpack(lang_args))
			end
		end
		return lang_str
    end
    local idx = %sKey[_key]
    if not idx then
        return nil
    end
    return _table[idx]
end'''%(tn,tn,tn,tn,tn,tn))
            fd.write(u'''

function %sById(_key_id)
    local id_data = %sData[_key_id]
    if id_data == nil then
        return nil
    end
    if getmetatable(id_data) == nil then
        setmetatable(id_data, %s_mt)
    end
    return id_data
end

'''%(tn,tn,tn))
            pass
        fd.close()
        return True 

    def raw_export_define(self,_define_information,_table_header):
        if util.string_wrapper.is_blank_str(self.get_define_path()):
            return True
        fd = open(self.get_define_path(),"wt")
        fd.write(u'--\n-- $Id$\n--\n\n')
        logging.info("     export define, %d\n",self.export_type_)
        if self.export_type_ == CFG.RULE_NUM_SERVER:
            fd.write("module( \"resmng\" )\n")
        #    fd.write("svnnum(\"$Id$\")\n\n")
            pass
        else:
            fd.write("local getmetatable = getmetatable\nlocal setmetatable = setmetatable\nlocal string = string\nlocal unpack = unpack\n_ENV = resmng\n")
        
        ret = True
        for item in self.reader_.records_:
            if "cli_useless" in item:
                continue
            pass
            key = _table_header.field_name_[0]
            val = _table_header.field_name_[1]
            if util.string_wrapper.is_number(key):
                fd.close()
                os.remove(_define_information.srv_fn_)
                return True
            
            kk = "%s:%d"%(key,0)
            kv = "%s:%d"%(val,1)
            fd.write(u"%s = %s\n"%(item[kk], item[kv]))
            pass
        fd.close()
        if not ret:
            logging.error("export lua define fail. context information: %s"%self.reader_.debug_info_define())
        return ret
    
    pass



# 专门导出语言包
class LanguageLua(Base):
    def __init__( self, _reader ):
        Base.__init__(self,_reader)
        pass

    def export_record(self,_rule):
        self.export_sub_language_package(_rule)
        return True 

    def raw_export_define(self,_define_information,_table_header):
        if util.string_wrapper.is_blank_str(self.get_define_path()):
            return True
        fd = open(self.get_define_path(),"wt")
        fd.write(u'--\n-- $Id$\n--\n\n')
        if self.export_type_ == CFG.RULE_NUM_SERVER:
            fd.write("module( \"resmng\" )\n")
        #    fd.write("svnnum(\"$Id$\")\n\n")
            pass
        else:
            fd.write("local getmetatable = getmetatable\nlocal setmetatable = setmetatable\nlocal string = string\nlocal unpack = unpack\n_ENV = resmng\n")
        
        ret = True
        for item in self.reader_.records_:
            key = _table_header.field_name_[0]
            val = _table_header.field_name_[1]
            if util.string_wrapper.is_number(key):
                fd.close()
                os.remove(_define_information.srv_fn_)
                return True
            
            kk = "%s:%d"%(key,0)
            kv = "%s:%d"%(val,1)
            fd.write(u"%s = %s\n"%(item[kk], item[kv]))
            pass
        fd.close()
        if not ret:
            logging.error("export lua define fail. context information: %s"%self.reader_.debug_info_define())
        return ret
    
    def export_sub_language_package(self,_rule):
        floder = "client"
        if self.export_type_ == CFG.RULE_NUM_SERVER:
            floder = "server"
        pass
        if self.is_field_empty():
            return True
        table_header = self.reader_.header_.table_header_
        
        tn = self.reader_.header_.table_name_
        field_count = table_header.field_count_
        output_path =  os.path.join( os.getcwd() , CFG.OUTPUT_PATH )

        for i in range(2, field_count, 1 ):
            name = table_header.field_name_[ i ]
            if table_header.check_color_rule(i, name, _rule):
                old_file = ( output_path+"%s/prop_lang_%s.lua"%(floder,name) ).lower()
                fd = open(old_file,"w")
                if self.export_type_ == CFG.RULE_NUM_SERVER:
                    fd.write("module( \"resmng\" )\n\n\npropLang = {\n")
                else:
                    fd.write("\nlocal getmetatable = getmetatable\nlocal setmetatable = setmetatable\nlocal string = string\nlocal unpack = unpack\n_ENV = resmng\npropLang = {\n")
                fd.close()

        field_count = 1
        for i in range(2, table_header.field_count_, 1 ):
            name = table_header.field_name_[ i ]
            if table_header.check_color_rule(i,name,_rule):
                fd = open((output_path+"/%s/prop_lang_%s.lua"%(floder,name) ).lower(),"a")
                field_count = field_count + 1

                for item in self.reader_.records_:
                    for i in range(0, table_header.field_count_, 1 ):
                        if i == field_count:
                            name = table_header.field_name_[ i ]
                            i_name = "%s:%d"%(name,i)
                            val = item[ i_name ]
                            if name == u"resIds":
                                pass
                            if val == "":
                                val = "nil"
                            fd.write("\t[%s] = %s,\n"%(item[ "ID:0" ],val))
                            fd.flush()
                    pass
                fd.write("}\n")
                fd.close()
            pass
    
    pass