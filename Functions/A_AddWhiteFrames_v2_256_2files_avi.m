% Prepare the Tif-stacks as video
% file reads a file generated with testSTORM as multitiff and prepares it
% for the display on a second cellphone
% first: white layers for perspective calibration will be added
% second: a barcode for encoding the framenumber is encoded
tif_stack = './testSTORM/testSTORM_4000frames_2500emitter_dense_256px_params';
tif_stack_2 = './testSTORM/testSTORM_lines_256_256';
mat_stack = 'testSTORM_2000frames_1000emitter_dense_256px';
png_stack_path = [tif_stack '_png_frames'];
%tif_stack = '800Emitters';
extension_stack = '.tif';
extension_video = '.mp4';
extension_mat = '.mat';
fname = [tif_stack extension_stack];
fname_2 = [tif_stack_2 extension_stack];
vname = [tif_stack extension_video];


if strcmp(extension_video, '.mp4')
    
    % create video writer object
    myVideo = VideoWriter(vname, 'MPEG-4');%'Grayscale AVI');%,'Uncompressed AVI');
    myVideo.FrameRate = 3;  % Default 30
    %myVideo.CompressionRatio = 1;
    myVideo.Quality = 100;
    %myVideoCompressionMethod = 'None';
    %myVideo.LosslessCompression = True;
    
elseif strcmp(extension_video, '.avi')
    
    % create video writer object
    myVideo = VideoWriter(vname, 'Uncompressed AVI');
    myVideo.FrameRate = 3;  % Default 30
    %myVideo.CompressionRatio = 1;
    %myVideo.Quality = 100;
    %myVideoCompressionMethod = 'None';
    %myVideo.LosslessCompression = True;
end


open(myVideo);


try
    ismatstack = false;
    % create tif file object
    tif_info = imfinfo(fname);
    %AllAllFrames_HWFrames = readtimeseries(fname);
    n_frames = size(tif_info,1);
    
    %% do the same for a second file
    tif_info_2 = imfinfo(fname_2);
    %AllAllFrames_HWFrames = readtimeseries(fname);
    n_frames_2 = size(tif_info_2,1);
    
    i = 1;
    iframe = imread(fname, i);
    iframe = 2^8*iframe./max(iframe);
    
    % mkdir if not exist
    if (~exist(png_stack_path, 'dir')); mkdir(png_stack_path ); end%if
    
    
    
catch
    
    ismatstack = true;
    disp('no tif stack - maybe mat?')
    if(exist('result_psf_mat') | exist('result_gt_mat') )
        disp('Variable already assigned')
    else
        load(mat_stack, 'result_psf', 'result_gt')
    end
    
    
    result_psf = result_psf_mat;
    
    n_frames = size(result_psf, 3);
    iframe = squeeze(result_psf(:,:,1));
    
    maxIntensityVal = max(max(max(iframe)));
    
    
end


frame_i = {};
i = 1;

firstframe = ones(1080, 1080)*2^8;
firstframe = uint8(firstframe- extract(dip_image(2^8* ones(256, 256)), [1080 1080]));
% add white frames to the video
for i=1:50
    writeVideo(myVideo, firstframe);
end
% barcode size define
barcode_width = 30;

% add white frames to the video
for i=1:10
    
    iframe = zeros(1080,1080);
    % generate the barcodes for each frame
    mybarcode = d2b(6666,14);
    mybarcode = imresize(mybarcode, [barcode_width , size(iframe,2)],'nearest');
    
    % concat barcode with frame
    iframe(end-barcode_width+1:end,:)= uint8(mybarcode);
    
    writeVideo(myVideo, iframe);
end

is_augmentdata = true
my_framenumber = 1;
n_augmentations = 2;
%% write out frames with concatenated barcode
for i = 1:n_frames
    
    % read frame
    
    iframe_raw = dip_image(imread(fname, i));
    %iframe(iframe>5000) = 5000;
    iframe_raw = 2^8*(iframe_raw)./max(iframe_raw);
    
    % augment data
    for i=1:n_augmentations
        iframe = augmentImage(iframe_raw);
        
        % save the frame
        imwrite(uint8(iframe), [png_stack_path '/Image_' num2str(my_framenumber) '.png'])
        
        % eventually expand the frame if size doesn't matchj
        if(max(iframe)< 1080)
            iframe = double(extract((iframe), [1080 1080]));
        end
        
        
        % generate the barcodes for each frame
        mybarcode = d2b(my_framenumber,14);
        mybarcode = imresize(mybarcode, [barcode_width , size(iframe,2)], 'nearest');
        
        
        % concat barcode with frame
        iframe(end-barcode_width+1:end,:) = 2^8.*uint8(mybarcode);
        if(0) frame_i{i}=iframe; end
        
        iframe = uint8(iframe);
        writeVideo(myVideo, iframe);
        
        disp([num2str(my_framenumber) ' / ' num2str(n_frames*n_augmentations)])
        my_framenumber = my_framenumber + 1;
    end
end

%% write out frames with concatenated barcode
for i = 1:n_frames_2
    
    % read frame
    
    iframe_raw = dip_image(imread(fname_2, i));
    %iframe(iframe>5000) = 5000;
    iframe_raw = 2^8*(iframe_raw)./max(iframe_raw);
    
    % augment data
    for i=1:n_augmentations
        iframe = augmentImage(iframe_raw);
        
        % save the frame
        imwrite(uint8(iframe), [png_stack_path '/Image_' num2str(my_framenumber) '.png'])
        
        
        % eventually expand the frame if size doesn't matchj
        if(max(iframe)< 1080)
            iframe = double(extract((iframe), [1080 1080]));
        end
        
        
        % generate the barcodes for each frame
        mybarcode = d2b(my_framenumber,14);
        mybarcode = imresize(mybarcode, [barcode_width , size(iframe,2)], 'nearest');
        
        
        % concat barcode with frame
        iframe(end-barcode_width+1:end,:) = 2^8.*uint8(mybarcode);
        if(0) frame_i{i}=iframe; end
        
        iframe = uint8(iframe);
        writeVideo(myVideo, iframe);
        
        disp([num2str(my_framenumber) ' / ' num2str(n_frames_2*n_augmentations)])
        my_framenumber = my_framenumber + 1;
    end
    
    
    
end

% add white frames to the video
for i=1:50
    writeVideo(myVideo, uint8(2^8*ones(1080,1080)));
end

%mybarcode = cat(3,frame_i{:});

% close frame-session and write video
close(myVideo);
