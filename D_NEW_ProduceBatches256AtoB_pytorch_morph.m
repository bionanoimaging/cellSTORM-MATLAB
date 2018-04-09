% specify the folder where the A to B paris are placed
filedir_GT = 'Artificial dataset-TS_nobg_png_frames';
filedir_HW = 'MOV_2018_03_12_14_07_02_ISO6400_texp_1_400_ArtificialMicrotubes_Checkerboard';%MOV_2018_02_28_10_57_39_ISO3200_texp1_200_randomtestSTORM'
filedir_dest = [filedir_HW filedir_GT '_shifted_combined_newaligned'];
mydestsize = 256;

filedir_GT = ['./LINES/' filedir_GT];
filedir_HW = ['./' filedir_HW];

%% Find matching test cases in the two directories]
dir_gt = dir(fullfile(filedir_GT, '/*.png')); dir_gt={dir_gt.name}; %
dir_hw = dir(fullfile(filedir_HW, '/*.png')); dir_hw={dir_hw.name};%]]

% create folder for batches
tmp_dir_GT = [filedir_dest  '/train'];
if (~exist(tmp_dir_GT, 'dir')); mkdir(tmp_dir_GT ); end%if


%% read whiteframes 
% first measured date
whiteframe_hw = imread([ filedir_HW '/XXX_Whiteframe.png']);

% then groundtruth frame
whiteframe_gt = flip(imread([ filedir_GT '/XX_Checkerboard.png']));

%estimate zoom and expand 2D dimensions to match the GT data
myzoom_diff = size(whiteframe_hw)/size(whiteframe_gt);
whiteframe_hw = uint8(extract(affine_trans(whiteframe_hw, [myzoom_diff myzoom_diff], [0 0], 0), size(whiteframe_gt)));
whiteframe_hw(whiteframe_hw==0) = mean(mean(whiteframe_hw(20,:)));

% find perfect match
[out] = find_affine_trans(whiteframe_gt,whiteframe_hw, [.8, .8, 1, 1, 0])
whiteframe_gt = affine_trans(whiteframe_gt, [out(1), out(2)], [out(3), out(4)], out(5));
cat(3, dip_image(whiteframe_hw), whiteframe_gt)



nfiles = length(dir_gt);
%% save image pairs
for i = 1:nfiles
    
    
    try
        %% load image, shift and sava as A to B pair
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% read in the image-pairs
        %i=round(rand(1)*nfiles)
        % read in the image-pairs
        backgroundval = 15; 
        disp(['backgroundval is : ' num2str(backgroundval)])
        img_gt_raw = imread([filedir_GT '/' dir_gt{i}])-15;
        img_hw = imread([filedir_HW '/' dir_gt{i}]);
        
        %estimate zoom
        img_hw = uint8(extract(affine_trans(img_hw, [myzoom_diff myzoom_diff], [0 0], 0), size(img_gt_raw)));
        
        % find perfect match
        img_gt = affine_trans(img_gt_raw, [out(1), out(2)], [out(3)-.75, out(4)-.2], out(5));

        % shift gt image according to shift of images
        %img_gt = uint8(affine_trans(img_gt_raw, myzoom, mytrans, myrot));
        if(0), dip_image(cat(3, img_gt, img_hw)), end % check if it's working
        
        % crop away uncertain data region - otherwise there will be a hard
        % edge
        my_innersize = 205;
        img_hw = extract(dip_image(img_hw), [my_innersize my_innersize ]);
        img_gt = extract(dip_image(img_gt), [my_innersize my_innersize ]);
        
        
        %return
        diff_size_hw = [mydestsize mydestsize] - size(img_hw);
        diff_size_gt = [mydestsize mydestsize] - size(img_hw);
        if(0)
            img_hw = extract(dip_image(img_hw), [mydestsize mydestsize ]);
            img_gt = extract(dip_image(img_gt), [mydestsize mydestsize ]);
        else
            img_gt(img_gt<0) = 0;
            img_gt = uint8(img_gt); img_hw = uint8(img_hw);
            img_gt_pad = padarray(img_gt,diff_size_gt,'circular','post');
            img_hw_pad = padarray(img_hw,diff_size_hw,'circular','post');
        end
        
        crop_gt = uint8(horzcat(img_hw_pad, img_gt_pad));
        imwrite(crop_gt, [tmp_dir_GT '/Image_' num2str(i) '.png'])
        
        
        
        disp([num2str(i) ' / ' num2str(length(dir_gt))])
    catch
        disp('Not found or another error ! ')
    end
    
end


dip_image(cat(3, img_gt, img_hw))
