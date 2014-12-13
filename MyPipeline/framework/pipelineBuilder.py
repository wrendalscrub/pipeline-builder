#!/usr/bin/python
#Created for Python 2.*


# 1. reads from a config script telling it:
	# $PIPELINE_DIR and name
	# a) all the steps
	# b) each step's corresponding sh script location
	# c) each step's dependencies and where to find them
	# d) each step's required arguments. 
# 2. provides an interface to the user allowing them to select which steps to run and provide the 
#	 necessary input. 2 modes: interactive command line, or just take arguments and go 
# 3. runs the requested steps, logging output for each step using standardized date/version number
# 4. stops the run at any point if a failure occurs and notifies the user (email?)

import sys
import argsParser
import configParser
import interactiveUI
import stepRunner
import os

def run():


	#get config file and read in information
	configfile = argsParser.getConfigFileName()
	success, steps = configParser.getConfig(configfile)
	if not success:
		print "Could not read configfile {0}.".format(configfile)
		print "Make sure it exists and is properly formatted."
		sys.exit(1)

	#read all the arguments provided; exit if incorrect args
	runInfo = argsParser.parseArgs(steps)

#	#if mandatory arguments are missing or incorrect, present interactive dialogue
#	if needInfo:
#		quit, steps, runInfo = interactiveUI.run(steps, runInfo)
#		if quit:
#			print "Exiting."
#			sys.exit(0)

	#part 4: run the requested steps; record output. Mark all log files with version and date. Catch 
	#any errors and exit gracefully 
	success = stepRunner.run(steps, runInfo)
	if success:
		print "Run of {0} completed successfully.".format(os.environ['_PIPELINE_NAME'])
	else:
		print ('Run of {0} did not complete successfully. '
		 	   'Check output logs for details.').format(os.environ['_PIPELINE_NAME'])
		sys.exit(1)




