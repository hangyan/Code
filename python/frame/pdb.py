import pdb
import sys


def test():
    frame = sys._getframe(1)
    pdb.set_trace()


def aFunction():
    a = 1
    b = 'hello'
    c = (12, 3.45)
    test()
    d = "This won't show up in the frame"


aFunction()
