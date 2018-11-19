filename = '/home/useradmin/Dropbox/Dokumente/Promotion/PROJECTS/STORM/DATASET_NN/neuroSTORM/2018-01-23_17.53.21_oldSample_ISO3200_10xEypiece_texp_1_30';
filename = '/Users/bene/Dropbox/MOV_2018_11_07_11_33_12'
filename = '/Users/bene/Dropbox/Confocal/with cubes/vid2'
filename = '/Users/bene/Downloads/2018-11-14 15.49.55'


input_filename = [filename '.mp4'];
output_filename = [filename '.tif'];
obj = VideoReader(input_filename);
nframes = obj.NumberOfFrames;

mysize = [1080 1920];
mycentre = mysize / 2;
mycentre = [477 925]

crop = false 
roi = 512; roi = roi/2;
% write out tiff stack
for x = 1:10:nframes%1000 : 10: 1500%nframes
    
    % crop out the centre of the image with width/height = 512 px 
    iframe = uint8(read(obj, x)); iframe = iframe(:,:,1);
    if(crop)
    iframe = iframe(mycentre(1)-roi:mycentre(1)+roi-1,mycentre(2)-roi:mycentre(2)+roi-1);
    end
    % write image 
    imwrite(iframe, output_filename, 'WriteMode', 'append');%,  'Compression','none');
   
    disp([num2str(x) ' / ' num2str(nframes)])
end