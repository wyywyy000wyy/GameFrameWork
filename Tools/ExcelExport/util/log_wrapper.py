# coding=utf8
# $Id$
#


def init_log_setting():
    import logging
    logging.basicConfig( level=logging.DEBUG,
                format='%(levelname)s> %(message)s')
    logging.info(u"initialize> logging done.")
    pass

if __name__ == "__main__":
    init_log_setting()
    pass
