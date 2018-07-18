% Convert the processed files from the GAN to a stack for fiji
filedir = '/media/useradmin/Data/Benedict/Dropbox/Dokumente/Promotion/PROJECTS/STORM/DATASET_NN/01_CELLPHONE_GT_PAIRS/Datapairs_Random_Teststorm_256_1000Emitters_lines_mod_rot/train/'
% READ the processed data
srcFiles = dir([filedir '*.png']);  % the folder in which ur images exists


%%
imse = {}
ipsnr = {}
ifilename = {}; 
iter = 1;
for i = 1 : 1000%length(srcFiles)
    
    %%
    
    filename = strcat(filedir,srcFiles(i).name);
    if(contains(filename, 'mod2'))
        
        iframe  = imread(filename);
        iframe_a = iframe(:,1:256);
        iframe_b = iframe(:,257:end);
        
        imse{iter} = mse(iframe_a,iframe_b,[]);
        ipsnr{iter} = psnr(iframe_a,iframe_b);
        ifilename{iter} = filename;
        iter = iter + 1; 
        
    end
    
    disp([num2str(i) ' / ' num2str(length(srcFiles))])
    
end

all_mse = cat(1, imse{:});
all_psnr= cat(1, ipsnr{:});
%%
figure
plot(all_mse)
hold on
plot(all_psnr)
hold off

%% #
iframe = 18;
iframe  = imread(ifilename{41});
iframe_a = iframe(:,1:256);
iframe_b = iframe(:,257:end);
dip_image(cat(3, iframe_a, iframe_b))