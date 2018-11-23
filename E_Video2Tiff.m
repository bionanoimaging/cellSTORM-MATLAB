% Convert Video to TIFF-Stack for processing it with Fiji
[filename pathname] = uigetfile('*.mp4')

%%
input_filename = [pathname filename]%[filename '.mp4'];
output_filename = [filename '.tif'];
obj = VideoReader(input_filename);
nframes = obj.NumberOfFrames;

mysize = [1080 1920];
mycentre = mysize / 2;
mycentre = [477 925]
mycentre = [ 494 939]


crop = true 
roi = 128; roi = roi/2;
%% write out tiff stack
for x = 1:5000%2:nframes%1000 : 10: 1500%nframes
    
    % crop out the centre of the image with width/height = 512 px 
    iframe = uint8(read(obj, x)); iframe = iframe(:,:,1);
    if(crop)
    iframe = iframe(mycentre(1)-roi:mycentre(1)+roi-1,mycentre(2)-roi:mycentre(2)+roi-1);
    end
    % write image 
    imwrite(iframe, output_filename, 'WriteMode', 'append');%,  'Compression','none');
   
    disp([num2str(x) ' / ' num2str(nframes)])
end