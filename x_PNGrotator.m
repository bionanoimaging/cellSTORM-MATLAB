% Convert the processed files from the GAN to a stack for fiji
filedir = '/Users/bene/Downloads/test/'
filedir_mod = '/Users/bene/Downloads/Rot/test/'
if (~exist(filedir_mod, 'dir')); mkdir(filedir_mod ); end%if

% READ the processed data
srcFiles = dir([filedir '*.png']);  % the folder in which ur images exists


%%
imse = {}
ipsnr = {}
ifilename = {};
iter = 1;

% find shift of the dataset and register
filename = strcat(filedir,srcFiles(i).name);
iframe  = imread(filename);
iframe_a = dip_image(iframe(1:256,:));
iframe_b = dip_image(iframe(257:end,:));

xyshift = findshift(iframe_a, iframe_b, 'ffts');
iframe_a_shift = affine_trans(iframe_a, 1, xyshift', 0);
%dip_image(cat(3, iframe_a_shift, iframe_b))



for i = 1 : length(srcFiles)
    
    %%
    
    filename = strcat(filedir,srcFiles(i).name);
    
    % read frame and register it (parameters measured only once!)
    iframe  = imread(filename);
    iframe_a = dip_image(iframe(1:256,:));
    iframe_a = affine_trans(iframe_a, 1, xyshift', 0);
    
    iframe_b = dip_image(iframe(257:end,:));

    % align the frame and save it
    iframe = horzcat(iframe_a, iframe_b);
    filename_mod = strcat((filedir_mod), srcFiles(i).name);
    
    imwrite(uint8(iframe), filename_mod);
    
    disp([num2str(i) ' / ' num2str(length(srcFiles))])
    
end
