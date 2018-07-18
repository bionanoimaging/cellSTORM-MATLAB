% read cellSTORM images MAC
myfilepath = './LINES/';

myfile_gt = 'testSTORM_random_gt.mp4';
myfile_HUAWEI = 'MOV_2018_03_06_11_43_47_randomBlink2500_lines_ISO6400_texp_1_125.mp4'; % needs 0 rotation


myfile_gt = [myfilepath myfile_gt];
myfile_HUAWEI = [myfilepath myfile_HUAWEI];



% Read frames from HUAWEI video
AllFrames_HW = ReadVideoFrameSave256(myfile_HUAWEI, 100000, 0); 

return
AllFrames_GT = ReadVideoFrameSave256(myfile_gt, 100000, 0); 
% Read frames from GT video
AllFrames_GT = ReadVideoFrameSaveGroundTruth(myfile_gt, 10000, 0); 
