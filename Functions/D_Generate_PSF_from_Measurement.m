%% This script generates the training dataset for the fully convolutional 
% neural network by extracting patches with heatmap labels from the 
% ThuderSTORM simulated data.
% derived form the original script from the deepSTORM paper


%% ------------------------------------------------------------------------
%                 Artificial dataset path and settings
%%-------------------------------------------------------------------------

% path to the ThunderSTORM simulated stack of images in tiff format with 
% the accompanying ground truth positions in csv format
datapath = './DataFromOriginalVideo/';
tiff_filename = 'Localizationresult_Made_v2.tif';
csv_filename = 'Localizationresult_Made_v2.csv';


my_filename = strsplit(tiff_filename, '.');
datapath_dest = [datapath my_filename{1} '_combined/']

% mkdir if not exist
if (~exist(datapath_dest, 'dir')); mkdir(datapath_dest ); else disp('already processed'), return; end%if

% upsampling factor for super-resolution reconstruction later on
upsampling_factor = 5;

% simulated camera pixel size in [nm]
camera_pixelsize = 80; 

%% ------------------------------------------------------------------------
%              Extract patches and generate matching heatmaps
%%-------------------------------------------------------------------------

% gaussian kernel standard deviation [pixels]
gaussian_sigma = 3;

% read the artificial acquisition stack
ImageStack = ReadStackFromTiff(tiff_filename);

% dimensions of acquired images
[M,N,numImages] = size(ImageStack);

% dimensions of the high-res grid
Mhr = upsampling_factor*M;
Nhr = upsampling_factor*N;

% create the high resolution grid with the appropriate pixel size
patch_size_hr = camera_pixelsize/upsampling_factor; % nm

% import all positions from ground truth csv
Activations = importdata(fullfile(datapath,csv_filename));
Data = Activations.data;
col_names = Activations.colheaders;

% check that user didn't take out columns when saving from ThunderSTORM
if length(col_names) < 8
    error('Number of columns in the ThunderSTORM csv file is less than 8!');
end 

%% run over all frames and construct the training examples
% heatmap psf
psfHeatmap = fspecial('gauss',[9 9],gaussian_sigma);


for frmNum=1:numImages
    %%
    % cast tiff frame to double 
    y = double(ImageStack(:,:,frmNum));
    
    % upsample the frame by the upsampling_factor using a nearest neighbor
    yus = double(resample(y,upsampling_factor,0,'nn')); % imresize(y,upsampling_factor,'box');  
    
    % read all the provided high-resolution locations for current frame
    DataFrame = Data(Data(:,2)==frmNum,:);
       
    % get the approximated locations according to the high-res grid pixel size
    Chr_emitters = max(min(round(DataFrame(:,3)/patch_size_hr),Nhr),1);
    Rhr_emitters = max(min(round(DataFrame(:,4)/patch_size_hr),Mhr),1);
    
    % find the linear indices of the GT emitters
    indEmitters = sub2ind([Mhr,Nhr],Rhr_emitters,Chr_emitters);
    
    % get the labels per frame in spikes and heatmaps
    SpikesImage = zeros(Mhr,Nhr);
    SpikesImage(indEmitters) = 1;
    HeatmapImage = double(gaussf(SpikesImage, gaussian_sigma));
    
    % normalize the images to min/max
    yus = 2^8*yus./max(max(yus));
    HeatmapImage = 2^8*HeatmapImage./max(max(HeatmapImage));
    
    % concat images and reduce size
    resultmap = (horzcat(yus, HeatmapImage));

    %% write the images
    imwrite(uint8(resultmap), [datapath_dest 'Image_' num2str(frmNum) '.png'])
    disp([num2str(frmNum) ' / ' num2str(k) ' / ' num2str(numImages)])
end
