%% Convert the processed files from the GAN to a stack for fiji
filedir = '/home/useradmin/Dropbox/Dokumente/Promotion/PROJECTS/STORM/DATASET_NN/01_CELLPHONE_GT_PAIRS/Datapairs_Random_Teststorm_256_1000Emitters_lines/train/'
filedir_mod = '/home/useradmin/Dropbox/Dokumente/Promotion/PROJECTS/STORM/DATASET_NN/01_CELLPHONE_GT_PAIRS/Datapairs_Random_Teststorm_256_1000Emitters_lines_only_max5/train/'
if (~exist(filedir_mod, 'dir')); mkdir(filedir_mod ); end%if
% READ the processed data
srcFiles = dir([filedir '*.png']);  % the folder in which ur images exists



%% Check similarity per frame
imse = {};
itranslation = {};
ipsnr = {}
ifilename = {};
iter = 1;

%randomized_index = randi(length(srcFiles),length(srcFiles),1);

for i = 1  :  length(srcFiles)
    
    
    filename = strcat(filedir,srcFiles(i).name);
    if(~contains(filename, 'mod') & count(srcFiles(i).name,'_')==1)
        
        iframe  = imread(filename);
        iframe_a = dip_image(iframe(:,1:256));
        iframe_b = dip_image(iframe(:,257:end));
        
        %   dip_image(cat(3, iframe_a, iframe_b))
        
        % correct for wrong alignement for certain files!
        try
            % find shift coordinates by cross correlation
            translation_out= findshift(iframe_a,iframe_b,'ffts',0,15);
            
            if(sqrt(translation_out(2,:).^2+translation_out(1,:).^2) < 7)
                
                % shift the one frame to match the other one
                %iframe_a_shift = affine_trans(iframe_a, 1, flip(translation_out), 0);
                iframe_b = shift(iframe_b, translation_out);
                
                
                if(0),cat(3, iframe_a, iframe_b), drawnow, end
                
                
                
                imse{iter} = mse(iframe_a,iframe_b,[]);
                ipsnr{iter} = psnr(iframe_a,iframe_b);
                ifilename{iter} = filename;
                itranslation{iter } = translation_out ;
                iter = iter + 1;
                %% apply random shift, rotate and translation
                for i_rotate = 1:6
                    zoom = 1+(.1*rand(1)-.05);
                    translation = round(128*(rand(1,2)))-64;
                    angle = (rand*360);
                    if(zoom>1) % if zoom greater 1 -> pad it with coppies
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
                    
                    if(0), cat(3, iframe_a_i, iframe_b_i), end
                    
                    if(1)
                        % save the file
                        % experiment with scalling the intensities; GAN suggests to not oversaturate the images
                        
                        %iframe_a_i = iframe_a_i./max(iframe_a_i)*(.5*255);
                        %iframe_b_i = iframe_b_i./max(iframe_b_i)*(.5*255);
                        iframe_i = horzcat(iframe_a_i, iframe_b_i);
                        filename_i = [filedir_mod  erase(srcFiles(i).name,'.png') '_mod' num2str(i_rotate) '.png'];
                        
                        if(0), dip_image(cat(3, iframe_a_i, iframe_b_i)), drawnow, end
                        
                        imwrite(uint8(iframe_i), filename_i)
                    end
                end
            else
                disp('Too much shift is estimated!')
            end
            
            
        catch
            disp('DIPlib Error in function dip_FindShift: Too few valid data points to do calculation.')
            
        end
        
    end
    
    disp([num2str(i) ' / ' num2str(length(srcFiles))])
    
end


all_mse = cat(1, imse{:});
all_psnr= cat(1, ipsnr{:});
all_translation= cat(2, itranslation{:});

%%
figure
plot(all_mse)
hold on
plot(all_psnr)

plot(all_translation(1,:))
plot(all_translation(2,:))
plot(sqrt(all_translation(2,:).^2+all_translation(1,:).^2))
hold off

%% #
iframe = 2345;
iframe  = imread(ifilename{iframe});
iframe_a = iframe(:,1:256);
iframe_b = iframe(:,257:end);

% find shift coordinates by cross correlation
translation_out = findshift(iframe_a,iframe_b,'ffts',0,15);

% shift the one frame to match the other one
iframe_a_shift = affine_trans(iframe_a, 1, translation_out, 0);


dip_image(cat(3, iframe_a, iframe_b, iframe_a_shift ))

