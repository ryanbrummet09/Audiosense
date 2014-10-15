import fileList as fL;
import sys;

def combineAA(audioPath, annotationPath):
	audioFiles = fL.fileList(audioPath,'audio');
	annotationFiles = fL.fileList(annotationPath,'txt');
	combinedList = [];
	for audioFile in audioFiles:
		print 'For audio file :'+audioFile;
		toCompare = audioFile.split('/')[-1].split('.')[0];
		toCompare+='.txt';
		annotationFile = [x for x in annotationFiles if toCompare in x];
		if 1 == len(annotationFile):
			print 'Found annotation:'+annotationFile[0];
			combinedList.append((audioFile,annotationFile[0]));
		else:
			print 'len != 1,';
			print annotationFile;
	return combinedList;