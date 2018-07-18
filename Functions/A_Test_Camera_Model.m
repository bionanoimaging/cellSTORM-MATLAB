image_raw = readim('orka');
mysize = size(image_raw);

readnoise = 10; % e- rms
gain = 1; % DN/e- 
poisson_noise = 0; 

% add photon noise
sensorOut_e = noise(image_raw, 'poisson', 1);

% add read noise 
readNoise_e = randn(mysize) * readnoise; %units are e- rms

% quantize the data and take care of the gain
image_DN = ((sensorOut_e + readNoise_e) * gain);   %units DN

% calculate SNR
%mySNR=mean(image_DN(:))/std(image_DN(:))

SNR=10*log10(mean(image_DN(:))/std(image_DN(:)))

SNR3 = 10*log10(var(image_raw(:))/var(image_DN(:)-image_raw(:)))

