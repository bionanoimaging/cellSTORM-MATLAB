% specify the folder where the A to B paris are placed
filedir_GT = 'Thunderstorm_Microtubuline_Artificial_dataset-TS_nobg_png_frames';
filedir_HW = 'MOV_2018_03_12_13_51_33';%MOV_2018_02_28_10_57_39_ISO3200_texp1_200_randomtestSTORM'
filedir_dest = [filedir_HW filedir_GT '_shifted_combined_newaligned'];
mydestsize = 256;

filedir_GT = ['./LINES/' filedir_GT];
filedir_HW = ['./LINES/' filedir_HW];

%% read whiteframe
whiteframe = imread([ filedir_HW '/XXX_Whiteframe.png'])

% detect the coordinates of the box
disp('select outer frame')
[X1 myMask] = getFrameCoordinates(whiteframe);
mysize = size(whiteframe);
X2 = [0 0; mysize(2) 0; mysize(2)  mysize(1); 0 mysize(1)];

%% Find matching test cases in the two directories]
dir_gt = dir(fullfile(filedir_GT, '/*.png')); dir_gt={dir_gt.name}; %
dir_hw = dir(fullfile(filedir_HW, '/*.png')); dir_hw={dir_hw.name};%]]

% create folder for batches
tmp_dir_GT = [filedir_dest  '/train'];
if (~exist(tmp_dir_GT, 'dir')); mkdir(tmp_dir_GT ); end%if

%% Test the shift
i = round(rand(1,1)*1000);
% read in the image-pairs
img_gt = imread([filedir_GT '/' dir_gt{i}]);
img_hw = imread([filedir_HW '/' dir_gt{i}]);

%estimate zoom
myzoom_diff = size(img_hw)/size(img_gt);
img_gt_aff = uint8(extract(affine_trans(img_gt, [myzoom_diff myzoom_diff], [0 0], 0), size(img_hw)));

% crop frame to match the recorded one
[tform, ~, ~] = estimateGeometricTransform(X2, X1, 'projective');
outputView = imref2d(mysize);
img_gt_morphed = imwarp(img_gt_aff,tform,'OutputView',outputView);

% check if it worked
dip_image(cat(3, img_gt_morphed, img_hw, img_gt_aff))



%% find shift of the files
shift_i = {};
nfiles = length(dir_gt);
for i = 1:100
    disp(i);
    try
        %%
        i=round(rand(1)*nfiles)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% read in the image-pairs
        % read in the image-pairs
        img_gt = imread([filedir_GT '/' dir_gt{i}]);
        img_hw = imread([filedir_HW '/' dir_gt{i}]);
        
        %estimate zoom
        myzoom_diff = size(img_hw)/size(img_gt);
        img_gt = uint8(extract(affine_trans(img_gt, [myzoom_diff myzoom_diff], [0 0], 0), size(img_hw)));
        
        % crop frame to match the recorded one
        [tform, ~, ~] = estimateGeometricTransform(X2, X1, 'projective');
        outputView = imref2d(mysize);
        img_gt_morphed = imwarp(img_gt,tform,'OutputView',outputView);
        
        %dip_image(cat(3, img_gt_morphed, img_hw, img_gt_aff));
        %%
        img_gt = img_gt_morphed;
        img_gt = extract(dip_image(img_gt), [128 128]);
        img_hw = extract(dip_image(img_hw), [128 128]);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        cat(3, img_gt, img_hw)
        
        % measure the shift and then the rotation/zoom
        outxy = findshift(img_gt, img_hw, 'iter');
        [out] = find_affine_trans(img_gt, img_hw, [1, 1, outxy(1), outxy(2), 0]);
        zoomx = out(1);
        zoomy = out(2);
        transx = out(3);
        transy = out(4);
        rotxy = out(5);
       
        img_gt_aff = affine_trans(img_gt, [zoomx zoomy], [transx transy], rotxy);
        outxy = findshift(img_gt_aff, img_hw, 'iter');
        img_gt_aff_post = shift(img_gt_aff, outxy);
        
        cat(3, dip_image(img_gt), img_gt_aff_post, img_gt_aff,  dip_image(img_hw))
        
        
        %estimate zoom
        sv2 = findshift(img_hw, img_gt_morphed ,'ffts');
        shift_i_sv2{i} = sv2;
        
    catch
        disp('does not exist or wrong shift')
    end
    
end


% Estimate shift
shiftxy = cat(2, shift_i_sv2{:});
[~, ~, ~, sv2_final_m1] = isoutlier(shiftxy(1,:));
[~, ~, ~, sv2_final_m2] = isoutlier(shiftxy(2,:));
sv2_final = [sv2_final_m1; sv2_final_m2];



