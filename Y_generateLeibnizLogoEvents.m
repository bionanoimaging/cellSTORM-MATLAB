

% Load LeibnizLogo and generate blinking events after the edges of the
% image were detecte 
testimage = dip_image(edge(rgb2gray(uint8(readim('/Users/Bene/Downloads/Download.png')))));
testimage(0:160, 135:end) = 0;
testimage = extract(testimage, [256, 256]);
size(testimage);
[rows,cols] = find(flip(double(testimage)));
scatter(cols, rows, '.');


%% define parameter
isize = 256;
ipsfsize = 1.5;
n_frames = 2000;

frame_result_i = {};
iframe_i = {};
%%
for i = 1:n_frames
    %% generate frame
    intensitymap = gaussf(rand(isize, isize)>0.95, 7);
    iframe_a = testimage.*intensitymap.*dip_image(rand(isize, isize)>0.999);
    ibackground = gaussf(rand(isize, isize)>0.99, 11);
    
    ipsfsize = 2*(rand(1,1)+.5);
    iframe_psf = gaussf(iframe_a, ipsfsize);
    iframe_b = iframe_psf;%+ibackground*0.005;
    
   
    frame_result_i{i} = intensity_factor * iframe_b;
    iframe_i{i} = intensity_factor  * iframe_a;
    
    disp([num2str(i) ' / ' num2str(n_frames) ' / zoom: ' num2str(zoom) ' intensity factor: ' num2str(intensity_factor)])
    
    
    if(0), cat(3, iframe_a_i, iframe_b_i), end
end




%% max
result_psf = double(cat(3, frame_result_i{:}));
result_gt = double(cat(3, iframe_i{:}));


result_psf_final = {};
result_gt_final = {};

n_combination = 8; % number of frames to combine with
for i=1:n_frames
    %% combine different emitter sizes
    rand_v = randi([1 n_frames],1,n_combination );
    result_psf_final{i} = sum(result_psf(:,:,rand_v), 3);
    result_gt_final{i} = sum(result_gt(:,:,rand_v), 3);
    disp([num2str(i) ' / ' num2str(n_frames) ' / zoom: ' num2str(zoom)]);
end

result_psf_final = dip_image(cat(3, result_psf_final{:}));
result_gt_final = dip_image(cat(3, result_gt_final{:}));

% normalize 
result_psf_final = result_psf_final/max(result_psf_final,[],[1,2])
result_gt_final = result_gt_final/max(result_gt_final,[],[1,2]);


%%
%cat(4, result, result_gt);

%% save images to png
%load(mat_stack, 'result_psf', 'result_gt')
fpath = './';
fname = 'LeibnizEvents_psf';
fpath_dest = './';
fpath_dest = [fpath_dest fname];
result_psf_mat = uint8(result_psf_final*2^8);

% mkdir if not exist
if (~exist(fpath_dest, 'dir')); mkdir(fpath_dest ); end%if


% write out png series
for i = 1 : size(result_psf, 3)
    
    % write image
    imwrite((result_psf_mat(:,:,i)), [fpath_dest '/Image_' num2str(i) '.png']);%,  'Compression','none');
    
    disp([num2str(i) ' / ' num2str(n_frames)])
end


%% save images to png
fpath = './';
fname = 'LeibnizEvents_gt';
fpath_dest = './';
fpath_dest = [fpath_dest fname];
result_gt_mat = uint8(result_gt_final*2^8);
% mkdir if not exist
if (~exist(fpath_dest, 'dir')); mkdir(fpath_dest ); end%if

% write out png series
for i = 1 : size(result_psf, 3)
    
    % write image
    imwrite((result_gt_mat(:,:,i)), [fpath_dest '/Image_' num2str(i) '.png']);%,  'Compression','none');
    
    disp([num2str(i) ' / ' num2str(n_frames)])
end

%%
save('LeibnizEvents')

return;
%% save images PSF
outputFileName = 'testSTORM_random_psf_v2.tif'
for K=0:length(result_psf(1, 1, :))-1
    imwrite((uint8(result_psf(:, :, K)*256)), outputFileName, 'WriteMode', 'append');
    disp([num2str(K) ' / ' num2str(n_frames)])
end

%% save images PSF
outputFileName = 'testSTORM_random_psf_v2.tif'
for K=0:length(result_psf(1, 1, :))-1
    imwrite((uint8(result_psf(:, :, K)*256)), outputFileName, 'WriteMode', 'append');
    disp([num2str(K) ' / ' num2str(n_frames)])
end

%% save images GT
outputFileName = 'testSTORM_random_gt_v2.tif'
for K=0:length(result_gt(1, 1, :))-1
    imwrite((uint8(result_gt(:, :, K)*256)), outputFileName, 'WriteMode', 'append');
    disp([num2str(K) ' / ' num2str(n_frames)])
end


save('testSTORM_random')

