import subprocess, os

def run(steps, runInfo):
	if runInfo.alone:
		success = runStep(runInfo.step, steps)
		return success
	else:
		steps = steps[getStepIndexByName(runInfo.step, steps):]
		for step in steps:
			success = runStep(step["name"], steps)
			if not success:
				return success
		return success


def getStepLocByName(stepname, steps):
	for step in steps:
		if step["name"] == stepname:
			return '{0}/{1}'.format(os.getcwd(), step["script"])
	return False

def getStepIndexByName(stepname, steps):
	for i in range(len(steps)):
		if steps[i]["name"] == stepname:
			return i
	return -1


def runStep(stepName, steps):
	print
	print "Beginning execution of step: {0}".format(stepName)
	print "--------------------------------------------------"
	step_path = getStepLocByName(stepName, steps)
	if not step_path:
		print ('A problem occurred while parsing information for step {0}. '
				'Check to ensure that the -s argument is correct and config.yml is well-formed.'
				.format(stepName) )
		return False
	if not (os.path.isfile(step_path) and os.access(step_path, os.X_OK)):
		print 'While executing step {0}:'.format(stepName)
		print 'Could not find or open executable at path: {0}'.format(step_path)
		print 'Check to make sure that it exists and is executable.'
		return False

 	success = subprocess.call(step_path)

	if success != 0:
		print ('Step {0} did not complete successfully.'
				' No subsequent steps will be executed.'
				.format(stepName))
		return False
	print "Step {0} completed successfully.".format(stepName)
	return True
