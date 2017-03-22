#!/usr/bin/env python
# -*- coding: utf-8 -*-

import time


__author__ = 'Hang Yan'




def sum_of_n_2(n):
    start = time.time()

    the_sum = 0
    for i in range(1, n+1):
        the_sum += i

    end = time.time()

    return the_sum, end-start



for i in range(5):
    print "Sum is {} %10.7f secounds".format(sum_of_n_2(10000))

    