%% estimate affine transformation
nfiles = length(dir_gt);
affine_shift_i_sv2 = {};
for j = 1:25
    %% i= round(rand(1,1)*nfiles);
    try
        i=round(rand(1)*nfiles);
        disp([num2str(i) ' / ' num2str(j)])
        % read in the image-pairs
        img_gt = imread([filedir_GT '/' dir_gt{i}]);
        img_hw = imread([filedir_HW '/' dir_gt{i}]);
        
        %estimate zoom
        myzoom_diff = size(img_hw)/size(img_gt);
        img_gt_aff = uint8(extract(affine_trans(img_gt, [myzoom_diff myzoom_diff], [0 0], 0), size(img_hw)));
        
        % crop frame to match the recorded one
        [tform, ~, ~] = estimateGeometricTransform(X2, X1, 'projective');
        outputView = imref2d(mysize);
        img_gt_morphed = imwarp(img_gt_aff,tform,'OutputView',outputView);
        img_gt = shift(img_gt_morphed, sv2_final);
        
        
        %sv1 = findshift(img_gt,img_hw);
        [out] = find_affine_trans(img_hw, img_gt, [1, 1, sv2_final', 0]);
        affine_shift_i_sv2{j} = out;
    catch
        disp('does not exist or wrong shift')
    end
    
end


affine_trans_shiftxy = vertcat(affine_shift_i_sv2{:});

%% seek for affine parameters - remove outliers!!
[~, ~, ~, myzoom_x] = isoutlier(affine_trans_shiftxy(:,1)');
[~, ~, ~, myzoom_y] = isoutlier(affine_trans_shiftxy(:,2)');
[~, ~, ~, mytrans_x] = isoutlier(affine_trans_shiftxy(:,3)');
[~, ~, ~, mytrans_y] = isoutlier(affine_trans_shiftxy(:,4)');
[~, ~, ~, myrot] = isoutlier(affine_trans_shiftxy(:,5)');


% disp shift
figure
plot(affine_trans_shiftxy(:,1))
hold on
plot(affine_trans_shiftxy(:,2))
plot(affine_trans_shiftxy(:,3))
plot(affine_trans_shiftxy(:,4))
plot(affine_trans_shiftxy(:,5))
legend('zoomx', 'zoomy', 'transx', 'transy', 'rot')

plot(myzoom_x*ones(size(affine_trans_shiftxy(2,:))))
plot(myzoom_y*ones(size(affine_trans_shiftxy(2,:))))
plot(mytrans_x*ones(size(affine_trans_shiftxy(2,:))))
plot(mytrans_y*ones(size(affine_trans_shiftxy(2,:))))
plot(myrot*ones(size(affine_trans_shiftxy(2,:))))

legend('zoomx', 'zoomy', 'transx', 'transy', 'rot')
hold off
drawnow


% disp values
disp(['myzoom_x: ' num2str(myzoom_x)])
disp(['myzoom_y: ' num2str(myzoom_y)])
disp(['mytrans_x: ' num2str(mytrans_x)])
disp(['mytrans_y: ' num2str(mytrans_y)])
disp(['myrot: ' num2str(myrot)])

%% save image pairs
for i = 1:nfiles
    
    
    try
        %% load image, shift and sava as A to B pair
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% read in the image-pairs
        %i=round(rand(1)*nfiles)
        % read in the image-pairs
        img_gt = imread([filedir_GT '/' dir_gt{i}]);
        img_hw = imread([filedir_HW '/' dir_gt{i}]);
        
        %estimate zoom
        myzoom_diff = size(img_hw)/size(img_gt);
        img_gt_aff = uint8(extract(affine_trans(img_gt, [myzoom_diff myzoom_diff], [0 0], 0), size(img_hw)));
        
        % crop frame to match the recorded one
        [tform, ~, ~] = estimateGeometricTransform(X2, X1, 'projective');
        outputView = imref2d(mysize);
        img_gt_morphed = imwarp(img_gt_aff,tform,'OutputView',outputView);
        
        %dip_image(cat(3, img_gt_morphed, img_hw, img_gt_aff));
        % img_gt = shift(img_gt_morphed, sv2_final);
        img_gt_morphed = shift(img_gt_morphed, sv2_final);
        img_gt = affine_trans(img_gt_morphed, [myzoom_x, myzoom_y], [mytrans_x, mytrans_y], (-myrot));
        
        
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
