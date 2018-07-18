% specify the folder where the A to B paris are placed
filedir_GT = 'testSTORM_4000frames_2500emitter_dense_256px_params_png_frames';
filedir_HW = 'MOV_2018_03_06_11_43_47_randomBlink2500_lines_ISO6400_texp_1_125';%MOV_2018_02_28_10_57_39_ISO3200_texp1_200_randomtestSTORM'
filedir_dest = [filedir_HW filedir_GT '_shifted_combined'];

if(not(isvarname('filedir_GT')))
    filedir_GT = '/home/useradmin/Dropbox/Dokumente/Promotion/PROJECTS/STORM/DATASET_NN/00_GT_ALLIGNED/';
    filedir_HW = '/home/useradmin/Dropbox/Dokumente/Promotion/PROJECTS/STORM/DATASET_NN/00_CELLPHONE_ALLIGNED/';
    
    filedir_GT = [uigetdir(filedir_GT) '/'];
    filedir_HW = [uigetdir(filedir_HW) '/'];
end
%% Find matching test cases in the two directories]
dir_gt = dir(fullfile(filedir_GT, '/*.png')); dir_gt={dir_gt.name}; %
dir_hw = dir(fullfile(filedir_HW, '/*.png')); dir_hw={dir_hw.name};%]]

% create folder for batches
tmp_dir_GT = [filedir_dest  '/train'];
if (~exist(tmp_dir_GT, 'dir')); mkdir(tmp_dir_GT ); end%if

%% find shift of the files 
shift_i = {};
for i = 1:100
    
    try
        
        %i=round(rand(1)*nfiles)
        % read in the image-pairs
        img_gt = imread([filedir_GT '/' dir_gt{i}]);
        img_hw = imread([filedir_HW '/' dir_gt{i}]);
        
        %sv1 = findshift(img_gt,img_hw);
        sv2 = findshift(img_hw, img_gt,'ffts');
        shift_i_sv2{i} = sv2;
    catch
        disp('does not exist or wrong shift')
    end
    
end

shiftxy = cat(2, shift_i_sv2{:});
sv2_final = [mean(shiftxy(1,:)); mean(shiftxy(2,:))];

% disp shift 
figure
plot(shiftxy(1,:))
hold on
plot(shiftxy(2,:))
plot(mean(shiftxy(2,:))*ones(size(shiftxy(2,:))))
plot(mean(shiftxy(1,:))*ones(size(shiftxy(2,:))))
hold off

% estimate affine transformation
nfiles = length(dir_gt);
for j = 1:25
    %i= round(rand(1,1)*nfiles);
    try
        i=round(rand(1)*nfiles)
        % read in the image-pairs
        img_gt = readim([filedir_GT '/' dir_gt{i}]);
        img_hw = readim([filedir_HW '/' dir_gt{i}]);
        
        %sv1 = findshift(img_gt,img_hw);
        [out] = find_affine_trans(img_hw, img_gt, [1, 1, sv2_final', 0]);
        affine_shift_i_sv2{i} = out;
    catch
        disp('does not exist or wrong shift')
    end
    
end


affine_trans_shiftxy = vertcat(affine_shift_i_sv2{:});

% disp shift
figure
plot(affine_trans_shiftxy(:,1))
hold on
plot(affine_trans_shiftxy(:,2))
plot(affine_trans_shiftxy(:,3))
plot(affine_trans_shiftxy(:,4))
plot(affine_trans_shiftxy(:,5))
legend('zoomx', 'zoomy', 'transx', 'transy', 'rot')

plot(mean(affine_trans_shiftxy(:,1))*ones(size(affine_trans_shiftxy(2,:))))
plot(mean(affine_trans_shiftxy(:,2))*ones(size(affine_trans_shiftxy(2,:))))
plot(mean(affine_trans_shiftxy(:,3))*ones(size(affine_trans_shiftxy(2,:))))
plot(mean(affine_trans_shiftxy(:,4))*ones(size(affine_trans_shiftxy(2,:))))
plot(mean(affine_trans_shiftxy(:,5))*ones(size(affine_trans_shiftxy(2,:))))

legend('zoomx', 'zoomy', 'transx', 'transy', 'rot')
hold off



%% Data reading
myzoom = mean(affine_trans_shiftxy(:,1:2));
mytrans = mean(affine_trans_shiftxy(:,3:4));
myrot = mean(affine_trans_shiftxy(:,5));


%% save image pairs
nfiles = length(dir_gt);
for i = 1:nfiles
    
    
    try
        %% load image, shift and sava as A to B pair
        
        % i=round(rand(1)*nfiles)
        % read in the image-pairs
        img_gt = imread([filedir_GT '/' dir_gt{i}]);
        img_hw = imread([filedir_HW '/' dir_gt{i}]);
        
        % shift gt image according to shift of images
        %img_gt = uint8(shift(img_gt_raw, sv2_final));
        img_hw = uint8(affine_trans(img_hw, myzoom, mytrans, myrot));
        %img_gt = uint8(affine_trans(img_gt_raw, myzoom, mytrans, myrot));
        if(1), dip_image(cat(3, img_gt, img_hw)), end % check if it's working
        
        %return
        crop_gt = horzcat(img_hw, img_gt*1.2);
        imwrite(crop_gt, [tmp_dir_GT '/Image_' num2str(i) '.png'])
        
        
        
        disp([num2str(i) ' / ' num2str(length(dir_gt))])
    catch
        disp('Not found')
    end
    
end


dip_image(cat(3, img_gt, img_hw))
