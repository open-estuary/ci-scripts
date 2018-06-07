#!/usr/bin/python
# -*- coding: utf-8 -*-
import os
import yaml

linestrlist = []
linelist = []
locate_list = {}
job_result_dict = {}
WHOLE_SUMMARY_NAME="whole_sum.txt"
LOCATE_SUMMARY_NAME="locate_sum.txt"
PASS_COLOR = 'green'
FAIL_COLOR = 'red'
BLOCK_COLOR = 'yellow'

def generate_test_report(job_id):
    # print testsuite_results
    with open("/home/luojiaxing/lava.yaml") as f:
         test = yaml.load(f)
         #print test
    if job_id not in job_result_dict:
        job_result_dict[job_id] = test
    #print job_result_dict


def generate_email_test_report():
    print "--------------now begin get testjob: result ------------------------------"

    suite_list = []  #all test suite list
    case_dict = {}  #testcast dict value like 'smoke-test':[test-case1,test-case2,test-case3]
    boot_total = 0
    boot_success = 0
    boot_fail = 0
    test_total = 0
    test_success = 0
    test_fail = 0
    suite_total = 0
    suite_success = 0
    suite_fail = 0
    suite_count = 0
    #get all the test suite list from get_testjob_results_yaml
    for job_id in job_result_dict.keys():
        print job_id
        for item in job_result_dict[job_id]:
            #print item
            if suite_list.count(item['suite']) == 0:
                suite_count += 1
                suite_list.append(item['suite'])

    #inital a no value dict
    for suite in suite_list:
        case_dict[suite] = []
    commit_id=''
    #set all the value in dict
    for job_id in job_result_dict.keys():
        for item in job_result_dict[job_id]:
            case_dict[item['suite']].append(item)
            if item['suite'] == "0_Begin-test":
               commit_id = item['unit']
    #try to write summary file
    summary_dir = os.getcwd()
    
    summary_file = os.path.join(summary_dir, WHOLE_SUMMARY_NAME)
    print "The path of summary file is %s" % summary_dir
    if os.path.exists(summary_file):
        os.remove(summary_file)
    
    for key in sorted(case_dict.keys()):
        if key == 'lava':
            for item in case_dict[key]:
                if item['result'] == 'pass':
                    boot_total += 1
                    boot_success += 1
                elif item['result'] == 'fail':
                    boot_total += 1
                    boot_fail += 1
                else:
                    boot_total += 1
        else:
            for item in case_dict[key]:
                if item['result'] == 'pass':
                    test_total += 1
                    test_success += 1
                elif item['result'] == 'fail':
                    test_total += 1
                    test_fail += 1
                else:
                    test_total += 1

    with open(summary_file, 'w') as wfp:
        #get the url of test
        str=case_dict['lava'][0]['url'].split('/')
        #print str
        str.pop(-1)
        str.pop(-1)
        #print str
        lava_url='/'.join(str)
        #print lava_url
        # ["Ubuntu", "pass", "100", "50%", "50", "50", "0"],
        wfp.write("[\"%s\", " % commit_id)
        # always pass for compile result
        if test_fail == 0:
            wfp.write("{\"data\": \"%s\", \"color\": \"%s\", \"link\": \"%s\"}, " %
                  ("pass", PASS_COLOR,"http://120.31.149.194:180" + lava_url))
        else:
            wfp.write("{\"data\": \"%s\", \"color\": \"%s\", \"link\": \"%s\"}, " %
                  ("fail", FAIL_COLOR,"http://120.31.149.194:180" + lava_url))
        wfp.write("{\"data\": \"%s\", \"color\": \"%s\"}, " %
                  ("Huang daode", PASS_COLOR))
        print type(lava_url)
        print type(test_total)

        print "test_total is %s "%test_total
        tmp = repr(test_total)
        print type(tmp)
        wfp.write("{\"data\": \"%s\", \"link\": \"%s\"}, " % (tmp, "http://120.31.149.194:180"+lava_url))
        if test_total == 0:
            wfp.write("\"%.2f%%\", " % (0.0))
        else:
            wfp.write("\"%.2f%%\", " % (100.0 * test_success / test_total))
        wfp.write("{\"data\": \"%s\", \"color\": \"%s\", \"link\": \"%s\"}, " %
                  (repr(test_success), PASS_COLOR,  "http://120.31.149.194:180" + lava_url))
        wfp.write("{\"data\": \"%s\", \"color\": \"%s\", \"link\": \"%s\"}, " %
                  (repr(test_fail), FAIL_COLOR,  "http://120.31.149.194:180" + lava_url))
        wfp.write("{\"data\": \"%s\", \"color\": \"%s\"}" %
                  (repr(test_total - test_success - test_fail), BLOCK_COLOR))
        wfp.write("],\n")
        print "End with the first line!"
        #print wfp
        print case_dict
        #cycle show the result of each test
        for key in sorted(case_dict.keys()):
            if key == 'lava':
                print "No add LAVA result at mial result txt!"
            else:
                print "begin to get the testcase txt!"
                suite_count -= 1
                suite_total = 0
                suite_success = 0
                suite_fail = 0
                for testsuite in case_dict[key]:
                    #get the result count in each testsuit
                    if testsuite['result'] == 'pass':
                       suite_total += 1
                       suite_success += 1
                    elif testsuite['result'] == 'fail':
                       suite_total += 1
                       suite_fail += 1
                    else:
                       suite_total += 1
                    if testsuite['suite'] == "0_Begin-test":
                       maintainer="Luojiaxing"
                    else:
                       maintainer=testsuite['unit']
                if suite_total == suite_success:
                    suite_result = "pass"
                else:
                    suite_result = "fail"
                
                #get the url of test suite
                str=testsuite['url'].split('/')
                print str
                str.pop(-1)
                print str
                suite_url='/'.join(str)
                str.pop(-1)
                result_url='/'.join(str)
                print suite_url

                # ["Ubuntu", "pass", "100", "50%", "50", "50", "0"],
                wfp.write("[\"%s\", " % key)
                # always pass for compile result
                if suite_result == "pass" :
                   wfp.write("{\"data\": \"%s\", \"color\": \"%s\", \"link\": \"%s\"}, " %
                      (suite_result, PASS_COLOR,"http://120.31.149.194:180" + result_url))
                else:
                   wfp.write("{\"data\": \"%s\", \"color\": \"%s\", \"link\": \"%s\"}, " %
                      (suite_result, FAIL_COLOR,"http://120.31.149.194:180" + result_url))
                wfp.write("{\"data\": \"%s\", \"color\": \"%s\"}, " %
                  (maintainer, PASS_COLOR))
                wfp.write("{\"data\": \"%s\", \"link\": \"%s\"}, " % (repr(suite_total), "http://120.31.149.194:180" + suite_url))
                if suite_total == 0:
                   wfp.write("\"%.2f%%\", " % (0.0))
                else:
                   wfp.write("\"%.2f%%\", " % (100.0 * suite_success / suite_total))
                wfp.write("{\"data\": \"%s\", \"color\": \"%s\", \"link\": \"%s\"}, " %
                  (repr(suite_success), PASS_COLOR,  "http://120.31.149.194:180" + suite_url))
                wfp.write("{\"data\": \"%s\", \"color\": \"%s\", \"link\": \"%s\"}, " %
                  (repr(suite_fail), FAIL_COLOR,  "http://120.31.149.194:180" + suite_url))
                wfp.write("{\"data\": \"%s\", \"color\": \"%s\"}" %
                  (repr(suite_total - suite_success - suite_fail), BLOCK_COLOR))
                if suite_count == 1:
                   wfp.write("]\n")
                else:
                   wfp.write("],\n")
                print wfp
                        

    print "--------------now end get testjob result --------------------------"
	
