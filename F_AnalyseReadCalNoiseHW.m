% read HUAWEI P9 video and analyse the noise behaviour
filedir = './READCALNOISE/';
filename_in = 'Brighframe_ISO12800_AE20_texp_1_30s.mp4'; filename_in= [filedir filename_in];
filename_in = 'MOV_2018_01_18_13_57_21.mp4'; filename_in= [filedir filename_in];
filename_bg = 'Darkframe_ISO12800_AE20_texp_1_30s.mp4'; filename_bg= [filedir filename_bg];

%% read input images
readerobj_in = VideoReader(filename_in, 'tag', 'myreader1');
absNumFrames_in = readerobj_in.Duration*readerobj_in.FrameRate;

absNumFrames_in = get(readerobj_in, 'numberOfFrames');

% read all frames of the video into a cell-array
iframes_in = cell(absNumFrames_in,1);
for i=1:333
    temp = dip_image(read(readerobj_in, i));
    iframes_in{i} = squeeze(temp(:,:,1));
    
end
allFrames_in = cat(3, iframes_in{:});
disp('Succesfully read the input images')

%% read bg images
readerobj_bg = VideoReader(filename_bg, 'tag', 'myreader1');
absNumFrames_bg = get(readerobj_bg, 'numberOfFrames'); 

% read all frames of the video into a cell-array
iframes_bg = cell(absNumFrames_bg,1);
for i=1:100
    temp = dip_image(read(readerobj_bg, i));
    iframes_bg{i} = squeeze(temp(:,:,1));
end
allFrames_bg = cat(3, iframes_bg{1:100});
disp('Succesfully read the background images')

%save([filedir '/Darkframe_ISO3200_AE20_texp_1_30s'], 'allFrames_bg', 'allFrames_in')

return
% use read call noise
disp('Start calculating the noise model')
cal_readnoise(allFrames_in, allFrames_bg)




%% Ronny wanna try some stuff

if 1 
    mymean = mean(allFrames_in, [], [3]);
    myvar = var(allFrames_in, [], [3]);
    mygain = myvar ./ mymean %or vic versa
    
end