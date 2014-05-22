This read me helps in running the buzz, beep validation. There are a few prerequisites that need to be fulfilled before one can run these tests. These are listed below:
1. You need to have the following files with you before you run the validation:
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

Please make sure that you have all these files in a single folder. This makes it easier for you to select them through the GUI.

After you have these files store somewhere, you can simply run the 'runMe.m' with only one argument i.e. the frequency of sampling the audio (which in our case is 16000Hz). Further descriptions of how the functions work are embedded in the description of the files. Please make use of the 'help' command in the MATLAB terminal.

Usage
[BuzzBeepLocations, variousMeasurements, locationsChecked] = runMe(16000);

