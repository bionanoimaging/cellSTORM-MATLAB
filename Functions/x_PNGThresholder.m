% Convert the processed files from the GAN to a stack for fiji
filedir = './testSTORM_random_psf_v5/'
filedir_mod = './testSTORM_random_gt_v5/'
if (~exist(filedir_mod, 'dir')); mkdir(filedir_mod ); end%if

% READ the processed data
srcFiles = dir([filedir '*.png']);  % the folder in which ur images exists


%%


for i = 1 : length(srcFiles)
    
    %%
    
    filename = strcat(filedir,srcFiles(i).name);
    
    % read frame and register it (parameters measured only once!)
    iframe  = imread(filename);
    iframe = iframe.*maxima(iframe,1,1);
    
    filename_mod = strcat((filedir_mod), srcFiles(i).name);
    
    imwrite(uint8(iframe), filename_mod);
    
    disp([num2str(i) ' / ' num2str(length(srcFiles))])
    
end
