% Prepare the Tif-stacks as video
% file reads a file generated with testSTORM as multitiff and prepares it
% for the display on a second cellphone
% first: white layers for perspective calibration will be added
% second: a barcode for encoding the framenumber is encoded
tif_stack_folder = './MOV_2018_02_06_16_25_19_ISO3200_texp_1_45_line_combined_unprocessed_forAlex_alltogether_2/';
tif_stack_folder_dest = [tif_stack_folder '_aligned/'];
tif_realA = 'realA.tiff';
tif_realB = 'realB.tiff';
tif_fakeB = 'fakeB.tiff';

if (~exist(tif_stack_folder_dest, 'dir')); mkdir(tif_stack_folder_dest ); end%if

% create tif file object
info = imfinfo([tif_stack_folder tif_realA]);

%AllAllFrames_HWFrames = readtimeseries(fname);
n_frames = size(info,1);

%% initiliaze stuff
est_zoom = [1 1];
est_trans = [0 0];
est_rot = 0;
affine_trans_BA = {};
affine_trans_BB = {};
affine_shift_BA = {};
affine_shift_BB = {};

frame_realA_i = {};
%% estimate affine shift first
for i = round(rand(1,10)*n_frames)
    
    % read the images
    frame_realA = imread([tif_stack_folder tif_realA], i);
    frame_realB = imread([tif_stack_folder tif_realB], i);
    frame_fakeB = imread([tif_stack_folder tif_fakeB], i);
    
    % try to find the estimate of the shift transformation from groundtruth data to realA/fakeB
    affine_shift_BA{i} = findshift(frame_realA, frame_realB, 'iter');
    affine_shift_BB{i} = findshift(frame_fakeB, frame_realB, 'iter');
    
    
    
    
    disp(num2str(i) )
    
    if (0)
        dip_image(cat(3, frame_realA, frame_realB, frame_fakeB))
    end
    
end

affine_shift_BA_mean = double(mean(dip_image(cat(3, affine_shift_BA{:})), [], 3));
affine_shift_BB_mean = double(mean(dip_image(cat(3, affine_shift_BB{:})), [], 3));
affine_shift_mean = (affine_shift_BA_mean+affine_shift_BB_mean)/2;



%% estimate affine shift
for i = round(rand(1,10)*n_frames)
    
    % read the images
    frame_realA = imread([tif_stack_folder tif_realA], i);
    frame_realB = imread([tif_stack_folder tif_realB], i);
    frame_fakeB = imread([tif_stack_folder tif_fakeB], i);
    
    frame_realA_shift = shift(frame_realA, -affine_shift_mean);
    frame_fakeB_shift = shift(frame_fakeB, -affine_shift_mean);
    
    
    % try to find the estimate of the affine transformation from groundtruth data to realA/fakeB
    affine_trans_BA{i} = find_affine_trans(frame_realB, frame_realA, [est_zoom est_trans est_rot]);
    affine_trans_BB{i} = find_affine_trans(frame_realB, frame_fakeB, [est_zoom est_trans est_rot]);
    
end

affine_trans_BA_mean = double(mean(dip_image(cat(3, affine_trans_BA{:})), [], 3));
affine_trans_BB_mean = double(mean(dip_image(cat(3, affine_trans_BB{:})), [], 3));
affine_trans_mean = (affine_trans_BA_mean+affine_trans_BB_mean)/2;

if(1)
    my_zoom = (2-affine_trans_mean(1:2));
    my_trans = -affine_trans_mean(3:4);
    my_rot = -affine_trans_mean(5);
end
%% test alignment
for(i=1:n_frames)
    %% read the images
    frame_realA = imread([tif_stack_folder tif_realA], i);
    frame_realB = imread([tif_stack_folder tif_realB], i);
    frame_fakeB = imread([tif_stack_folder tif_fakeB], i);
    
    
    
    
    frame_realA = affine_trans(frame_realA, my_zoom, - my_trans + affine_shift_mean', my_rot);
    frame_fakeB = affine_trans(frame_fakeB, my_zoom, - my_trans + affine_shift_mean', my_rot);
    
    if(0)
        cat(3, frame_realB, frame_realA, frame_fakeB)
    end
    

    
    %% write back to file
    % write image
    imwrite(uint8(frame_realA), [tif_stack_folder_dest tif_realA], 'WriteMode', 'append');
    imwrite(uint8(frame_fakeB), [tif_stack_folder_dest tif_fakeB], 'WriteMode', 'append');
    imwrite(uint8(frame_realB), [tif_stack_folder_dest tif_realB], 'WriteMode', 'append');
    
    disp(i)
end
