% Convert the processed files from the GAN to a stack for fiji
filedir = '/media/useradmin/Data/Benedict/Dropbox/Dokumente/Promotion/PROJECTS/STORM/MATLAB/DataFromOriginalVideo/1_Artificial_dataset_GT_VIDEO_GENERATED_ISO3200'
filedir_mod = [filedir '_demosaic'];
filedir = [filedir '/train/'];


if (~exist(filedir_mod, 'dir')); mkdir(filedir_mod ); end%if

% READ the processed data
srcFiles = dir([filedir '*.png']);  % the folder in which ur images exists



for i = 1 : length(srcFiles)
    
    %%
    
    filename = strcat(filedir,srcFiles(i).name);
    
    % read frame and register it (parameters measured only once!)
    iframe  = imread(filename);
    iframe_a = iframe(:,1:256);
    iframe_b = iframe(:,257:end);

    % align the frame and save it
    iframe = horzcat(iframe_a, iframe_b);
    filename_mod = strcat((filedir_mod), srcFiles(i).name);
    
    imwrite(uint8(iframe), filename_mod);
    
    disp([num2str(i) ' / ' num2str(length(srcFiles))])
    
end
