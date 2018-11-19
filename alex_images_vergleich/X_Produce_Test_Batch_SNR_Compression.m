% specify the folder where the A to B paris are placed

% define input and output folder
filename_TIF = 'test_density_128_6_parametrs';
filedir_TIF = './Stack_6/'
fname = [filedir_TIF filename_TIF '.tif'];
background_level = 0;


% iterate over different  Video compression
compression = [90 100 70 80];

% iterate over different Photon levels 
nphotons = [50 100 500 1000];

% define photon statistics 
mysize = [128 128];

gain = .34;
pixeloffset = 4.074;
myreadnoise = 1.23; % in e- rms

for compression_i = compression
    for nphotons_i = nphotons
        
        
        
        %% define Video settings
        extension_video = '.m4v';
        vname = [filedir_TIF filename_TIF 'SNR_Compression_nphotons_' num2str(nphotons_i) '_compression_' num2str(compression_i) extension_video ];
        % create video writer object
        myVideo = VideoWriter(vname, 'MPEG-4');%'Grayscale AVI');%,'Uncompressed AVI');
        myVideo.FrameRate = 30;  % Default 30
        %myVideo.CompressionRatio = 1;
        myVideo.Quality = compression_i;
        myVideoCompressionMethod = 'H.264';
        %myVideo.LosslessCompression = True;
        
        % open the video
        open(myVideo)
        
        
        %% read tiff-stack
        % parameters set in ThunderSTORM:
        % photoelectron: 1
        % 
        % FHWM: 200-350 nm, Intensity 700-1000, Background 0
        % pixelsize: 80nm 
        % density of emitters: 3 1/µmm^2
        max_intensity = 1001;
        
        % create tif file object
        tif_info = imfinfo(fname);
        n_frames = size(tif_info,1);
        
        %% apply camera statistics
        for i = 1:n_frames
            
            %% apply camera statistics
            iframe = extract(dip_image(imread(fname, i)), mysize);
            
            % how many photons per Emitter?
            iframe = iframe/max_intensity*nphotons_i;
            
            % apply photon noise (poisson)
            sensorOut_e = noise(iframe, 'Poisson', gain);
            %sensorOut_e = poissrnd(5.2,10,10);  %units are e- - NO
            %DIPIMAGE!
            
            % add readNoise according to camera measurements
            readNoise_e = randn(mysize) * myreadnoise; %units are e- rms
            
            % sum signal and quantize
            image_DN = uint8((sensorOut_e + readNoise_e)) + pixeloffset;   %units DN
            
            if(0)
                % apply demosaicing using nearest neighbours (optional)
                image_DN_demosaic = uint8(mean(demosaicing(image_DN), 3));
                writeVideo(myVideo, image_DN_demosaic);
            else
                writeVideo(myVideo, image_DN);
            end
            
            
            
            disp([num2str(i) '/ ' num2str(n_frames)])
        end
        
        % Close video to start new iteration
        close(myVideo);
        
    end
end


