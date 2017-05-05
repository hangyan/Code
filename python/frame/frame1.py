import sys


def one():
    two()


def two():
    three()


def three():
    for num in range(3):
        frame = sys._getframe(num)
        show_frame(num, frame)


def show_frame(num, frame):
    print frame
    print "  frame     = sys._getframe(%s)" % num
    print "  function  = %s()" % frame.f_code.co_name
    print "  file/line = %s:%s" % (frame.f_code.co_filename, frame.f_lineno)


one()
