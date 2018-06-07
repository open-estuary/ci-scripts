#!/usr/bin/python
# -*- coding: utf-8 -*-

linestrlist = []
linelist = []
locate_list = {}
def test():
    with open("/home/luojiaxing/result.txt", 'r') as resultf:
        for line in resultf.readlines():
            #linestr = line.strip()
            linestrlist = line.split("\t")
            linestrlist[0]=linestrlist[0].strip()
            print linestrlist
            linelist=map(str,linestrlist)
            locate_list[linelist[0]]=linelist[1].strip("\n")
            print "New issue locate item with key %s , locate info is %s" %( linelist[0] , locate_list[linelist[0]] )


