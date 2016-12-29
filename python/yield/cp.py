def produce(c):
    n = 0
    next(c)
    while n < 6:
        n += 2
        print('Produce 2 ,total %d' % n)
        n = c.send(n)
        print('Left: %d' %n)

    c.close()


def consumer():
    n = 0 
    print('Consumer init...')
    while True:
        n = yield n
        if not n:
            return
        n -= 1
        print('Consume 1, left %d' % n)


c = consumer()
produce(c)
