% specify the folder where the A to B paris are placed
filedir_dest = 'MOV_2018_02_15_16_02_27_ISO3200_texp_1_500_lines_combined/';


if(not(isvarname('filedir_GT')))
    filedir_GT = '/home/useradmin/Dropbox/Dokumente/Promotion/PROJECTS/STORM/DATASET_NN/00_GT_ALLIGNED/';
    filedir_HW = '/home/useradmin/Dropbox/Dokumente/Promotion/PROJECTS/STORM/DATASET_NN/00_CELLPHONE_ALLIGNED/';
    
    filedir_GT = [uigetdir(filedir_GT) '/'];
    filedir_HW = [uigetdir(filedir_HW) '/'];
end
%% Find matching test cases in the two directories]
dir_gt = dir(fullfile(filedir_GT, '*.png')); dir_gt={dir_gt.name}; %
dir_hw = dir(fullfile(filedir_HW, '*.png')); dir_hw={dir_hw.name};%]]

% create folder for batches
tmp_dir_GT = [filedir_dest  '/gt_batch_train'];
if (~exist(tmp_dir_GT, 'dir')); mkdir(tmp_dir_GT ); end%if
tmp_dir_HW = [filedir_dest  '/hw_batch_train'];
if (~exist(tmp_dir_HW, 'dir')); mkdir(tmp_dir_HW ); end%if

% create folder for batches
tmp_dir_GT_test = [filedir_dest  '/gt_batch_test'];
if (~exist(tmp_dir_GT_test, 'dir')); mkdir(tmp_dir_GT_test ); end%if
tmp_dir_HW_test = [filedir_dest  '/hw_batch_test'];
if (~exist(tmp_dir_HW_test, 'dir')); mkdir(tmp_dir_HW_test ); end%if

% create folder for batches
tmp_dir_GT_valid = [filedir_dest  '/gt_batch_valid'];
if (~exist(tmp_dir_GT_valid, 'dir')); mkdir(tmp_dir_GT_valid ); end%if
tmp_dir_HW_valid = [filedir_dest  '/hw_batch'];
if (~exist(tmp_dir_HW_valid, 'dir')); mkdir(tmp_dir_HW_valid ); end%if


% create folder for batches
tmp_dir_HWGT = [filedir_dest  '/hwgt_batch_train'];
if (~exist(tmp_dir_HWGT, 'dir')); mkdir(tmp_dir_HWGT ); end%if
tmp_dir_HWGT_valid = [filedir_dest  '/hwgt_batch_valid'];
if (~exist(tmp_dir_HWGT_valid, 'dir')); mkdir(tmp_dir_HWGT_valid ); end%if
tmp_dir_HWGT_test = [filedir_dest  '/hwgt_batch_test'];
if (~exist(tmp_dir_HWGT_test, 'dir')); mkdir(tmp_dir_HWGT_test ); end%if



%% Data reading
nfiles = length(dir_hw);
for i = 1:nfiles
    % read in the image-pairs
    img_gt = imread([filedir_GT '/' dir_gt{i}]);
    img_hw = imread([filedir_HW '/' dir_hw{i}]);
    
    % set cropping parameters
    [n m]= size(img_gt);
    n = n-10; m=m-10; % take care of the barcode!
    L = 256; % size of one mini patch
    
    
    
    for xi = 0:3 % number of crops in x
        for yi = 0:3 % number of crops in x
            
            if(0)
                % Crop; Take care of the 16 pixel kernel width of the jpeg compression
                crop_roi_x = idivide(int32(randi(n-L+1)), int32(16))+int32(0:L-1); crop_roi_x = crop_roi_x + 1;
                crop_roi_y = idivide(int32(randi(n-L+1)), int32(16))+int32(0:L-1); crop_roi_y = crop_roi_y + 1;
                
                crop_gt = img_gt(crop_roi_x, crop_roi_y);
                crop_hw = img_hw(crop_roi_x, crop_roi_y);
                
                if(0)
                    cat(3, dip_image(crop_gt), dip_image(crop_hw))
                    cat(3, dip_image(img_gt), dip_image(img_hw))
                end
            end
            
            % randomly shift the cut-out box, so that there is no jpeg
            % pattern visible from the images - maybe solves the effect
            % already!
            rand_x = randi(8);
            rand_y = randi(8);
            
            crop_gt = img_gt(L*xi+1+rand_y:(L*xi)+L+rand_y, L*yi+1+rand_x:(L*yi)+L+rand_x);
            crop_hw = img_hw(L*xi+1+rand_y:(L*xi)+L+rand_y, L*yi+1+rand_x:(L*yi)+L+rand_x);
            
            
            crop_gt_hw = cat(2, crop_hw, crop_gt);
            if(0)
                if(i/nfiles<0.7)
                    % save the images as training
                    imwrite(crop_gt, [tmp_dir_HW '/Image_' num2str(i) '_' num2str(xi) '_' num2str(yi) '.png'])
                    imwrite(crop_hw, [tmp_dir_GT '/Image_' num2str(i) '_' num2str(xi) '_' num2str(yi) '.png'])
                elseif(i/nfiles<0.85)
                    % save the images as testing
                    imwrite(crop_gt, [tmp_dir_HW_test '/Image_' num2str(i) '_' num2str(xi) '_' num2str(yi) '.png'])
                    imwrite(crop_hw, [tmp_dir_GT_test '/Image_' num2str(i) '_' num2str(xi) '_' num2str(yi) '.png'])
                else
                    % save the images as testing
                    imwrite(crop_gt, [tmp_dir_HW_valid '/Image_' num2str(i) '_' num2str(xi) '_' num2str(yi) '.png'])
                    imwrite(crop_hw, [tmp_dir_GT_valid '/Image_' num2str(i) '_' num2str(xi) '_' num2str(yi) '.png'])
                end
                
            else
                if(i/nfiles<0.7)
                    % save the images as training
                    imwrite(crop_gt_hw, [tmp_dir_HWGT '/Image_' num2str(i) '_' num2str(xi) '_' num2str(yi) '.png'])
                    
                elseif(i/nfiles<0.85)
                    % save the images as testing
                    imwrite(crop_gt_hw, [tmp_dir_HWGT_test '/Image_' num2str(i) '_' num2str(xi) '_' num2str(yi) '.png'])
                    
                else
                    % save the images as testing
                    imwrite(crop_gt_hw, [tmp_dir_HWGT_valid '/Image_' num2str(i) '_' num2str(xi) '_' num2str(yi) '.png'])
                    
                end
            end
            % disp([num2str(xi) ' / ' num2str(length(yi))])
            
            
            
        end
        
    end
    
    disp([num2str(i) ' / ' num2str(length(dir_hw))])
end


dip_image(cat(3, img_gt, img_hw))
