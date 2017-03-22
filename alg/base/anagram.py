#!/usr/bin/env python
# -*- coding: utf-8 -*-



__author__ = 'Hang Yan'



def anagram_solution1(s1, s2):
    a_list = list(s2)
    pos1 = 0
    still_ok = True

    while pos1 < len(s1) and still_ok:
        pos2 = 0
        found = False

        while pos2 < len(a_list) and not found:
            if s1[pos1] == a_list[pos2]:
                found = True
            else:
                pos2 += 1

        if found:
            a_list[pos2] = None
        else:
            still_ok = False

        pos1 = pos1 + 1

    return still_ok


print(anagram_solution1('abcd', 'dcba'))



def anagram_solution2(s1, s2):
    a_list1 = list(s1)
    a_list2 = list(s2)

    a_list1.sort()
    a_list2.sort()


    pos = 0
    matches = True


    while pos < len(s1) and matches:
        if a_list1[pos] == a_list2[pos]:
            pos = pos +1
        else:
            matches = False

    return matches


print(anagram_solution2('abcde', 'edcba'))