def generate_email_locate_report():
    print "--------------now begin get testjob: result ------------------------------"

    suite_list = []  #all test suite list
    linestrlist = []
    linelist = []
    locate_list = {}
    case_dict = {}  #testcast dict value like 'smoke-test':[test-case1,test-case2,test-case3]
    boot_total = 0
    boot_success = 0
    boot_fail = 0
    test_total = 0
    test_success = 0
    test_fail = 0
    suite_total = 0
    suite_success = 0
    suite_fail = 0
    suite_count = 0
    #get all the test suite list from get_testjob_results_yaml
    for job_id in job_result_dict.keys():
        print job_id
        for item in job_result_dict[job_id]:
            #print item
            if suite_list.count(item['suite']) == 0:
                suite_count += 1
                suite_list.append(item['suite'])

    #inital a no value dict
    for suite in suite_list:
        case_dict[suite] = []
    commit_id=''
    #set all the value in dict
    for job_id in job_result_dict.keys():
        for item in job_result_dict[job_id]:
            case_dict[item['suite']].append(item)
            if item['suite'] == "0_Begin-test":
               commit_id = item['unit']
    #try to write summary file
    summary_dir = os.getcwd()
    summary_file = os.path.join(summary_dir, LOCATE_SUMMARY_NAME)
    if os.path.exists(summary_file):
        os.remove(summary_file)
    
    for key in sorted(case_dict.keys()):
        if key == 'lava':
            for item in case_dict[key]:
                if item['result'] == 'pass':
                    boot_total += 1
                    boot_success += 1
                elif item['result'] == 'fail':
                    boot_total += 1
                    boot_fail += 1
                else:
                    boot_total += 1
        else:
            for item in case_dict[key]:
                if item['result'] == 'pass':
                    test_total += 1
                    test_success += 1
                elif item['result'] == 'fail':
                    test_total += 1
                    test_fail += 1
                else:
                    test_total += 1

    with open("/home/luojiaxing/%s/result.txt"%job_id, 'r') as resultf:
        for line in resultf.readlines():
            #linestr = line.strip()
            linestrlist = line.split("#")
            linestrlist[0]=linestrlist[0].strip()
            print linestrlist
            #linelist=map(str,linestrlist)
            locate_list[linestrlist[0]]=linestrlist[1].strip("\n")
            print "New issue locate item with key %s , locate info is %s" %( linestrlist[0] , locate_list[linestrlist[0]] )
    #os.rmdir(r"/fileserver/plinth/%s"%job_id)
    with open(summary_file, 'w') as wfp:
        #cycle show the result of each test
        for key in sorted(case_dict.keys()):
            if key == 'lava':
                print "No add LAVA result at mial result txt!"
            else:
                suite_count -= 1
                suite_total = 0
                suite_success = 0
                suite_fail = 0
                for testsuite in case_dict[key]:
                    #get the result count in each testsuit
                    if testsuite['result'] == 'pass':
                       suite_total += 1
                       suite_success += 1
                    elif testsuite['result'] == 'fail':
                       suite_total += 1
                       suite_fail += 1
                    else:
                       suite_total += 1
                    if testsuite['suite'] == "0_Begin-test":
                       maintainer="Luojiaxing"
                    else:
                       maintainer=testsuite['unit']
                    
                
                    #get the url of test suite
                    str=testsuite['url'].split('/')
                    print str
                    str.pop(-1)
                    print str
                    suite_url='/'.join(str)
                    str.pop(-1)
                    result_url='/'.join(str)
                    print result_url
                     
                    for locate_key in sorted(locate_list.keys()):
                       if testsuite['name'] == locate_key:
                           wfp.write("[\"%s\", " % key)
                           wfp.write("\"%s\", " % testsuite['name'])
                           wfp.write("\"%s\", " % maintainer)
                           wfp.write("{\"data\": \"%s\", \"color\": \"%s\", \"link\": \"%s\"}, " %
                                (locate_list[testsuite['name']] , FAIL_COLOR,"http://120.31.149.194:180" + result_url))
                           #wfp.write("\"%s\", " % locate_list[testsuite['name']])
                           wfp.write("],\n")
                           print wfp
    if os.path.getsize(summary_file) == 0:
        with open(summary_file, 'w') as wfp:
               wfp.write("[\"%s\", " % "None")
               wfp.write("\"%s\", " % "None")
               wfp.write("\"%s\", " % "None")
               wfp.write("\"%s\", " % "None")
               wfp.write("],\n")
               print wfp
    print "--------------now end get testjob issue locate --------------------------"
