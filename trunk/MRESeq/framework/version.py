#!/usr/bin/python

# This is a simple program for tracking version numbers of pipelines. 
# It interacts with the file "changelog.csv". 
# Version 1.0 last updated by hbabaran on Oct 22 2014.

import sys, getopt, csv, datetime

logfile = open('changelog.csv', 'a+')
logfile.seek(0)
changelog = list(csv.reader(logfile))

def usage():
   print("usage: python version.py <command> [args]")
   print("Command:\tArgs:\t\tUse:")
   print("get-version\t\t\tdisplays version number")
   print("get-date\t\t\tdisplays current date")
   print("print-log\t<num_entries>\tprints the <num_entries> most recent entries in the changelog. 0 < num_entries < 100; default 3")
   print("inc-small\t\"<message>\"\trecord a small update in the changelog")
   print("inc-medium\t\"<message>\"\trecord a medium update in the changelog")
   print("inc-large\t\"<message>\"\trecord a large update in the changelog")
   sys.exit(1)

#returns current version number parsed from last line of changelog.csv
def getversion():
   logLength = len(changelog)
   if(logLength != 0):
      return [int(x) for x in changelog[logLength-1][:3]]
   return [0,0,0]  
   

#version string formatter
def versiontostr(version):
   return  "{0}.{1}.{2}".format(version[0], version[1], version[2])

#gets date in string format 
def getdatestr():
   today = datetime.datetime.now()
   return "{0}-{1}-{2}".format(today.year, today.month, today.day)

#pretty prints the last <entries> lines of changelog.csv; default 3 
def printlog(entries = 3):
   entries = int(entries)
   logLength = len(changelog)
   
   if(logLength == 0):
      print("No recorded entries in the changelog.")
   else:
      if(entries > logLength):
         print "Only", logLength, "entries available."
         entries = logLength
      for entry in changelog[(logLength - entries):]:
         print "{3} v{0}.{1}.{2}: {4}".format(entry[0], entry[1], entry[2], entry[3], entry[4])


#returns current version number, incremented small medium or large
def incsmall():
   version = getversion()
   version[2] += 1;
   return version

def incmedium():
   version = getversion()
   version[1] += 1;
   version[2] = 0;
   return version

def inclarge():
   version = getversion()
   version[0] += 1;
   version[1] = 0;
   version[2] = 0;
   return version

#modifies changelog to update with new version number and message
#truncates the logfile at 99 lines
def updatelog(version, message):
   changelog.append([version[0],version[1],version[2],getdatestr(),message])
   csv.writer(logfile).writerow(changelog[len(changelog) - 1])


def main(argv):
   if len(sys.argv) < 2:
      usage()
   
   if sys.argv[1] == "get-version":
      print "Current version is", versiontostr(getversion())
   elif sys.argv[1] == "get-date":
      print "Today is", getdatestr()
   elif sys.argv[1] == "print-log":
      if len(sys.argv) < 3:
         printlog()
      else:
         printlog(sys.argv[2])
   elif sys.argv[1] == "inc-small" and len(sys.argv) == 3:
      updatelog(incsmall(), sys.argv[2])
   elif sys.argv[1] == "inc-medium" and len(sys.argv) == 3:
      updatelog(incmedium(), sys.argv[2])
   elif sys.argv[1] == "inc-large" and len(sys.argv) == 3:
      updatelog(inclarge(), sys.argv[2])
   else:
      usage()

if __name__ == "__main__":
   main(sys.argv)


