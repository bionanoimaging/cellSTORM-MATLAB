% File to find the matches fo the two frames from groundtruth and acquired
% video

filedir_GT = 'testSTORM_random_psf/';%uigetdir('./');
filedir_HW = 'MOV_2018_02_28_10_57_39_ISO3200_texp1_200_randomtestSTORM/'%;uigetdir('./');



%% Find matching test cases in the two directories
o = dir(fullfile(filedir_GT, '*.png')); % 'old'
n = dir(fullfile(filedir_HW, '*.png')); % 'new'

%// Use setdiff to compare the files that were in one but not the other
in_old_but_not_new = setdiff({o.name}, {n.name});
in_new_but_not_old = setdiff({n.name}, {o.name});



%% first check in GT folder for files
% mkdir for tmp files
tmp_dir_GT = [filedir_GT '/tmp'];
if (~exist(tmp_dir_GT, 'dir')); mkdir(tmp_dir_GT ); end%if
% move files to tmp directory
for i = 1:length(in_old_but_not_new)
    try
        
        movefile([filedir_GT '/' in_old_but_not_new{i}], [tmp_dir_GT '/' in_old_but_not_new{i}])
    catch
        disp('Error: maybe file was already transfered')
    end
    
end

%% now check in HUAWEI FOLDER
% mkdir for tmp files
tmp_dir_HW = [filedir_HW '/tmp'];
if (~exist(tmp_dir_HW, 'dir')); mkdir(tmp_dir_HW ); end%if
% move files to tmp directory
for i = 1:length(in_new_but_not_old)
    try
        
        movefile([filedir_HW '/' in_new_but_not_old{i}], [tmp_dir_HW '/' in_new_but_not_old{i}])
    catch
        disp('Error: maybe file was already transfered')
    end
    
end

%% Check if there are any leftover files:

%% Find matching test cases in the two directories
o = dir(fullfile(filedir_GT, '*.png')); % 'old'
n = dir(fullfile(filedir_HW, '*.png')); % 'new'

%// Use setdiff to compare the files that were in one but not the other
in_old_but_not_new = setdiff({o.name}, {n.name})
in_new_but_not_old = setdiff({n.name}, {o.name})


