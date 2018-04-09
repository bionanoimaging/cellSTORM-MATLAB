I1 = uint8((imread('checkerboard.png')));
I2 = uint8(rgb2gray(imread('checkerobardacq.png')));
I2 = I2(100:end, 60:670);

mysize = size(I2);
I1 = imrotate(imresize(I1, mysize), 180);

%%
clear flow opticalFlow
opticalFlow = opticalFlowLK('NoiseThreshold', 0.005)                                                          

flow = estimateFlow(opticalFlow, I1)
flow = estimateFlow(opticalFlow, I2)

figure
imagesc(0.5*I2 + 0.5*I1)
colormap gray
hold on
plot(flow)
hold off
axis square

%%
fixed  = I2;
moving = I1;

moving = imhistmatch(moving,fixed);
[displacementmat,movingReg] = imregdemons(moving,fixed,[500 400 200],...
    'AccumulatedFieldSmoothing',3);

rectx = double(sin(xx(mysize)*.5)>0);
recty = double(sin(yy(mysize)*.5)>0);


displacementmat_var_x = double(gaussf(displacementmat(:,:,1), 5));
displacementmat_var_y = double(gaussf(displacementmat(:,:,2), 5));
displacementmat_var = cat(3, displacementmat_var_x, displacementmat_var_y);

dip_image(cat(3, horzcat(displacementmat_var), horzcat(displacementmat)))
dip_image(cat(3, imwarp(I1, displacementmat_var), I2, imwarp(I1, displacementmat), imwarp(rectx, displacementmat), imwarp(recty, displacementmat)))