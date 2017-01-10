import gc

import objgraph

gc.disable()


class A(object):
	pass

class B(object):
	pass

def test1():
	a = A()
	b = B()

test1()
print objgraph.count('A')
print objgraph.count('B')


def test2():
    a = A()
    b = B()
    a.child = b
    b.parent = a

test2()
print 'Object count of A:', objgraph.count('A')
print 'Object count of B:', objgraph.count('B')
gc.collect()
print 'Object count of A:', objgraph.count('A')
print 'Object count of B:', objgraph.count('B')