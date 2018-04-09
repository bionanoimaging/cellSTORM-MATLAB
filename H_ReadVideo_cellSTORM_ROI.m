% Read a video and extract a ROI selected by the user
% export it as a TIFF stack for processing with rapidSTORM or ThunderSTORM


filedir = '../MEASUREMENTS/';
filename = '2018_01_19_17_20_29_ISO3200_10xEyepiece_1.mp4';

filename = [filedir filename];


%% Define Videoreader
% Construct a multimedia reader object associated with file 'xylophone.mpg' with
% user tag set to 'myreader1'.
readerobj = VideoReader(filename, 'tag', 'myreader1');
absNumFrames = readerobj.Duration*readerobj.FrameRate;


% read the frames
iframe = uint8(squeeze(mean(read(readerobj, 1), 3)));

%% get the ROI coordinates
AH=dipshow(dip_image(iframe))
diptruesize(AH,100)
fprintf('Get the ROI coordinates')
fprintf('1. Click the center of the Hologram \n');
fprintf('2. Click the outer rim of the roi you wanna extract\n ')
roi_coordinates = dipgetcoords(AH,2);
fprintf('Thank you for selecting the ROI! Data will be processed now!\n')

roi_center = [roi_coordinates(1, 1) roi_coordinates(1,2)]; % StartX, StartY

difX = abs(roi_coordinates(1)-roi_coordinates(2));
difY = abs(roi_coordinates(3)-roi_coordinates(4));
roi_size = max(difX, difY); %size of the Box
roi_size = 2*[roi_size roi_size];

iframe_roi = extract(dip_image(iframe), roi_size, roi_center)
disp('ROI has been extracted')


%% READ all FRAMES and save as TIFF
istart = 100;
nFrames = 2000;
iframes = {nFrames-istart};
for k = istart:nFrames
    
    % read the frames
    iframe = uint8(squeeze(mean(read(readerobj, k), 3)));
    iframes{k} = extract(dip_image(iframe), roi_size, roi_center);
    
    disp([ num2str(k) ' / ' num2str(nFrames-istart)])
end

iframes_mat = uint8(cat(3, iframes{istart:nFrames}));

% Save images 
outputFileName = [filedir filename '.tiff']
for K=1:length(iframes_mat(1, 1, :))
   imwrite(iframes_mat(:,:, K), outputFileName, 'WriteMode', 'append');
end
