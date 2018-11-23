%% LOAD emccd DATA
myfolder = '/Users/bene/Downloads/comparison/';
my_locfile_emccd = 'emccd.csv';
my_locfile_emccd = [myfolder my_locfile_emccd];

%% import all positions from ground truth csv
Activations = importdata(my_locfile_emccd);
Data = Activations.data;
col_names = Activations.colheaders;

% Create output variable
Activatoins_emccd = table;
Activatoins_emccd.frame = Data(:,2);
Activatoins_emccd.xnm = Data(:,3);
Activatoins_emccd.ynm = Data(:,4);

emccd_n_frames = max(Activatoins_emccd.frame);
emccd_nemitter_per_frame = zeros(1,emccd_n_frames);

for i=1:emccd_n_frames
    emccd_nemitter_per_frame(i) = sum(Activatoins_emccd.frame==i);
end

emccd_dx = max(Activatoins_emccd.xnm) - min(Activatoins_emccd.xnm);
emccd_dy = max(Activatoins_emccd.ynm) - min(Activatoins_emccd.ynm);
emccd_area = emccd_dx*emccd_dy;

%% LOAD cmos DATA
myfolder = '/Users/bene/Downloads/comparison/';
my_locfile_cmos = 'cmos.csv';
my_locfile_cmos = [myfolder my_locfile_cmos];

%% import all positions from ground truth csv
Activations = importdata(my_locfile_cmos);
Data = Activations.data;
col_names = Activations.colheaders;

% Create output variable
Activatoins_cmos = table;
Activatoins_cmos.frame = Data(:,2);
Activatoins_cmos.xnm = Data(:,3);
Activatoins_cmos.ynm = Data(:,4);

cmos_n_frames = max(Activatoins_cmos.frame);
cmos_nemitter_per_frame = zeros(1,cmos_n_frames);

for i=1:cmos_n_frames
    cmos_nemitter_per_frame(i) = sum(Activatoins_cmos.frame==i);
end

cmos_dx = max(Activatoins_cmos.xnm) - min(Activatoins_cmos.xnm);
cmos_dy = max(Activatoins_cmos.ynm) - min(Activatoins_cmos.ynm);
cmos_area = cmos_dx*cmos_dy;

%% Plot values
r_gauss = 9;
fps = 20;
cmos_nframe_unitarea = gaussf(cmos_nemitter_per_frame/fps, r_gauss )/cmos_area;
emccd_nframe_unitarea = gaussf(emccd_nemitter_per_frame/fps, r_gauss )/emccd_area;
cmos_result = [myfolder 'CMOS_res.tif'];
cmos_result = imread(cmos_result);
emccd_result = [myfolder 'EMCCD_res.tif'];
emccd_result = imread(emccd_result);

% calculate the two line profiles for
cmos_linp_x = [197 228];
cmos_linp_y = [405 368];
cmos_linp = improfile(cmos_result, cmos_linp_x, cmos_linp_y, 'bicubic');

emccd_linp_x = [293 320];
emccd_linp_y = [334 311];
emccd_linp = improfile(emccd_result, emccd_linp_x, emccd_linp_y, 'bicubic');



%
figure
subplot(1,4,1)
plot((1:cmos_n_frames),cmos_nframe_unitarea*1e6, 'Color', 'blue')
hold on
plot((1:emccd_n_frames),emccd_nframe_unitarea*1e6, 'Color', 'green')
hold off
axis square
xlabel 'Time [s]'
ylabel '# Events/µm^2'
xlim([ 1 cmos_n_frames])
if(1)
h = legend('CMOS', 'EMCCD')
pos=get(h,'position')
new_pos=pos;
new_pos(3)=pos(3)+0.4; % This is the x length
new_pos(1)=pos(1)-0.4;   %  The x position
set(h,'position',new_pos)
end

%
subplot(1,4,2)
xdata = min(Activatoins_cmos.xnm)*1e-3:max(Activatoins_cmos.xnm*1e-3);
ydata = min(Activatoins_cmos.ynm)*1e-3:max(Activatoins_cmos.ynm*1e-3);
cmos_result(cmos_result>100) = 100; 
imagesc(cmos_result, [0 60])%, 'XData', xdata, 'YData', ydata)
axis square
axis off
colormap hot
xlabel 'X Dimension [µm]'
ylabel 'Y Dimension [µm]'
title 'Result CMOS'
hold on
line(cmos_linp_x, cmos_linp_y,'Color', 'blue', 'LineWidth',1)
hold off
%
subplot(1,4,3)
roi_comp = floor(640/1400*1000);
emccd_result = emccd_result(end-roi_comp:end,end-roi_comp:end);
xdata = min(Activatoins_cmos.xnm)*1e-3:max(Activatoins_cmos.xnm*1e-3);
ydata = min(Activatoins_cmos.ynm)*1e-3:max(Activatoins_cmos.ynm*1e-3);
imagesc(emccd_result, [0 100])%, 'XData', xdata, 'YData', ydata)
axis square, colormap hot
axis off
xlabel 'X Dimension [µm]'
ylabel 'Y Dimension [µm]'
title 'Result EMCCD'
hold on
line(emccd_linp_x, emccd_linp_y,'Color', 'green', 'LineWidth',1)
hold off

%
subplot(1,4,4)
plot((1:numel(cmos_linp))*80*1e-3,cmos_linp, 'Color', 'blue')
hold on
plot((1:numel(emccd_linp))*80*1e-3,emccd_linp, 'Color', 'green')
hold off
axis square
xlabel 'Dimension [µm]'
ylabel 'Intensity [AU]'
xlim([ 0 3])
ylim([ 0 110])
title 'Lineprofile CMOS/EMCCD'

%%


if(0)
h = legend('CMOS', 'EMCCD')
pos=get(h,'position')
new_pos=pos;
new_pos(3)=pos(3)+0.4; % This is the x length
new_pos(1)=pos(1)-0.4;   %  The x position
set(h,'position',new_pos)
end



%% export graphic
hgexport_script('small_low_res_png.png', 11, 4, 4, 1200,'png')

