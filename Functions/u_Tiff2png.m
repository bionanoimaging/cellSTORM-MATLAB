%Convert the TIFF Stack into the pix2pix readable png files 
fpath = '/Users/bene/Dropbox/';
fname = 'MOV_2018_01_22_17_23_31_2018_01_19_17_20_29_ISO3200_20xEyepiece_1';
fpath_dest = '/Users/bene/Dropbox/';
fpath_dest = [fpath fname '/test'];
myfname = [fpath fname '.tif']

% mkdir if not exist
if (~exist(fpath_dest, 'dir')); mkdir(fpath_dest ); end%if

% create tif file object 
info = imfinfo(myfname);

%AllAllFrames_HWFrames = readtimeseries(fname);
n_frames = size(info,1)

isize = 256;   isize = isize/2;
icentre = 256;

%%
for i = 1:n_frames
    
    %% read frame
    iframe = imread(myfname, i);
    %iframe = iframe(icentre-isize:icentre+isize, icentre-isize:icentre+isize);
    
    % write frame 
    imwrite(uint8(horzcat(iframe, iframe*0)), [fpath_dest '/Image_' num2str(i) '.png']);
    
    
    disp([num2str(i) ' / ' num2str(n_frames)])
end
