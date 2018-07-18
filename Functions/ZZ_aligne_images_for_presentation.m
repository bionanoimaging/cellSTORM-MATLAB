pixelsize = 80/5;

%%
fakeB_y = dip_image(ValuesfakeB.Y);
realA_y = dip_image(ValuesrealA.Y);


fakeB_y = gaussf(fakeB_y, 1);
realA_y = gaussf(realA_y, 1);
if(size(realA_y,1)>size(fakeB_y,1))
    realA_y = extract(realA_y, size(fakeB_y,1));
elseif(size(realA_y,1)<size(fakeB_y,1))
    fakeB_y = extract(fakeB_y, size(realA_y,1));
end

shiftcoord = findshift(realA_y, fakeB_y, 'iter');
fakeB_y_s = shift(fakeB_y, shiftcoord);


%
figure
plot(double(fakeB_y_s))
hold on
plot(double(realA_y))
hold off
legend 'fakeB'  'realA'



%%
fakeB = readim('/Users/bene/Dropbox/Paper/Bilder/2017-12-18_18.29.45.mp4_256_alltogether_2/Averaged shifted histograms_from_video_v2_fakeb.tif');
realA = readim('/Users/bene/Dropbox/Paper/Bilder/2017-12-18_18.29.45.mp4_256_alltogether_2/sehraltedaten_real-TS-filtered_ASH+dc.tif');
cat(3, fakeB, realA)

shiftcoord = findshift(fakeB, realA, 'iter');
realA_s = shift(realA, shiftcoord);
cat(3, fakeB, realA_s)

% also incorporate zoom and shift 
affine_coords = find_affine_trans(fakeB, realA_s, [1,1, 0, 0, 0])
fakeB_affine = affine_trans(fakeB, affine_coords(1:2), affine_coords(3:4), 0)


%% write images
fakeB_final = uint16(extract((fakeB_affine/max(fakeB_affine)*2^12), [1000 1000]));
realA_final = uint16(extract((realA_s/max(realA_s)*2^12), [1000 1000]));
dip_image(cat(3, fakeB_final, realA_final))

imwrite(fakeB_final, 'fakeB_alligned.tif')
imwrite(realA_final, 'realA_alligend.tif')


%%
start_y = 565;
end_y = 750;
x_bar = pixelsize*(0:(end_y-start_y))

figure

plot(x_bar, fakeB_final(545, start_y:end_y))
hold on
plot(x_bar, realA_final(545, start_y:end_y))
hold off
xlabel 'Dimensions [nm]'
ylabel 'Intensity [ADU]'
legend 'fakeB'  'realA'

fig_compare = dip_image(cat(3, fakeB_final, realA_final));
extract(fig_compare, [200 200], [start_y end_y])



