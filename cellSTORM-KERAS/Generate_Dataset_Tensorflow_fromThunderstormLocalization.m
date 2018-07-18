%% Script to produce patches for cellSTORM
% Inpsired and derived from DEEP-STORM (Nehme et al.)
clear all
clc
close all

if(~exist('filename_CSV'))
    %% Initialize variables.
    [filename_CSV, filedir_CSV] = uigetfile('.csv'); %'MOV_2018_03_13_17_16_35_ISO6400_texp_1_15_TIRF_v2_smallresult_realA';
    filepath_CSV = [filedir_CSV filename_CSV];
    delimiter = ',';
    mat_filename = [filename_CSV '.mat'];
    
    % define input and output folder
    [filename_TIF, filedir_TIF] = uigetfile('.tif'); %'MOV_2018_03_13_17_16_35_ISO6400_texp_1_15_TIRF_v2_smallresult_realA';
    filepath_TIF = [filedir_TIF filename_TIF]
    
    %% define folder for the image-pairs
    % mkdir if not exist
    filedir_dest = ['./images/' filename_TIF '_bilinear_smallpatch/'];
    if (~exist(filedir_dest, 'dir')); mkdir(filedir_dest ); end%if
end





%% Stack parameters
%% read tiff-stack
% parameters set in ThunderSTORM:
% photoelectron: 1
%
% FHWM: 200-350 nm, Intensity 700-1000, Background 0
% pixelsize: 80nm
% density of emitters: 3 1/µmm^2
%
% if debug => visualize some stuff
debug = 0;


max_intensity = 10001; % +1 => avoid saturation of the pixels
numphotons = 3500; % number of photons for current dataset generation

% simulated camera pixel size in [nm]
camera_pixelsize = 80;

% gaussian kernel standard deviation [pixels]
gaussian_sigma = 2;

% upsampling factor for super-resolution reconstruction later on
upsampling_factor = 4;

% sample from real experimental data?
if strcmp(questdlg(['Is ' filename_CSV ' a synthetic dataset?'], 'Userinput'), 'Yes')
    is_experimental = false;
else
    is_experimental = true;
end

% save as a mat file?
if strcmp(questdlg(['Do you want to export the data as H5?'], 'Userinput'), 'Yes')
    save_mat = true;
else
    save_mat = false;
end



% how many emitters per frame should be detected?
min_num_emitters = 5

% patchsizse for training samples:
training_patchsize = 256;

%% ------------------------------------------------------------------------
%              Extract patches and generate matching heatmaps
%%-------------------------------------------------------------------------


% read the artificial acquisition stack
ImageStack = ReadStackFromTiff(filepath_TIF);

% dimensions of acquired images
[M,N,numImages] = size(ImageStack);

% dimensions of the high-res grid
Mhr = upsampling_factor*M;
Nhr = upsampling_factor*N;


% create the high resolution grid with the appropriate pixel size
patch_size_hr = camera_pixelsize/upsampling_factor; % nm

% import all positions from ground truth csv
Activations = importdata(filepath_CSV);
Data = Activations.data;
col_names = Activations.colheaders;

% check that user didn't take out columns when saving from ThunderSTORM
if length(col_names) < 7
    error('Number of columns in the ThunderSTORM csv file is less than 8!');
end

%% Create output variable
eventslocalization = table;
eventslocalization.frame = Data(:,2);
eventslocalization.xnm = Data(:,3);
eventslocalization.ynm = Data(:,4);
eventslocalization.intensityphoton = Data(:,5);

%% place the events in each frame
nframes = size(ImageStack,3);
mysize = size(ImageStack,[1]);

