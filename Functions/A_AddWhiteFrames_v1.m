% Prepare the Tif-stacks as video
% file reads a file generated with testSTORM as multitiff and prepares it
% for the display on a second cellphone
% first: white layers for perspective calibration will be added
% second: a barcode for encoding the framenumber is encoded 
tif_stack = '1000Emitters';
%tif_stack = '800Emitters';
extension_stack = '.tif';
extension_video = '.avi';
fname = [tif_stack extension_stack];
vname = [tif_stack extension_video];

% create video writer object
myVideo = VideoWriter(vname, 'Uncompressed AVI');%,'Uncompressed AVI');
myVideo.FrameRate = 5;  % Default 30
%myVideo.CompressionRatio = 1;
myVideo.Quality = 100;
myVideoCompressionMethod = 'None';
%myVideo.LosslessCompression = True;
open(myVideo);

% create tif file object 
info = imfinfo(fname);

%AllAllFrames_HWFrames = readtimeseries(fname);
n_frames = size(info,1);

frame_i = {};
iframe = imread(fname, i);

% add white frames to the video
for i=1:50
    writeVideo(myVideo, double( ones(1080,1080)));
end
% barcode size define
barcode_width = 20;

% add white frames to the video
for i=1:10
    
    iframe = zeros(1080,1080);
    % generate the barcodes for each frame
    mybarcode = de2bi(6666,14);
    mybarcode = imresize(mybarcode, [barcode_width , size(iframe,2)],'nearest');
    
    % concat barcode with frame
    iframe(end-barcode_width+1:end,:)=double(mybarcode);
    
    writeVideo(myVideo, double(iframe/max(max(iframe))));
end


for i = 1:n_frames
    
    % read frame
    iframe = imread(fname, i);
    
    % calculate the max pixel values along the time-series 
    maxIntensityVal = max(max(iframe));
    
    % generate the barcodes for each frame
    mybarcode = de2bi(i,14);
    mybarcode = imresize(mybarcode, [barcode_width , size(iframe,2)],'nearest');
    
    
    % concat barcode with frame
    iframe(end-barcode_width+1:end,:)=double(maxIntensityVal)*double(mybarcode);
    if(0) frame_i{i}=iframe; end
    
    writeVideo(myVideo, double(iframe/maxIntensityVal));
    
    disp(i)
end

% add white frames to the video
for i=1:50
    writeVideo(myVideo, double(ones(1080,1080)));
end

%mybarcode = cat(3,frame_i{:});

% close frame-session and write video
close(myVideo);
