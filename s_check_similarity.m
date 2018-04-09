% Convert the processed files from the GAN to a stack for fiji
filedir = './MOV_2018_03_02_11_27_56_ISO3200_texp_1_200_RandomBlink_v5testSTORM_random_psf_v5_shifted_combined/train/'
%filedir_mod = '/Users/bene/Downloads/Rot/test/'
%if (~exist(filedir_mod, 'dir')); mkdir(filedir_mod ); end%if

% READ the processed data
srcFiles = dir([filedir '*.png']);  % the folder in which ur images exists


%%
imse = {}
ipsnr = {}
icrossc = {}
ifilename = {};
ilfmse = {}
iter = 1;
for i = 1 : length(srcFiles)
    
    %%
    %i = round(rand(1,1)*length(srcFiles))
    
    filename = strcat(filedir,srcFiles(i).name);
    
    
    iframe  = imread(filename);
    
    iframe_a = dip_image(iframe(:,1:256));
    iframe_a = iframe_a - min(iframe_a);iframen_a = iframe_a/max(iframe_a);
    
    iframe_b = dip_image(iframe(:,257:end));
    iframe_b = iframe_b - min(iframe_b);iframe_b = iframe_b/max(iframe_b);
    
    if(1), cat(3, iframe_a, iframe_b), end
    
    %%
    imse{i} = mse(iframe_a , iframe_b);
    ipsnr{i} = psnr(iframe_a , iframe_b);
    icrossc{i} = mean(crosscorrelation(iframe_a,iframe_b));
    ilfmse{i} = lfmse(iframe_a,iframe_b,[]);
    %iframe_a = extract(iframe_a, [512, 512]);
    %iframe_b = extract(iframe_b, [512, 512]);
    
    %iframe_a = affine_trans(iframe_a, 2, 0, 0);
    %iframe_b = affine_trans(iframe_b, 2, 0, 0);
    
    %iframe = horzcat(iframe_a, iframe_b);
    
    %filename_mod = strcat((filedir_mod), srcFiles(i).name);
    
    
    %imwrite(uint8(iframe), filename_mod);
    
    disp([num2str(i) ' / ' num2str(length(srcFiles))])
    
end

%%
figure
plot(cat(1, ipsnr{:}))
hold on
plot(cat(1, imse{:}))
plot(cat(1, icrossc{:}))
plot(cat(1, ilfmse{:}))
hold off
legend 'ipsnr' 'imse' 'crossc'

ilfmse
