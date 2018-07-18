%Convert the TIFF Stack into the pix2pix readable png files
fpath = '/home/useradmin/Dropbox/Dokumente/Promotion/PROJECTS/STORM/DATASET_NN/neuroSTORM/';
fpath = '/Users/bene/Dropbox/neuroSTORM/';


[fname fpath] = uigetfile({'*.mp4'}, 'Select the Video File', fpath)

fpath_dest = fpath;'';
fpath_dest = '/media/useradmin/Data/Benedict/Dropbox/Dokumente/Promotion/PROJECTS/STORM/DATASET_NN/04_UNPROCESSED_RAW_HW/';
roi = 512; 
fpath_dest = [fpath_dest fname '_' num2str(roi) '/test'];
myfname = [fpath fname]

% mkdir if not exist
if (~exist(fpath_dest, 'dir')); mkdir(fpath_dest ); else disp('already processed'), return; end%if


obj = VideoReader(myfname);

nframes = obj.NumberOfFrames;

mysize = [1080 1920];
mycentre = mysize / 2;




%% get the ROI coordinates
iframe = uint8(read(obj, 10)); iframe = iframe(:,:,1);

AH=dipshow(dip_image(iframe))
diptruesize(AH,100)
fprintf('Get the ROI coordinates')
fprintf('1. Click the center of the Hologram \n');
fprintf('2. Click the outer rim of the roi you wanna extract\n ')
roi_coordinates = dipgetcoords(AH,2);
fprintf('Thank you for selecting the ROI! Data will be processed now!\n')

roi_center = [roi_coordinates(1, 1) roi_coordinates(1,2)]; % StartX, StartY

difX = abs(roi_coordinates(1)-roi_coordinates(2));
difY = abs(roi_coordinates(3)-roi_coordinates(4));
%roi_size = max(difX, difY)*2; %size of the Box
roi_size = roi;
roi_size =[roi_size roi_size];

iframe_roi = extract(dip_image(iframe), roi_size, roi_center)
disp('ROI has been extracted')



%% write out png series
for x = 1 : nframes
        
    % crop out the centre of the image with width/height = 512 px
    iframe = (read(obj, x)); 
    %iframe = iframe(mycentre(1)-roi:mycentre(1)+roi-1,mycentre(2)-roi:mycentre(2)+roi-1);
    iframe = extract(dip_image(iframe), roi_size, roi_center);
    iframe = mean(iframe, [], 3);
    iframe = uint8(iframe);
    % write image
    imwrite(horzcat(iframe, iframe*0), [fpath_dest '/Image_' num2str(x) '.png']);%,  'Compression','none');
    
    disp([num2str(x) ' / ' num2str(nframes)])
end