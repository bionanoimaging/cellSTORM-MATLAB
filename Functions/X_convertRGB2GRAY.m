

% Convert the processed files from the GAN to a stack for fiji
filedir = '/home/useradmin/Dropbox/Dokumente/Promotion/PROJECTS/STORM/MATLAB/LINES/MOV_2018_02_07_10_42_44_ISO12800_texp1_85_lines_combined/'
% READ the processed data
srcFiles = dir([filedir '*.png']);  % the folder in which ur images exists
iframe = {};
for i = 1 : length(srcFiles)
    try
    filename = strcat(filedir,srcFiles(i).name);
    iframe = imread(filename);
    imwrite(rgb2gray(iframe), filename);
    catch
        disp(i)
    end
end
