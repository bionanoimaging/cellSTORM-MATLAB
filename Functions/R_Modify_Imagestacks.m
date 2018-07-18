% specify the folder where the A to B paris are placed
filedir_dest = './MOV_2018_02_15_16_29_08_ISO12800_texp_1_600_lines_combined/test/';

%% Find matching test cases in the two directories]
dir_dest = dir(fullfile(filedir_dest, '*.png')); dir_dest={dir_dest.name}; %


%% Data reading
nfiles = length(dir_hw);
for i = 1:nfiles
    % read in the image-pairs
    img_dest = flip(imread([filedir_dest dir_dest{i}]));
    imwrite(img_dest, [filedir_dest dir_dest{i}]);
    
end

    

fname = 'my_file_with_lots_of_images.tif';
info = imfinfo(fname);
num_images = numel(info);
for k = 1:num_images
    A = imread(fname, k, 'Info', info);
    % ... Do something with image A ...
end