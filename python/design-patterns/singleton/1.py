import threading


class Singleton(object):
    """Non thread safe"""
    _instance = None
    def __new__(cls, *args, **kwargs):
        if not cls._instance:
            cls._instance = super(Singleton, cls).__new__(cls, *args, **kwargs)
        return cls._instance



class TFSingleTon(object):
    objs = {}
    objs_locker = threading.Lock()

    def __new__(cls, *args, **kwargs):
        if cls in cls.objs:
            return cls.objs[cls]
        cls.objs_locker.acquire()
        try:
            if cls in cls.objs:
                return cls.objs[cls]
            cls.objs[cls] = objects.__new__(cls)

        finally:
            cls.objs.





            


if __name__ == '__main__':
    s1 = Singleton()
    s2 = Singleton()
    print id(s1)
    print id(s2)

    
