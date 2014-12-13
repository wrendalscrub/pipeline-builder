import yaml
import os
from socket import gethostname

#if you go on scc/scinet and type "hostname", the hostname contains these strings
#unfortunately the exact hostnames change depending on individual nodes in the cluster 
#pipeline builder uses these strings to determine what environment variable paths to load
# !!! you will need to change these if/when either system changes their host naming conventions !!!

SCC_HOSTNAME_STR1 = "scc.camh.net" 	#the login node
SCC_HOSTNAME_STR2 = "node" 			#eg node21 
#TODO determine with djrotenberg if *all* qsub nodes start with "node"

SCINET_HOSTNAME_STR1 = "scinet" 	#the login node
SCINET_HOSTNAME_STR2 = "gpc" 		#any of the qsub systems on gpc
#TODO add HPSS etc for scinet


def getConfig(configfile):
	try:
		configfile = open(configfile, 'r')
		configList = yaml.load(configfile)
	except:
		return False, {}, {}

	setEnvironmentVars(configList)
	
	return True, configList[1:]


def setEnvironmentVars(configList):
	os.environ['_PIPELINE_NAME'] = str(configList[0]['pipeline_name'])
	os.environ['_PIPELINE_DIR'] = str(os.getcwd())

	if configList[0]['CONSTANTS']:
		for key in configList[0]['CONSTANTS']:
			os.environ[key] = str(configList[0]['CONSTANTS'][key])

	#register _SYS_TYPE as either "SCC", "SCINET" or "OTHER"
	sysStr = getSystemStr()
	os.environ["_SYS_TYPE"] = sysStr
	
	#register system-specific dependencies as specified in config parser
	system = sysStr + '_dependencies'
	if configList[0][system]:
		for key in configList[0][system]:
			os.environ[key] = str(configList[0][system][key])


def getSystemStr():
	#check SCC
	if (gethostname().count(SCC_HOSTNAME_STR1) > 0 or 
		gethostname().count(SCC_HOSTNAME_STR2) > 0):
		return "SCC"
	#check SciNet
	if (gethostname().count(SCINET_HOSTNAME_STR1) > 0 or
		gethostname().count(SCINET_HOSTNAME_STR2) > 0):
		return "SCINET"
	#if neither return other
	return "OTHER"


