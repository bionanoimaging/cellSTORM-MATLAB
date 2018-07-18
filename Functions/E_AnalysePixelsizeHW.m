% read HUAWEI P9 video and export mean over sequence 
filename = './HW_calibration/HW_1_33s_12800ISO.mp4';

readerobj = VideoReader(filename, 'tag', 'myreader1');
absNumFrames = readerobj.Duration*readerobj.FrameRate;

absNumFrames = get(readerobj, 'numberOfFrames');

iframes = {};
for i=1:10
    iframes{i} = dip_image(read(readerobj, i));
end


aa = mean(cat(3, iframes{:}), [],[3]);

filename_tif = './HW_calibration/test.tif';
imwrite(double(aa)/max(max(double(aa))), filename_tif)