#!/usr/bin/env python

#------------------------------------------------------------------------------
import os, sys, string
# from sys import stdout, stderr
# from mx import DateTime
# import utils.cvt as cvt

#------------------------------------------------------------------------------

class $root(object):
    def __init__(self):
        self.symbol = ""
    def __cmp__(x, y):
        return cmp(x.symbol, y.symbol)
    def __str__(self):
        return "%5s" % ( self.symbol)

#------------------------------------------------------------------------------
#
# main function
#
def usage():
    print "-f filename"
    print "-s startDate"
    print "-e endDate"
    print "-h this help"

def main():
    import getopt, sys
    try:
        opts, args = getopt.getopt(sys.argv[1:], "hf:s:e:", ["help", "file=", "startDate=", "endDate="])
    except getopt.GetoptError:
        # print help information and exit:
        usage()
        sys.exit(2)
    filename = "SmallPortEval-1.txt"
    startDate=""
    endDate=""
    for o, a in opts:
        if o in ("-h", "--help"):
            usage()
            sys.exit()
        if o in ("-f", "--file"):
            filename = a
        if o in ("-s", "--startDate"):
            endDate = a
        if o in ("-e", "--endDate"):
            endDate = a

#------------------------------------------------------------------------------

if __name__== '__main__':
    main()

#------------------------------------------------------------------------------
