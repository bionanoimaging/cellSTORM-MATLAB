
%% calculate crop coordinates
crop_x_1 = min(X1_inner(:,1));
crop_x_2 = max(X1_inner(:,1));
crop_y_1 = min(X1_inner(:,2));
crop_y_2 = max(X1_inner(:,2));
diff_x = abs(crop_x_1 - crop_x_2);
diff_y = abs(crop_y_1 - crop_y_2);


% check if even integer
if(mod(diff_x, 2)); crop_x_1 = crop_x_1-1; end
if(mod(diff_y, 2)); crop_y_1 = crop_y_1-1; end
diff_x = abs(crop_x_1 - crop_x_2);
diff_y = abs(crop_y_1 - crop_y_2);
diff_xy = abs(diff_x-diff_y);


% make square
if(diff_y > diff_x)
    crop_x_1 = crop_x_1 - uint8(diff_xy/2);
    crop_x_2 = crop_x_2 + uint8(diff_xy/2);
elseif(diff_y < diff_x)
    crop_y_1 = crop_y_1 - round(diff_xy/2);
    crop_y_2 = crop_y_2 + round(diff_xy/2);
end
diff_x = abs(crop_x_1 - crop_x_2);
diff_y = abs(crop_y_1 - crop_y_2);
diff_xy = abs(diff_x-diff_y);


% add border around it
px_border = 10;
crop_x_1 = crop_x_1 - px_border;
crop_x_2 = crop_x_2 + px_border;
crop_y_1 = crop_y_1 - px_border;
crop_y_2 = crop_y_2 + px_border;


% update difference
diff_x = abs(crop_x_1 - crop_x_2);
diff_y = abs(crop_y_1 - crop_y_2);

% compute crop coordinates
crop_coordinates_x = crop_x_1:crop_x_2+1;
crop_coordinates_y = crop_y_1:crop_y_2+1;


i_whiteframe = iframe_raw(crop_coordinates_y, crop_coordinates_x);
dip_image(i_whiteframe)
disp('Whiteframe saved')
imwrite(uint8(squeeze(i_whiteframe)), ['./' filedir '/XXX_Whiteframe.png'])

