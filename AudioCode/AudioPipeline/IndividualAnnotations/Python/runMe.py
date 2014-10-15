import sys;
import extractAudio as eA;
import combineAnnotationsAudio as cAA;

fList = cAA.combineAA(sys.argv[1],sys.argv[2]);
for fL in fList:
	eA.extractAudio(fL[0],fL[1],sys.argv[3]);