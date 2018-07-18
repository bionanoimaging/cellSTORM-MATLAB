filename = '/home/useradmin/Dropbox/Dokumente/Promotion/PROJECTS/STORM/DATASET_NN/neuroSTORM/2018-01-23_17.53.21_oldSample_ISO3200_10xEypiece_texp_1_30';
input_filename = [filename '.mp4'];
output_filename = [filename '.tif']; 
obj = VideoReader(input_filename);
nframes = obj.NumberOfFrames;

mysize = [1080 1920];
mycentre = mysize / 2;

roi = 256; roi = roi/2;
% write out tiff stack
for x = 1 : nframes
    
    % crop out the centre of the image with width/height = 512 px 
    iframe = uint8(read(obj, x)); iframe = iframe(:,:,1);
    iframe = iframe(mycentre(1)-roi:mycentre(1)+roi-1,mycentre(2)-roi:mycentre(2)+roi-1);
    
    % write image 
    imwrite(iframe, output_filename, 'WriteMode', 'append');%,  'Compression','none');
   
    disp([num2str(x) ' / ' num2str(nframes)])
end