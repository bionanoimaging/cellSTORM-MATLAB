myfilepath_processed = '/home/useradmin/Dropbox/Dokumente/Promotion/PROJECTS/STORM/DATASET_NN/06_testSTORM_FIJI_Experiment/'; %ISO_12800/extractedFrames2018-02-01_13.03.21_ISO12800_Texp_1_30_FIJI_EXPERIMENT_processed/images/';
myfilepath_processed = [uigetdir(myfilepath_processed) '/images/'];


%% READ the groundtruth and captured data data
srcFiles = dir([myfilepath_processed '*outputs.png']);  % the folder in which ur images exists
iframe = {};
for i = 1 : length(srcFiles)
    filename = strcat(myfilepath_processed,srcFiles(i).name);
    iframe{i}  = imread(filename);
    disp(i)
end
iframes_hw_processed = cat(3, iframe{:});

% ok, we don't want to do anything more than saving..
writeim(iframes_hw_processed, 'iframes_hw_processed.tiff', 'TIFF')


%% READ the groundtruth and captured data data
srcFiles = dir([myfilepath_processed '*inputs.png']);  % the folder in which ur images exists
iframe = {};
for i = 1 : length(srcFiles)
    filename = strcat(myfilepath_processed,srcFiles(i).name);
    iframe{i}  = imread(filename);
    disp(i)
end
iframes_hw_unprocessed = cat(3, iframe{:});

% ok, we don't want to do anything more than saving..
writeim(iframes_hw_unprocessed, 'iframes_hw_unprocessed.tiff', 'TIFF')





%% 
load('../MEASUREMENTS/FIJI_Experiment_Dim256_Numbera256_params.mat')
blinking_positions = (cell2mat(patterns.struct_coords))
Img = zeros(256,256);
blinking_positions = blinking_positions(1:2,:);
blinking_positions = blinking_positions-min(min(blinking_positions));
blinking_positions = blinking_positions./max(max(blinking_positions))*(256-1);
blinking_positions = blinking_positions+1;
blinking_positions = int32(blinking_positions);
Img(sub2ind(size(Img), blinking_positions(1,:), blinking_positions(2, :))) = 1;
result_testSTORM = gaussf(dip_image(Img), 1);
%result_testSTORM = result_testSTORM(512:512+256, 512:512+256);
figure
imagesc(double(result_testSTORM));
colormap gray
axis image
result_testSTORM = result_testSTORM - min(result_testSTORM);
result_testSTORM = result_testSTORM./max(result_testSTORM);
result_testSTORM = result_testSTORM*255;

writeim(uint8(result_testSTORM), '/home/useradmin/Dropbox/Dokumente/Promotion/PROJECTS/STORM/DATASET_NN/06_testSTORM_FIJI_Experiment/iframes_result_testSTORM.tiff', 'TIFF')


%% 
load('/Users/bene/Dropbox/Dokumente/Promotion/PROJECTS/STORM/MEASUREMENTS/testSTORM_lines_256_256_params.mat')
blinking_positions = (cell2mat(patterns.struct_coords{:}));
blinking_positions = labels.init_cont_coords{1};
blinking_positions = blinking_positions(1:2,:);
Img = zeros(256,256);
blinking_positions = blinking_positions(1:2,:);
blinking_positions = blinking_positions-min(min(blinking_positions));
blinking_positions = blinking_positions./max(max(blinking_positions))*(256-1);
blinking_positions = blinking_positions+1;
blinking_positions = (blinking_positions);
Img(sub2ind(size(Img), blinking_positions(1,:), blinking_positions(2, :))) = 1;
result_testSTORM = gaussf(dip_image(Img), 1);
%result_testSTORM = result_testSTORM(512:512+256, 512:512+256);
figure
imagesc(double(result_testSTORM));
colormap gray
axis image
result_testSTORM = result_testSTORM - min(result_testSTORM);
result_testSTORM = result_testSTORM./max(result_testSTORM);
result_testSTORM = result_testSTORM*255;

writeim(uint8(result_testSTORM), '/home/useradmin/Dropbox/Dokumente/Promotion/PROJECTS/STORM/DATASET_NN/06_testSTORM_FIJI_Experiment/iframes_result_testSTORM.tiff', 'TIFF')




