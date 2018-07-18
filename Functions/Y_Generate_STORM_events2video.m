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
    iframe_a = intensitymap.*dip_image(rand(isize, isize)>0.9999);
    ibackground = gaussf(rand(isize, isize)>0.99, 11);
    
    iframe_psf = gaussf(iframe_a, ipsfsize);
    iframe_b = iframe_psf;%+ibackground*0.005;
    
    
    % augment data to vary psf size and position 
    zoom_min = 0.5;
    zoom_max = 2.;
    zoom = (zoom_max-zoom_min).*rand(1) + zoom_min;
    %zoom = 1+(.1*rand(1)-.05);
    translation = round(128*(rand(1,2)))-64;
    angle = (rand*360);
    
    
    if(zoom<1) % if zoom greater 1 -> pad it with coppies
        iframe_a_rep = repmat(iframe_a, [3 3]);
        iframe_b_rep = repmat(iframe_b, [3 3]);
        
        iframe_a_i = affine_trans(iframe_a_rep, zoom, translation, angle);
        iframe_b_i = affine_trans(iframe_b_rep, zoom, translation, angle);
        
        
        iframe_a_i = extract(iframe_a_i, [256 256]);
        iframe_b_i = extract(iframe_b_i, [256 256]);
    else
        
        iframe_a_i = affine_trans(iframe_a, zoom, translation, angle);
        iframe_b_i = affine_trans(iframe_b, zoom, translation, angle);
    end
    
    
    % weigh the intensity of the slice according to the focus position 
    % high zoom value means out of focus, thus less intensity
    intensity_factor = (((zoom_min - zoom_max))*zoom+ (zoom_min + zoom_max)).^(2);
    
    
    
    frame_result_i{i} = intensity_factor * iframe_b_i;
    iframe_i{i} = intensity_factor  * iframe_a_i;
    
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
    result_gt_final{i} = sum(result_gt(:,:,rand_v)), 3);
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
fname = 'testSTORM_random_psf_v5';
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
fname = 'testSTORM_random_gt_v5';
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
save('testSTORM_random_v5')

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
