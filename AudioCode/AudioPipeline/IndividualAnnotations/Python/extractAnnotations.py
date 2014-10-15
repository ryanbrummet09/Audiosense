def extractAnnotations(annotationFile):
	f = open(annotationFile,'r');
	data = f.read();
	f.close();
	data = data.split('\r');
	data.remove('');
	indvAnnotations = {};
	for i in data:
		i = i.split('\t');
		tag = i[2];
		startTime = float(i[0]);
		endTime = float(i[1]);
		if tag in indvAnnotations:
			temp = indvAnnotations[tag];
			temp.append((startTime,endTime));
		else:
			temp = [(startTime,endTime)];
		indvAnnotations[tag] = temp;
	return indvAnnotations;