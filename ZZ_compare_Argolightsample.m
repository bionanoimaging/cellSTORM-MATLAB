foldername = '/Users/bene/Dropbox/Dokumente/Promotion/PROJECTS/STORM/MATLAB/HW_Calibration/ArgolightSIM-Test_RAW_Video/'
filename_video = 'MOV_2018_03_16_11_59_37.mp4'
filename_raw = 'RAW_2018_03_16_11_53_32_638_ExpTime_1_8_ISOVal_3200.dng'

n_videoframe = 22;

%% read video frame 
readerobj = VideoReader([foldername filename_video], 'tag', 'myreader1');

% Read in all video frames.
videoFrame = rgb2gray(read(readerobj, n_videoframe));
videoFrame = dip_image(videoFrame);


%% read RAW frame
rawFrame = readim([foldername filename_raw])


size_raw = size(rawFrame)
size_video = size(videoFrame)
size_ratio = size_raw./size_video

%% make them square
rawFrame_square = extract(rawFrame, [min(size_raw), min(size_raw)]);
videoFrame_square = extract(videoFrame, [min(size_video), min(size_video)]);

size_raw = size(rawFrame_square);
size_video = size(videoFrame_square);
size_ratio = size_raw./size_video;

cat(3, resample(videoFrame_square, size_ratio), rawFrame_square)

