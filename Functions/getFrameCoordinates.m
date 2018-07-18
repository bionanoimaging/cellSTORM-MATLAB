function [FiberPosition mask] = getFrameCoordinates(input)


mysize=size(squeeze(input));

%% create a figure handle and select the coordinates
%fh=dipshow(input(:,:,1)); % find edges of CC signal
fh=dipshow((input)); % find edges of CC signal

diptruesize(fh, 100);
%fh=dipshow(abs(AllSubtractFT(:,:,0))^.1) % find edges of CC signal
fprintf('Please select 4 coordinates which describe the position of the frame');
fprintf('Order: Upper-Left Corner, Upper-Right Corner, Lower-Right Corner, Lower-Left Corner')
FiberPosition = dipgetcoords(fh,4);
fprintf('Thank you :-)')

%% select ROI
mask = drawpolygon(newim(mysize),FiberPosition,1,'closed');
mask = dip_image(mask,'bin');
mask = ~bpropagation(mask&0,~mask,0,1,1);