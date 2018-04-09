% read HUAWEI P9 video and analyse the noise behaviour
filedir = '.\';
filename_in = 'Brighframe_ISO12800_AE20_texp_1_30s.mp4'; filename_in= [filedir filename_in];
filename_in = 'Brighframe_ISO3200_AE0_AE_block_2.mp4'; filename_in= [filedir filename_in];
filename_bg = 'Darkframe_ISO12800_AE20_texp_1_30s.mp4'; filename_bg= [filedir filename_bg];

filename_in = 'MOV_2018_01_27_10_24_29.mp4'

%% read input images
readerobj_in = VideoReader(filename_in, 'tag', 'myreader1');
absNumFrames_in = get(readerobj_in, 'numberOfFrames');

disp(['framerate: ' num2str(readerobj_in.FrameRate)])
disp(['duration: ' num2str(readerobj_in.Duration)])



%% read all frames of the video into a cell-array
iframes_in = cell(absNumFrames_in,1);
hist_i={};
iter = 1;
j=1:25:absNumFrames_in;
n_bins = 35;
hist_i = zeros(length(j), n_bins);
noise_i = zeros(1, length(j));


for i = j
    try
        temp = (read(readerobj_in, i));
        h = histogram(temp(:), n_bins);
        hist_i(iter, :) = h.Values;
        noise_i(iter) = noisestd(temp,[],0);

    catch
        disp('error')
    end
    disp([num2str(iter) '/' num2str(i) '/' num2str(absNumFrames_in)])
    iter = iter + 1;
end
figure
xbin = linspace(1, (readerobj_in.Duration), length(noise_i))
plot(xbin/60 , noise_i)
xlabel('time')
ylabel('stdv')

figure
imagesc(hist_i)

return

mymean_z = squeeze(mean(allFrames_in, [], [1 2]));
mytime = linspace(0,readerobj_in.Duration,absNumFrames_in);

plot(mytime,mymean_z)

