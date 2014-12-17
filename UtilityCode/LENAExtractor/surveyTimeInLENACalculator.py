'''
@author: syedshabihhasan
There are three inputs:
	surveyFilePath 		: path to the survey file
	trsFilePath		: path to the transcriber file
	secondsToLookBack	: the number of seconds before the start of the survey to extract

There are two outputs in the form of a tuple:
	(the start time for extraction of the audio, the end time for the extraction if the survey)
Usage:
	time_tuple = getStartTimeLENA('dummyPath/surveyFile.survey','dummyPath2/trsFile.trs',250);
	or
	time_tuple = getStartTimeLENA('dummyPath/surveyFile.survey','dummyPath2/trsFile.trs');
'''
import datetime as dt;
import sys;
import elementtree.ElementTree as et;
import pytz;

def getStartTimeLENA(surveyFilePath, trsFilePath, secondsToLookBack = 300):
	# lets open the survey file and extract the survey start time
	f = open(surveyFilePath,'r');
	survey_data = f.read();
	f.close();
	survey_data = survey_data.split('\r');
	survey_data.remove('');
	for survey_tag in survey_data:
		if 'start-time' in survey_tag:
			local_dt = dt.datetime.strptime(survey_tag.split('=')[1],'%Y-%m-%d %H:%M:%S');
		elif 'end-time' in survey_tag:
			local_dt_end = dt.datetime.strptime(survey_tag.split('=')[1],'%Y-%m-%d %H:%M:%S');
	xml_data = et.parse(trsFilePath);
	lenaStartTimeTagLocation = xml_data.find('.//Background');
	lenaStartTimeTagData = lenaStartTimeTagLocation.attrib["type"];
	lenaStartTimeTagData = lenaStartTimeTagData.split(' ');
	lenaStartTimeString = lenaStartTimeTagData[4]+' '+lenaStartTimeTagData[7];
	lenaStartTime = dt.datetime.strptime(lenaStartTimeString,'%Y-%m-%d %H:%M:%S');
	lenaStartTime = pytz.timezone('Etc/GMT').localize(lenaStartTime);
	# lets start the time difference calculation
	local_tz = pytz.timezone('America/Chicago');
	# convert local time to the right state
	local_dt = local_tz.localize(local_dt,is_dst=True);
	local_dt_end = local_tz.localize(local_dt_end,is_dst=True);
	utc_dt = local_dt.astimezone(pytz.utc);
	utc_dt_end = local_dt_end.astimezone(pytz.utc);
	surveyEndsAt = utc_dt_end - utc_dt;
	lenaSurveyTime = utc_dt - lenaStartTime;
	lenaSurveyEndTime = lenaSurveyTime + surveyEndsAt + dt.timedelta(seconds = secondsToLookBack);
	lenaToLookTime = lenaSurveyTime - dt.timedelta(seconds = secondsToLookBack);
	print 'Survey Start Local:'+local_dt.strftime('%H:%M:%S %Y-%m-%d');
	print 'Survey Start GMT:'+ utc_dt.strftime('%H:%M:%S %Y-%m-%d');
	print 'Survey End Local:'+local_dt_end.strftime('%H:%M:%S %Y-%m-%d');
	print 'Survey End GMT:'+utc_dt_end.strftime('%H:%M:%S %Y-%m-%d');
	print 'LENA Start GMT:'+lenaStartTime.strftime('%H:%M:%S %Y-%m-%d');
	print str(secondsToLookBack)+'s before the survey starts at: '+str(lenaToLookTime.total_seconds()) + 's into the LENA data';
	print 'LENA End GMT:'+str(lenaSurveyEndTime.total_seconds());
	return lenaToLookTime.total_seconds(),lenaSurveyEndTime.total_seconds();

if __name__ == "__main__":
	if 4 <= len(sys.argv):
		startAt, endAt= getStartTimeLENA(sys.argv[1],sys.argv[2],int(sys.argv[3]));
	elif 3 == len(sys.argv):
		startAt, endAt= getStartTimeLENA(sys.argv[1],sys.argv[2]);
	else:
		print "Too few arguments";
