% Compare Images
filedir_GT = './1000Emitters';
filedir_HW = './1000Emitters_focus17_2_ISO3200_Polarizer';


filename = '/Image_'
%% 
psnr_i = {};
stack_i = {}; 
for i = 1:20
    try
        file_GT = [filedir_GT num2str(i,'/Image_%03d') '.png'];
        file_HW = [filedir_HW num2str(i,'/Image_%03d') '.png'];
        
        img_GT = readim(file_GT);
        img_HW = readim(file_HW);
       stack_i{i} =  cat(3, img_GT, img_HW);
        
       psnr_i{i} = psnr(img_GT, img_HW);
    catch
        disp('not found')
    end
end

cat(4, stack_i{:})
plot(cat(1, psnr_i{:}))

