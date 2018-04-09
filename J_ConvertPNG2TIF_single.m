% Convert the processed files from the GAN to a stack for fiji
filedir = '/Users/bene/Dropbox/Dokumente/Promotion/PROJECTS/STORM/MATLAB/LINES/testSTORM_lines_256_256_barcode/'
% READ the processed data
srcFiles = dir([filedir '*.png']);  % the folder in which ur images exists
iframe = {};
for i = 1 : length(srcFiles)
    filename = strcat(filedir,srcFiles(i).name);
    iframe{i}  = imread(filename);
end

iframes = cat(3, iframe{:});
writeim(iframes, 'testSTORM_lines_256_256_barcode.tif', 'TIFF')


%% Read the orignial data
srcFiles = dir([filedir '*inputs.png']);  % the folder in which ur images exists
iframe = {};
for i = 1 : length(srcFiles)
    filename = strcat(filedir,srcFiles(i).name);
    iframe{i}  = imread(filename);
end

iframes = cat(3, iframe{:});
writeim(iframes, '2018-02-01_17.36.34_ISO_3200_texp_1_10_andorsync_2_unprocessed.tif', 'TIFF')

%%
if(0)
    
    filedir = '/media/useradmin/Data/Benedict/Dropbox/Dokumente/Promotion/PROJECTS/STORM/MATLAB/HW_testSTORM_FIJI_EXPERIMENT/'

    %% Read the orignial data
srcFiles = dir([filedir '*.png']);  % the folder in which ur images exists
iframe = {};
for i = 1 : length(srcFiles)
    filename = strcat(filedir,srcFiles(i).name);
    iframe{i}  = imread(filename);
end

iframes = cat(3, iframe{:});
writeim(iframes, [filedir 'result_1.tif'], 'TIFF')
writeim(iframes, [filedir 'result_2.tif'], 'TIFF')

end