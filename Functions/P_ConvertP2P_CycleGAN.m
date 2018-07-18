% Convert the processed files from the GAN to a stack for fiji
filedir = '/home/useradmin/Dropbox/Dokumente/Promotion/PROJECTS/STORM/DATASET_NN/01_CELLPHONE_GT_PAIRS/1000Emitters_focus17_2_ISO3200_Polarizer_AtoB_randShift/hwgt_batch_test/';

fieldir_dest = '/home/useradmin/Dropbox/Dokumente/Promotion/PROJECTS/STORM/DATASET_NN/01_CELLPHONE_GT_PAIRS/1000Emitters_focus17_2_ISO3200_Polarizer_AtoB_randShift/cycleGAN/';
filedir_dirA = 'testA/';
filedir_dirB = 'testB/';

filedir_dirA = [fieldir_dest filedir_dirA];
filedir_dirB = [fieldir_dest filedir_dirB];

if (~exist(filedir_dirA, 'dir')); mkdir(filedir_dirA ); end%if
if (~exist(filedir_dirB, 'dir')); mkdir(filedir_dirB ); end%if


% read all frames which have been processed for the pix2pix network already
% cycleGAN requiers to have two seperated folders for training
srcFiles = dir([filedir '*.png']);  % the folder in which ur images exists
iframe = {};
for i = 1 : length(srcFiles)
    filename = strcat(filedir,srcFiles(i).name);
    iframe = imread(filename);
    fileA = iframe(:, 1:256);
    fileB = iframe(:, 257:end);
    
    imwrite(fileA, [filedir_dirA srcFiles(i).name]);
    imwrite(fileB, [filedir_dirB srcFiles(i).name]);
end
