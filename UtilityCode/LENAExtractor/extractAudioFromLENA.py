'''
@autor syedshabihhasan
There are four inputs:
	wavFilePath			:		Paths to the LENA wav file
	surveyFilePath		: 		Path to the survey file
	trsFilePath 		: 		Path to the transcriber file
	secondsToLookBack 	: 		number of seconds to look before the start of the survey
	
	example:
			extractAudio('test/path/abc.wav','test/path1/surveyFile.survey','test/path2/trsFile.trs',400);
			or
			extractAudio('test/path/abc.wav','test/path1/surveyFile.survey','test/path2/trsFile.trs');
'''
import surveyTimeInLENACalculator as tc;
import sys;
import wave as wv;
import os;

def getFileDetails(surveyFilePath):
	actualSurveyFName = surveyFilePath.split('/')[-1];
	patientID = actualSurveyFName.split('.')[0].split('-')[1];
	conditionID = actualSurveyFName.split('.')[1];
	sessionID = actualSurveyFName.split('.')[2];
	return patientID, conditionID, sessionID;

def extractAudio(wavFilePath, surveyFilePath, trsFilePath, secondsToLookBack=300):
	endsOfChunk = tc.getStartTimeLENA(surveyFilePath, trsFilePath, secondsToLookBack);
	Fs = 16000; # sampling frequency of 16000 Hz
	totalNumberOfSamples = (endsOfChunk[1] - endsOfChunk[0])*Fs;
	sampleToStartAt = endsOfChunk[0]*16000;
	patientDetails = getFileDetails(surveyFilePath);
	waveObject = wv.open(wavFilePath,'rb');
	waveParams = waveObject.getparams();
	newWaveParams = [];
	for i in range(len(waveParams)):
		if 3 == i:
			newWaveParams.append(totalNumberOfSamples);
		else:
			newWaveParams.append(waveParams[i]);
	newWaveParams = tuple(newWaveParams);
	#waveParams[3] = totalNumberOfSamples;
	if int(sampleToStartAt) > int(waveParams[3]):
		print 'LENA does not cover the survey for:'+patientDetails[0]+','+patientDetails[1]+','+patientDetails[2];
		return 0;
	elif int(sampleToStartAt)< 0:
		sampleToStartAt = 0;
	#print '\033[94m total:'+str(waveParams[3])+', starting at:'+str(sampleToStartAt)+'\033[93m';
	waveObject.setpos(int(sampleToStartAt));
	toWrite = waveObject.readframes(int(totalNumberOfSamples));
	waveObject.close();
	if not os.path.isdir('Chunks'):
		os.mkdir('Chunks');
	waveObject = wv.open('Chunks/'+patientDetails[0]+'_'+patientDetails[1]+'_'+patientDetails[2]+'.wav','wb');
	waveObject.setparams(newWaveParams);
	waveObject.writeframes(toWrite);
	waveObject.close();
	return 1;
if __name__ == "__main__":
	extractAudio(sys.argv[1],sys.argv[2],sys.argv[3],int(sys.argv[4]));
