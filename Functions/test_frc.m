% example: for 2D
%% defina beta
image_1 = '/home/useradmin/Dropbox/Dokumente/Promotion/PROJECTS/STORM/PYTHON/pix2pix-tensorflow/myresults/MOV_2018_05_09_15_09_17_ISO3200_texp_1_30_newsample.mp4_train_overnight_1_2_3_cluster_4_GANupdaterule_synthetic'
im1_raw=(readim('test_density_128_3SNR_Compression_nphotons_50_compression_70-with_NN_2.tif'));
im2_raw=(readim('test_density_128_3SNR_Compression_nphotons_50_compression_70-with_NN.tif'));
im3_raw=(readim('test_density_128_3SNR_Compression_nphotons_50_compression_70-wo_NN.tif'));
im4_raw=(readim('test_density_128_3SNR_Compression_nphotons_50_compression_70-wo_NN_2.tif'));
im1=im1+im2;
im3=im3+im4;
%cat(3, im1, resample(im3, 768/640))

%%
if(1)
    mymask = rr(size(im4_raw),'freq')<.25;
else
    mymask = zeros(size(im1));
    mymask(size(im1,1)/2, size(im1,2)/2) = 1;
    mymask = gaussf(mymask, 55);
    mymask = mymask/max(mymask);
end

if(0)
    mymask = circshift(mymask, [size(mymask,1)/2 0 ]) + circshift(mymask, [0 size(mymask,1)/2]);
    im1 = abs(ift(ft(im3_raw).*(mymask)));
    im2 = abs(ift(ft(im4_raw).*(mymask)));
else
    im1 = abs(ift(DampEdge(ft(im1_raw), 0.25,2,1,15)));
    im2 = abs(ift(DampEdge(ft(im2_raw), 0.25,2,1,15)));

    %im1 = ((DampEdge((im1_raw), 0.15,2,1)));
    %im2 = ((DampEdge((im2_raw), 0.15,2,1)));

end

%%
p.beta = 1
frc = FSC(double(im1), double(im2), p);
figure
hold on
plot(frc.nu, frc.frc, 'DisplayName', 'FRC')
plot(frc.nu, frc.T_hbit, 'DisplayName', '1/2 bit Threshold')
plot(frc.nu, frc.T_bit, 'DisplayName', '1 bit Threshold')
hold off
legend show