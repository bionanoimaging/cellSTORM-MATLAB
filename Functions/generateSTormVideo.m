myimg = imread('/Users/bene/Downloads/Blinky_Bill.jpg');
myedge = (edge(rgb2gray(myimg)));
%myedge = imresize(myedge*1.0, .25);
[y, x] = find(myedge); 
save('coordStorm', 'x', 'y')
ntime = 250;



myVideo = VideoWriter('stormfadeout.mp4');
myVideo.VideoFormat('MPEG-4)
myVideo.FrameRate = 24;  % Default 30
myVideo.Quality = 50;    % Default 75
open(myVideo);

iframes = {};
iframe = myedge * 0; 
for i = 0:ntime-1;
    timeevents = dip_image(myedge)*(1.*dip_image(rand([size(myedge)])>0.9930));
    timeevents = gaussf(timeevents, 2);
    timeevents = timeevents*(1-gaussf(rand([size(myedge)])>0.9930, 2));
    iframe = iframe + squeeze(timeevents);
    
    
    temp = iframe - min(min(iframe));
    temp = uint8(iframe./max(iframe).*256);
    %temp = 256-temp;
    writeVideo(myVideo, temp);
    disp([num2str( i ) ' / ' num2str(ntime-1)])
end



close(myVideo)




