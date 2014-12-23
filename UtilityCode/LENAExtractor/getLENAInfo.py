__author__ = 'hasanshabih'

import elementtree.ElementTree as et;

def getInfo(trsFilePath, startTime, endTime):
    xml_data = et.parse(trsFilePath);
    turnLocations = xml_data.findall('.//Turn');
    tupleVals = [];
    toWrite = '';
    for i in turnLocations:
        stTime = float(i.attrib["startTime"]);
        edTime = float(i.attrib["endTime"]);
        spInfo = i.attrib["speaker"];
        if stTime >= startTime and edTime <= endTime:
            tupleVals.append((spInfo,stTime,edTime));
            toWrite+=spInfo+','+str(stTime)+','+str(edTime)+'\n';
    return tupleVals, toWrite;