clear all

beep_files = containers.Map();
buzz_files = containers.Map();

beep_files('patient-EMA01.1.33.2013-05-21 16-09-50') = [1.7, 2.2, 2.55, 4.6,5, 5.8, 6.55, 6.95, 7.58, 9.64, 10.2, 11.3, 11.6, 13.8, 25.55, 27.0, 28.52, 29.9, 30.7, 33.05, 36.2];
beep_files('patient-EMA08.4.27.2013-08-19 17-12-32') = [];
beep_files('patient-EMA11.6.2.2013-08-09 12-50-55') = [];
buzz_files('patient-EMA01.1.33.2013-05-21 16-09-50') = [1.7, 2.55, 4.45, 5.0, 5.8, 7.48, 9.48, 10.2, 11.3, 12.45];

save('test_files', 'beep_files', 'buzz_files')