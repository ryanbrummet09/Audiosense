import fnmatch;
import os;

def fileList(toLookIn, fileType):
	fileList = [];
	for root,dirs, files in os.walk(toLookIn):
		for filename in fnmatch.filter(files,'*.'+fileType):
			 fileList.append(os.path.join(root,filename));
	return fileList;