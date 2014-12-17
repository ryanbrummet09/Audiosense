import sys;
import os;
import fnmatch;
import re;
import extractAudioFromLENA as extA;

def getSurveyFileDetails(filename):
	return re.findall('\d+',filename);

def getFileList(filePath, fileType):
	fileList = [];
	for root,dirs, files in os.walk(filePath):
		for filename in fnmatch.filter(files,'*.'+fileType):
			fileList.append(os.path.join(root,filename));
	return fileList;

def main():
	# get the list of all the files
	surveyFolder = sys.argv[1];
	transcriberFolder = sys.argv[2];
	lenaFileFolder = sys.argv[3];
	surveyFileList = getFileList(surveyFolder,'survey');
	transcriberFileList = getFileList(transcriberFolder,'trs');
	lenaFileList = getFileList(lenaFileFolder,'wav');
	# get the patient details, then corresponding trs and wav files
	for surveyFile in surveyFileList:
		surveyDeets = getSurveyFileDetails(surveyFile.split('/')[-1]);
		pid = surveyDeets[0];
		if 1 == len(pid):
			pid = '0'+pid;
		cid = surveyDeets[1];
		if 1 == len(cid):
			cid = '0'+cid;
		sid = surveyDeets[2];
		yr = surveyDeets[3];
		yr = yr[2:];
		mnth = surveyDeets[4];
		day = surveyDeets[5];
		fnameTemplate = pid+'_'+cid+'_'+mnth+day+yr;
		correspondingTrsFile = [x for x in transcriberFileList if fnameTemplate in x.split('/')[-1]];
		correspondingLENAFile = [x for x in lenaFileList if fnameTemplate in x.split('/')[-1]];
		if 1 != len(correspondingLENAFile) or 1 != len(correspondingTrsFile):
			print 'the number of corresponding lena and transcriber files is not 1 for survey file '+ surveyFile.split('/')[-1]+', skipping';
			print correspondingTrsFile;
			print correspondingLENAFile;
			print fnameTemplate;
			continue;
		print 'Working with '+surveyFile.split('/')[-1];
		extA.extractAudio(correspondingLENAFile[0], surveyFile, correspondingTrsFile[0]);
		print 'data extracted and saved';
if __name__ == "__main__":
	main();
