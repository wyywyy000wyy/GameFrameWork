# coding=utf8
# $Id$
#
import re,xlrd
import src.CFG as CFG

class Reader(object):
    def __init__( self, _filename, _sheet_idx = 0 ):
        self.book_   = xlrd.open_workbook( _filename, formatting_info = True )
        self.switch_sheet( _sheet_idx )
        pass

    def switch_sheet( self, _sheet_idx ):
        self.sheet_  = self.book_.sheet_by_index( _sheet_idx )
        pass

    def get_cell_color( self, _row,_column ):
        num = self.extract_cell_color( _row,_column )
        if CFG.COL_TBL_RAW.has_key(num):
            return CFG.COL_TBL_RAW[num]
        return CFG.RULE_NUM_NONE

    def extract_cell_color(self,_row,_column):
        color = 0
        try:
            xf_idx  = self.sheet_.cell_xf_index(_row,_column)
            xf_list = self.book_.xf_list[xf_idx]
            color   = xf_list.background.pattern_colour_index
        except IndexError:
            color = None
        if color == None:
            return 0
        return color

    def get_cell_value(self, _row, _column):
        try:
            value = self.sheet_.cell(_row,_column).value
            if type(value) == float or type(value) == int:
                return value

            value = value.lstrip()
            value = value.rstrip()
            return value
        except IndexError:
            return u""
        pass

    def is_none_row( self, _row ):
        text = self.get_cell_value(_row,0)
        head = re.compile("^//")
        if head.match( text ):
            return True
        if text == u"":
            return True
        return False

    pass

if __name__ == "__main__":
    # R = Reader("d:/Project/work/client/export/config/propInvite.xls")
    # for i in range(1,6):
    #     print R.extract_cell_color( i, 1 )
    #     pass
    pass
