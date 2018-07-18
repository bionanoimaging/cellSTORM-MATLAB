% specify the folder where the A to B paris are placed
myfiledir = '/home/useradmin/Dropbox/Dokumente/Promotion/PROJECTS/STORM/DATASET_NN/04_UNPROCESSED_RAW_HW/LINES/MOV_2018_03_08_13_01_45_Microtubuli_noBG_ISO3200_texp_1_100Thunderstorm_Microtubuline_Artificial_dataset-TS_nobg_png_frames_shifted_combined_newaligned/train/';
filedir_dest = ['/home/useradmin/Dropbox/Dokumente/Promotion/PROJECTS/STORM/DATASET_NN/04_UNPROCESSED_RAW_HW/LINES/alltogether_1_crop_2018_03_08/train/'];

if (~exist(filedir_dest, 'dir')); mkdir(filedir_dest ); end%if
mydestsize = 256;

% Get all files as a list
srcFiles = dir([myfiledir '*.png']);  % the folder in which ur images exists



%% Test the shift
myindex = randi([0 size(srcFiles,1)],1,1);
% read in the image-pairs
my_img = imread([myfiledir '/' srcFiles(myindex).name]);
mysize = size(my_img);


% split the PNG
my_hw = my_img(:,1:mysize(2)/2);
my_gt = my_img(:,(mysize(2)/2+1):end);
dip_image(cat(3, my_hw, my_gt));


%% find shift of the files
shift_i = {};
nfiles = length(srcFiles);

shiftxy2d = {};
shiftxy = 0;
shiftaffine2d={};

for i = 1:nfiles
    
    disp([num2str(i) '/ BACKGROUND"""']);
    %% read random images from datastack
    %
    % read in the image-pairs
    
    % find shift
    
    nlimit = 25;
    if (0)% i < nlimit)
        
        
        myindex = randi([0 size(srcFiles,1)],1,1);
        my_img = readim([myfiledir '/' srcFiles(myindex).name]);
        
        % split the PNG
        my_hw = my_img(0:mysize(2)/2-1,:);
        my_gt = my_img((mysize(2)/2):end, :);
        
        my_hw = my_gt*(my_hw > 3);
        my_hw = my_hw./max(my_hw);
        my_gt = my_gt*(my_gt > 3);
        my_gt = my_gt./max(my_gt);
        
        sub_size = 64;
        my_hw = extract((my_hw).^3, [sub_size sub_size]);
        my_gt = extract((my_gt).^3, [sub_size sub_size]);
       
        
        shiftxy2d{i} = findshift((my_hw), (my_gt), 'iter', 0);
        shiftaffine2d{i} =  find_affine_trans((my_hw), (my_gt), [1 1 shiftxy2d{i}' 0]);
        
    elseif ( 0)%i == nlimit)
        shiftxy = cat(2, shiftxy2d{:});
        shiftxy = mean(shiftxy');
        
        shiftaffine = vertcat(shiftaffine2d{:,:});
        shiftaffine = mean(shiftaffine, 1);
    else
        %%
        my_img = readim([myfiledir '/' srcFiles(i).name]);
        
        % split the PNG
        my_hw = my_img(0:mysize(2)/2-1,:);
        my_gt = my_img((mysize(2)/2):end, :)-15;
        
        % dip_image(cat(3, my_hw, my_gt))
        
        %shiftxy=0*shiftxy;
        %my_gt = affine(my_gt, (shiftxy));
        myzoom = [ 1.0037    1.0037];%[1 1]*mean(shiftaffine(1:2));
        myshift = [ -0.0489+.1   0.5227];% [shiftaffine(3) shiftaffine(4)+.5];
        myrot =     0.0023 ; %shiftaffine(5);
        
        my_gt = affine_trans(my_gt, myzoom, myshift, myrot);
        % cat(3, my_hw, my_gt)
        % upsampling
        
        sub_size = 64;
        my_hw = extract((my_hw), [sub_size sub_size]);
        my_gt = extract((my_gt), [sub_size sub_size]);
        
        if(0)
            my_hw_full = zeros(128, 128);
            my_gt_full = zeros(128, 128);
            
            shift1 = [rand(1)*64, rand(1)*64];
            shift2 = [rand(1)*64, rand(1)*64];
            shift3 = [rand(1)*64, rand(1)*64];
            shift4 = [rand(1)*64, rand(1)*64];
            
            % shift and paste into big grid
            my_hw_full(1:64, 1:64) = DampEdge(shift(my_hw, shift1), 0.1,2,1,1);
            my_gt_full(1:64, 1:64) = DampEdge(shift(my_gt, shift1), 0.1,2,1,1);
            
            my_hw_full(65:end, 1:64) = DampEdge(shift(my_hw, shift2), 0.1,2,1,1);
            my_gt_full(65:end, 1:64) = DampEdge(shift(my_gt, shift2), 0.1,2,1,1);
            
            my_hw_full(1:64, 65:end) = DampEdge(shift(my_hw, shift3), 0.1,2,1,1);
            my_gt_full(1:64, 65:end) = DampEdge(shift(my_gt, shift3), 0.1,2,1,1);
            
            my_hw_full(65:end, 65:end) = DampEdge(shift(my_hw, shift4), 0.1,2,1,1);
            my_gt_full(65:end, 65:end) = DampEdge(shift(my_gt, shift4), 0.1,2,1,1);
            
            
            
            
        else
            my_hw_full = extract(DampEdge(my_hw, 0.15,2,1,2), [128 128]);
            my_gt_full = extract(DampEdge(my_gt, 0.15,2,1,2), [128 128]);
            
        end
        
        
        
        %dip_image(cat(3, my_hw_full, my_gt_full))
        
        %%

        my_hw_full = extract(dip_image(my_hw_full), [256 256]);
        my_gt_full = extract(dip_image(my_gt_full), [256 256]);
        
        crop_gt = uint8(horzcat(my_hw_full, my_gt_full));
        imwrite(crop_gt, [filedir_dest '/CROP_' srcFiles(i).name ])
    end
    
end
