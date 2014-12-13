#command-line arguments:
# -c <configfile>   optional; the config file to use; default config.yml in pipelinedir
# -s <stepname>     optional; the step to start with; default first in sequence
# -a                optional; run the requested step alone (default is to run requested step and all subsequent steps to completion)
# -i <input_dir>    required. the directory in which to look for input
# -o <output_dir>   required. the directory for output

#treat any extra/unknown arguments as potentially needed by steps

import sys, os
import argparse

def getConfigFileName():
    parser = argparse.ArgumentParser()
    parser.add_argument('-c', default='config.yml', 
                        help='optional; the config file to use; default config.yml in pipelinedir')
    args, unknown = parser.parse_known_args()
    return args.c;

def parseArgs(steps):
    runInfo = parseDefaultArgs(steps)
    parseStepArgsAndSetEnvVars(steps)
    return runInfo


def parseDefaultArgs(steps):
    parser = argparse.ArgumentParser()
    
    parser.add_argument("-step", "-s", default = str(steps[0]['name']), help='optional; the step to start with; default first in sequence')
    parser.add_argument("-alone", "-a", action='store_true', help='optional; run the requested step alone (default is to run requested step and all subsequent steps to completion)')
    parser.add_argument("-in_dir", "-i", help='required; the absolute path in which to look for input', required = True)
    parser.add_argument("-out_dir", "-o", help='required; the absolute path for output', required = True)

    runInfo, unknown = parser.parse_known_args()
    #os.environ['_START'] = str(runInfo.step)
    #os.environ['_ALONE'] = str(runInfo.alone)
    os.environ['_IN_DIR'] = str(runInfo.in_dir)
    os.environ['_OUT_DIR'] = str(runInfo.out_dir)
    return runInfo


def parseStepArgsAndSetEnvVars(steps):
    #parse config file to add arguments
    #TODO: interactive UI for undefined args. Until then, fail hard 
    parser = argparse.ArgumentParser()
    for step in steps:
        if step['args']:
            for argname in step['args']:
                if str(step['args'][argname]) == "None":
                    parser.add_argument('--{0}'.format(argname), required = True)
                else:
                    parser.add_argument('--{0}'.format(argname), default = str(step['args'][argname]))
                
    #parse argument, set environment var 
    step_args, unknown = parser.parse_known_args()

    #set environment variables according to the provided args 
    for step in steps:
        if step['args']:
            for argname in step['args']:
                os.environ[argname] = str(getattr(step_args, argname))




