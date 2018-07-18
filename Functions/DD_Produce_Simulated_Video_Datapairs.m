% specify the folder where the A to B paris are placed

% define input and output folder
filename_TIF = 'Artificial_dataset_GT';
filedir_TIF = './DataFromOriginalVideo/'
filedir_dest = [filedir_TIF filename_TIF '_VIDEO_GENERATED/train'];
fname = [filedir_TIF filename_TIF '.tif'];
ispng = true;
background_level = 0;

% mkdir if not exist
if (~exist(filedir_dest, 'dir')); mkdir(filedir_dest ); end%if


extension_video = '.mp4';
vname = [filename_TIF extension_video];
vname = [filedir_TIF 'Artificial_Dataset2_GT_Noised_converted.m4v'];


if(1)
    % create video writer object
    myVideo = VideoWriter(vname, 'MPEG-4');%'Grayscale AVI');%,'Uncompressed AVI');
    myVideo.FrameRate = 3;  % Default 30
    %myVideo.CompressionRatio = 1;
    myVideo.Quality = 10;
    myVideoCompressionMethod = 'H.264';
    %myVideo.LosslessCompression = True;
    
    
    open(myVideo)
    
    %% read tiff-stack
    % create tif file object
    tif_info = imfinfo(fname);
    n_frames = size(tif_info,1);
     
    i = 1;
    
    iframe = imread(fname, i)-background_level ;
    mysize = size(iframe);
    gain = .34;
    poisson_par = 2;
    pixeloffset = 4.074;
    mybackground = 15;
    
    %% apply camera statistics
    for i = 1:n_frames
        %% apply camera statistics
        iframe = dip_image(double(imread(fname, i)-background_level)) ;
        iframe = iframe - min(iframe)+mybackground;
        iframe = 0.4*iframe/max(iframe);
        
        % eventually normalize and quantize
        iframe = uint8(2^8*iframe);
        
        % also make it a bit darker
        sensorOut_e = noise(iframe, 'Poisson', poisson_par);
        readNoise_e = randn(mysize) * 1.23 * 4; %units are e- rms
        %sensorOut_e = poissrnd(5.2,10,10);  %units are e-
        image_DN = uint8((sensorOut_e + abs(readNoise_e)) * gain) + pixeloffset;   %units DN
        image_DN_demosaic = uint8(mean(demosaicing(image_DN), 3)); 
        
        
        writeVideo(myVideo, image_DN_demosaic);
        
        
        disp([num2str(i) '/ ' num2str(n_frames)])
    end
    
    close(myVideo);
end

%% re-read the video and save it as A-to-B pairs

% create video writer object
videoObj = VideoReader(vname);
n_frames = get(videoObj, 'numberOfFrames');


%% apply camera statistics
for(i = 1:n_frames)
    
    % read video-frame
    iframe_video = squeeze(mean(read(videoObj, i), 3));
    
    % read tiff-frame
    iframe_tif = imread(fname, i)-background_level;
    % eventually normalize
    iframe_tif = uint8(2^8*double(iframe_tif)./double(max(max(1.*iframe_tif))));
    
    
    % produce stacked images
    iframe = horzcat(iframe_video, iframe_tif);
    
    if(ispng)
        % write out the images
        imwrite(uint8(iframe), [filedir_dest '/Image_' filename_TIF '_' num2str(i) '.png'])
        
    else
        % write image
        imwrite(uint8(iframe), [filedir_dest '/Image_' filename_TIF '.png'], 'WriteMode', 'append');%,  'Compression','none');
        
        
    end
    
    disp([num2str(i) '/ ' num2str(n_frames)])
end

%% visualize pair
(dip_image(cat(3, iframe_tif, iframe_video)))
dip_image(iframe)








