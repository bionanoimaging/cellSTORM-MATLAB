% example: for 2D
%% defina beta
filedir = '/home/useradmin/Dropbox/Dokumente/Promotion/PROJECTS/STORM/PYTHON/pix2pix-tensorflow/myresults/MOV_2018_05_09_15_32_13_ISO6400_texp_1_30_newsample.mp4_train_overnight_1_2_3_cluster_4_GANupdaterule_synthetic/'
image_1 = [filedir 'MOV_2018_05_09_15_32_13_ISO6400_texp_1_30_newsample.mp4output_sum_frc1.tif'];
image_2 = [filedir 'MOV_2018_05_09_15_32_13_ISO6400_texp_1_30_newsample.mp4output_sum_frc2.tif'];
%image_1 = [filedir 'FRC_1.tif'];
%image_2 = [filedir 'FRC_2.tif'];

im1_raw=(readim(image_1));
im2_raw=(readim(image_2));

%%
if(1)
    mymask = rr(size(im1_raw),'freq')<.25;
else
    mymask = zeros(size(im1));
    mymask(size(im1,1)/2, size(im1,2)/2) = 1;
    mymask = gaussf(mymask, 55);
    mymask = mymask/max(mymask);
end

if(1)
    mymask = circshift(mymask, [size(mymask,1)/2 0 ]) + circshift(mymask, [0 size(mymask,1)/2]);
    im1 = abs(ift(ft(im1_raw).*(1-mymask)));
    im2 = abs(ift(ft(im2_raw).*(1-mymask)));
else
    im1 = abs(ift(DampEdge(ft(im1_raw), 0.25,2,1,15)));
    im2 = abs(ift(DampEdge(ft(im2_raw), 0.25,2,1,15)));

    %im1 = ((DampEdge((im1_raw), 0.15,2,1)));
    %im2 = ((DampEdge((im2_raw), 0.15,2,1)));

end

%%
p.beta = 7;
frc = FSC(double(im1), double(im2), p);
figure
hold on
plot(frc.nu, frc.frc, 'DisplayName', 'FRC with NN')
plot(frc.nu, frc.T_hbit, 'DisplayName', '1/2 bit Threshold')
plot(frc.nu, frc.T_bit, 'DisplayName', '1 bit Threshold')
plot(frc_wonn.nu, frc_wonn.frc, 'DisplayName', 'FRC wo NN')
hold off
legend show

frc_wonn = frc;