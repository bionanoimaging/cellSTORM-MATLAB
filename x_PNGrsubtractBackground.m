% Convert the processed files from the GAN to a stack for fiji
filedir = '/Users/bene/Dropbox/Dokumente/Promotion/PROJECTS/STORM/alltogether/train/'
filedir_mod = filedir;'/Users/bene/Downloads/Rot/test/'
if (~exist(filedir_mod, 'dir')); mkdir(filedir_mod ); end%if

% READ the processed data
srcFiles = dir([filedir '*.png']);  % the folder in which ur images exists



bgrdval = 15;

for i = 1 : length(srcFiles)
    
    %%
    
    filename = strcat(filedir,srcFiles(i).name);
    
    if(contains(filename,'result_realA_sub256') | contains(filename,'Artificial') )
        disp('nothing to change')
    else
        
    % read frame and register it (parameters measured only once!)
    iframe  = imread(filename);
    
    iframe_a = (iframe(:,1:256));
    iframe_b = (iframe(:,257:end))-bgrdval;

    % align the frame and save it
    iframe = horzcat(iframe_a, iframe_b);
    
    imwrite(uint8(iframe), filename);
    
    disp([num2str(i) ' / ' num2str(length(srcFiles))])
    end
    
end
