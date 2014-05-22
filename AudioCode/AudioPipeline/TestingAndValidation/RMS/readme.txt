To run the RMS threshold calculation, the user needs to only run the 'runME.m' file with arguments being frame size in seconds, frequency, and the percentile value (1-100) the you want to know. Once you run this, you would need to find some files to calculate the threshold on. During initial calculations, we used :
patient-EMA01.1.33.2013-05-21 16-09-50.audio
patient-EMA01.1.35.2013-05-21 17-12-53.audio
patient-EMA01.1.93.2013-05-23 18-19-41.audio
patient-EMA04.2.108.2013-05-13 18-00-19.audio
patient-EMA04.2.56.2013-05-11 12-06-00.audio
patient-EMA04.2.74.2013-05-12 09-09-45.audio
patient-EMA04.5.115.2013-03-24 16-33-21.audio
patient-EMA07.3.102.2013-10-06 21-10-11.audio
patient-EMA07.3.45.2013-10-03 12-14-02.audio
patient-EMA08.1.10.2013-10-09 17-13-04.audio
patient-EMA08.4.27.2013-08-19 17-12-32.audio
patient-EMA11.6.2.2013-08-09 12-50-55.audio
patient-EMA11.6.70.2013-08-14 14-34-56.audio
patient-EMA13.1.87.2013-11-11 07-48-58.audio
patient-EMA13.1.91.2013-11-11 14-22-52.audio
patient-EMA16.5.13.2013-09-27 09-45-12.audio
patient-EMA18.2.25.2013-11-23 16-37-13.audio
patient-ema01.2.28.2013-04-13 16-40-50.audio
patient-ema01.2.50.2013-04-14 14-16-59.audio
patient-ema01.2.64.2013-04-15 12-05-35.audio

Please make sure that all the files are in a single folder so that you can select them all.

Usage example
[LowEnergyFrames, cumulativeLowEnergyFrames] = runMe(0.02, 16000, 20);


