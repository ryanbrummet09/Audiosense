import numpy as np;
import extractAnnotations as eA;
import os;

def __getFileDetails(filename):
	return filename.split('/')[-1].split('.')[0];

def __checkLimits(valToCheck,minL=0, maxL=90):
	if valToCheck < minL:
		valToCheck = minL;
	if valToCheck > maxL:
		valToCheck = maxL;
	return int(valToCheck);

def extractAudio(audioFile, annotationFile, toStoreIn, samplingFrequency=16000):
	if not os.path.isdir(toStoreIn):
		os.mkdir(toStoreIn);
	annotations = eA.extractAnnotations(annotationFile);
	print annotations;
	tags = annotations.keys();
	f = open(audioFile,'rb');
	realFName = __getFileDetails(audioFile);
	print 'working with '+realFName;
	for tag in tags:
		print 'tag:'+tag;
		if '/' == toStoreIn[-1]:
			fname = toStoreIn+realFName+'_'+tag+'.audio';
		else:
			fname = toStoreIn+'/'+realFName+'_'+tag+'.audio';
		times = annotations[tag];
		tag_vals = '';
		for stEn in times:
			startTime = __checkLimits(np.ceil(stEn[0]));
			endTime = __checkLimits(np.ceil(stEn[1]));
			numberOfBytes = (endTime - startTime)*samplingFrequency*2;
			seekTo = startTime*16000*2;
			f.seek(int(seekTo));
			temp = f.read(int(numberOfBytes));
			tag_vals+=temp;
		print 'writing extracted chunk to '+fname;
		f_tag = open(fname,'wb');
		f_tag.write(tag_vals);
		f_tag.close();
		print 'done';
	f.close();			