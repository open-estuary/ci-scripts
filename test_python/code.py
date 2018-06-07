#!/usr/bin/python
# -*- coding: utf-8 -*-
import os

linestrlist = []
linelist = []
locate_list = {}

def test():
    if os.path.getsize("/home/luojiaxing/empty") == 0:
        with open("/home/luojiaxing/empty", 'w') as wfp:
               wfp.write("[\"%s\", " % "None")
               wfp.write("\"%s\", " % "None")
               wfp.write("\"%s\", " % "None")
               wfp.write("\"%s\", " % "None")
               wfp.write("],\n")


