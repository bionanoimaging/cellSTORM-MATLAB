% specify the folder where the GT PNGs are stored 
addpath(genpath('./util'))

% specify the video file with the recorded GT events
% read cellSTORM images MAC
myfilepath = './LINES/';
myfile_HUAWEI = 'MOV_2018_03_12_14_07_02_ISO6400_texp_1_400_ArtificialMicrotubes_Checkerboard.mp4'; % needs 0 rotation
myfile_HUAWEI = [myfilepath myfile_HUAWEI];

% Read frames from HUAWEI video
AllFrames_HW = ReadVideoFrameSave256Crop(myfile_HUAWEI, 100000, 0); 
