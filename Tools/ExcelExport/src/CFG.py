# coding=utf8
# $Id: CFG.py 266 2013-03-07 06:58:25Z abel $
#


OUTPUT_PATH         = u"../../../"

# 导出命令行定义
FLAG_NONE           = 0
FLAG_ALL_FILE       = 2
FLAG_CLEAR          = 3


# EXCEL中的颜色规则定义
RULE_COLOR_USELESS  = u"(150,150,150)"
RULE_COLOR_SERVER   = u"(255,255,0)"
RULE_COLOR_CLEINT   = u"(255,0,0)"
RULE_COLOR_BOTH     = u"(153,204,0)"
RULE_COLOR_LANG     = u"(0,200,200)"
RULE_COLOR_LANG1    = u"(0,255,255)"
RULE_COLOR_ENDING   = u"(0,0,0)"
RULE_COLOR_FUNC 	= u"(112,48,160)"
RULE_COLOR_CLI_USELESS 	= u"(112,48,160)"

# EXCEL导出规则
RULE_NUM_USELESS    = 0
RULE_NUM_SERVER     = 1
RULE_NUM_CLIENT     = 2
RULE_NUM_BOTH       = RULE_NUM_SERVER | RULE_NUM_CLIENT
RULE_NUM_ENDING     = 4
RULE_NUM_NONE       = 8
RULE_NUM_LANG_RAW	= 16
RULE_NUM_LANG       = RULE_NUM_LANG_RAW | RULE_NUM_CLIENT | RULE_NUM_SERVER
RULE_NUM_RAW		= 32
RULE_NUM_FUNC		= RULE_NUM_RAW | RULE_NUM_CLIENT
RULE_NUM_CLI_USELESS = 64#客户端行不导出
RULE_NUM_TYPEINFO = 128 # 类型定义


# 颜色对应表
COL_TBL_RAW                     = {}
#COL_TBL_RAW[RULE_COLOR_USELESS] = RULE_NUM_USELESS
#COL_TBL_RAW[RULE_COLOR_SERVER]  = RULE_NUM_SERVER
#COL_TBL_RAW[RULE_COLOR_CLEINT]  = RULE_NUM_CLIENT
#COL_TBL_RAW[RULE_COLOR_BOTH]    = RULE_NUM_BOTH
#COL_TBL_RAW[RULE_COLOR_ENDING]  = RULE_NUM_ENDING
#COL_TBL_RAW[RULE_COLOR_LANG]    = RULE_NUM_LANG | RULE_NUM_CLIENT | RULE_NUM_SERVER
#COL_TBL_RAW[RULE_COLOR_LANG1]    = RULE_NUM_LANG | RULE_NUM_CLIENT | RULE_NUM_SERVER

