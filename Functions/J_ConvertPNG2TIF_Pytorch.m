% Convert the processed files from the GAN to a stack for fiji
myfiledir = 'C:\Users\diederichbenedict\Dropbox\Dokumente\Promotion\PROJECTS\STORM\MATLAB\LINES\';
actual_filedir = 'MOV_2018_02_07_10_42_44_ISO12800_texp1_85_lines_combined_processed';
pix2pix_filedir = '\images\';

filedir = [myfiledir actual_filedir pix2pix_filedir];


% READ the processed data
srcFiles = dir([filedir '*fake_B.png']);  % the folder in which ur images exists
iframe = {};
for i = 1 : length(srcFiles)
    filename = strcat(filedir,srcFiles(i).name);
    iframe{i}  = imread(filename);
end

iframes = cat(3, iframe{:});
writeim(iframes, [actual_filedir '_processed.tif'], 'TIFF')


%% Read the orignial data
srcFiles = dir([filedir '*real_A.png']);  % the folder in which ur images exists
iframe = {};
for i = 1 : length(srcFiles)
    filename = strcat(filedir,srcFiles(i).name);
    iframe{i}  = imread(filename);
end

iframes = cat(3, iframe{:});
writeim(iframes, [actual_filedir '_unprocessed.tif'], 'TIFF')


if(1)
    %% Read the orignial data
    srcFiles = dir([filedir '*real_B.png']);  % the folder in which ur images exists
    iframe = {};
    for i = 1 : length(srcFiles)
        filename = strcat(filedir,srcFiles(i).name);
        iframe{i}  = imread(filename);
    end
    
    iframes = cat(3, iframe{:});
    writeim(iframes, [actual_filedir '_raw.tif'], 'TIFF')
end

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