if(~is_experimental)
    % define camera parameters (from HUAWEI P9 measurements at ISO3200)
    gain = .41;
    pixeloffset = 4.074;
    myreadnoise = 1.23; % in e- rms
    
    % define Video settings
    extension_video = '.mp4';
    
    
    % define Video compression and codec
    vcompression = 50; % don't go bellow 50%
    vcodec = 'H.264';
    
    %% Create Video-writer for MP4 simulation
    vname = ['temp' extension_video ];
    myVideo = VideoWriter(vname, 'MPEG-4');%'Grayscale AVI');%,'Uncompressed AVI');
    %myVideo.FrameRate = 30;  % Default 30
    %myVideo.CompressionRatio = 1;
    myVideo.Quality = vcompression;
    %myVideo.VideoCompressionMethod = vcodec;
    %myVideo.LosslessCompression = True;
    
    % open the video
    open(myVideo)
    
    
    for frmNum = 1:1000%nframes
        % cast tiff frame to double
        iframe = dip_image(ImageStack(:,:,frmNum));
        iframe = iframe./max_intensity;
        iframe = iframe.*numphotons;
        
        % apply photon noise (poisson)
        sensorOut_e = noise(iframe, 'Poisson', gain);
        %sensorOut_e = poissrnd(5.2,10,10);  %units are e- - NO
        %DIPIMAGE!
        
        % add readNoise according to camera measurements
        readNoise_e = randn([mysize mysize]) * myreadnoise; %units are e- rms
        
        % sum signal and quantize
        y = uint8((sensorOut_e + readNoise_e)) + pixeloffset;   %units DN
        
        
        if(0)
            % apply demosaicing using nearest neighbours (optional)
            image_DN_demosaic = uint8(mean(demosaicing(image_DN), 3));
            writeVideo(myVideo, image_DN_demosaic);
        else
            writeVideo(myVideo, y);
        end
        
        disp([num2str(frmNum) ' / ' num2str(nframes)])
    end
    
    % Close video to start new iteration
    close(myVideo);
    
    
    %% Read in video frames, upsample and concat to groundtruth spikes
    % re-read the video and save it as A-to-B pairs
    
    % create video writer object
    videoObj = VideoReader(vname);
    nframes = get(videoObj, 'numberOfFrames');
end
% read all frams
% heatmap psf
psfHeatmap = (fspecial('gauss',[7*upsampling_factor 7*upsampling_factor],gaussian_sigma*2));

% preallocate memory
allHeatMaps = {};
allSpikes = {};
allMeasurements = {};

% init variabl
iterindex = 1;
stack = {};


for(frmNum = 1:nframes)
    
    %% create GT lolaization frame
    % read all the provided high-resolution locations for current frame
    % comes in the format:
    % ID | Frame# | xPos | yPos | Sigma | Intensity | offset | bkgstd
    DataFrame = Data(Data(:,2)==frmNum,:);
    
    
    if(~is_experimental)
        %% read video-frame
        y_video = squeeze(mean(read(videoObj, frmNum), 3));
        
        % upsample the frame by the upsampling_factor using a nearest neighbor
        iframe_video = imresize(y_video,upsampling_factor,'bicubic'); % imresize(y,upsampling_factor,'box');
    end
    
    % get the approximated locations according to the high-res grid pixel size
    correction_offset = 0*[25 25 ]; % this shifts the coordintes better together - depending on upsampling factor
    Chr_emitters = max(min(round((DataFrame(:,3)+correction_offset(1))/patch_size_hr),Nhr),1);
    Rhr_emitters = max( min(round((DataFrame(:,4)+correction_offset(2))/patch_size_hr),Mhr),1);
    
    % find the linear indices of the GT emitters
    indEmitters = sub2ind([Mhr,Nhr],Rhr_emitters,Chr_emitters);
    
    % get the labels per frame in spikes and heatmaps
    SpikesImage = zeros(Mhr,Nhr);
    SpikesImage(indEmitters) = 1;
    
    %iframe_gt = gaussf(SpikesImage, gauss);
    iframe_gt = conv2(SpikesImage,psfHeatmap,'same');
    iframe_gt = 2^7*iframe_gt./max(max(iframe_gt));
    
    % sanity check
    if(0), dip_image(cat(3, SpikesImage, iframe_gt, iframe_video, mygt_loc_psf, resample(ImageStack(:,:,frmNum),upsampling_factor,0,'nn'))), end
    if(0), dip_image(cat(3, iframe_gt, iframe_video)), end
    
    %% Divide image into patches and save it
    
    patchnum_m = 1:(round(size(iframe_gt,1))/training_patchsize)-1;
    patchnum_n = 1:(round(size(iframe_gt,2))/training_patchsize)-1;
    
    if(is_experimental)
        % get frame from thunderstorm
        iframe_gt_ts = double(ImageStack(:,:,frmNum));
        iframe_gt_ts = iframe_gt_ts./max_intensity;
        iframe_gt_ts = iframe_gt_ts.*numphotons;
        iframe_gt_ts = (imresize(iframe_gt_ts,upsampling_factor,'bilinear'));
        iframe_video = iframe_gt_ts;
    end
    
    
    for im = patchnum_m
        for in = patchnum_n
            % divide into patches
            iframe_gt_patch = iframe_gt(im*training_patchsize:(im+1)*training_patchsize-1, in*training_patchsize:(in+1)*training_patchsize-1);
            iframe_video_patch = iframe_video(im*training_patchsize:(im+1)*training_patchsize-1, in*training_patchsize:(in+1)*training_patchsize-1);
            spike_patch = SpikesImage(im*training_patchsize:(im+1)*training_patchsize-1, in*training_patchsize:(in+1)*training_patchsize-1);
            % iframe_gt_ts_patch = iframe_gt_ts(im*training_patchsize:(im+1)*training_patchsize-1, in*training_patchsize:(in+1)*training_patchsize-1);
            
            % check if enough emitters == enough intensity
            if(sum(spike_patch(:))>min_num_emitters) % only proceed if frames has more than 7 events
                
                if(save_mat)
                    % store all patches
                    allHeatMaps{iterindex} = iframe_gt_patch;
                    allSpikes{iterindex} = spike_patch;
                    allMeasurements{iterindex} =  iframe_video_patch;
               
                else
                    % produce stacked images
                    
                    iframe = 2*horzcat(iframe_video_patch, iframe_gt_patch, spike_patch*2^7);
                    if(debug), dip_image(cat(3, iframe_video_patch, iframe_gt_patch, spike_patch*2^7)), end
                    % write image
                    if(0)
                        imwrite(uint8(iframe), [filedir_dest '/Image' filename_TIF '.tif'], 'WriteMode', 'append');%,
                    else
                        imwrite(uint8(iframe), [filedir_dest '/Image' filename_TIF '_' num2str(iterindex) '.png']);%,
                    end
                    %'Compression','none');
                end
                
                iterindex = iterindex + 1;
                
            else
                disp('Not enough emitters found in the image-patch')
            end
            
            
        end
        
        
    end
    
    
    %    stack{frmNum} = cat(3, iframe_video_patch, iframe_gt_patch, iframe_gt_ts_patch);
    
    
    disp([num2str(frmNum) '/ ' num2str(nframes)])
end


% delete temp-video
try
delete(vname)
catch
    disp('Probably no video to delete..?')
end


%% cast it to a matrix and save it
heatmaps = cat(3, allHeatMaps{:});
spikes = cat(3, allSpikes{:});
patches = cat(3, allMeasurements{:});
 
 
% visualize pair
if(debug), dip_image(cat(4,heatmaps(:,:,1), spikes(:,:,1), patches(:,:,1))), end
 
 
% save training dataset to a mat file
%save(fullfile('./',mat_filename),'patches','heatmaps','spikes','-v7.3');
 
% save training dataset to a mat file
mat_filename = [filename_CSV '.h5'];
save(fullfile('./images/',mat_filename), 'heatmaps', 'patches', 'spikes','-v7.3');



% see the effect of the MP4 codec:
mean(dip_image(patches), [], [3])

