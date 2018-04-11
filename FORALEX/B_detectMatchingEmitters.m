% Script to compare files localized with Thunderstorm;
% you can process groundtruth to NN-processed frames or without NN % processing! 
disp('Import the data. Might take a while!')
mypath = './Leibniz/'
realB = importThunderstorm([mypath 'realB.csv'], 1);
realA = importThunderstorm([mypath 'realA.csv'], 1);
fakeB = importThunderstorm([mypath 'fakeB.csv'], 1);

%% define selected frames
my_firstframe = min(realB.frame);
my_lastframe = max(realB.frame);
my_selectedframes = (my_firstframe:1:my_lastframe);

%% find closest match for all events      

distance_realA_realB = [];
distance_fakeB_realB = [];


for my_iter = my_selectedframes
    % create the localizations per frame and draw them
    realB_events = (realB.frame == uint32(my_iter));
    realA_events = (realA.frame == uint32(my_iter));
    fakeB_events = (fakeB.frame == uint32(my_iter));


    if(sum(realB_events) == 0)
        disp('no events visible')
    else
        disp(['events visible at frame: ' num2str(my_iter)])
        
        % find all localizations in groundtruth frame 
        realB_xyevents_i = [realB.xnm(realB_events) realB.ynm(realB_events)];
        
        % find all localizations in captured frame 
        realA_xyevents_i = [realA.xnm(realA_events) realA.ynm(realA_events)];
        
        % find all localizations in captured frame which is processed 
        fakeB_xyevents_i = [fakeB.xnm(fakeB_events) fakeB.ynm(fakeB_events)];
        
        % find nearest neighbours in unprocessed data
        [neurest_realA_realB,distance_neurest_realA_realB] = knnsearch(realB_xyevents_i,realA_xyevents_i);
        
        % find nearest neighbours in processed data
        [neurest_fakeB_realB,distance_neurest_fakeB_realB] = knnsearch(realB_xyevents_i, fakeB_xyevents_i);
        
        % save all distances
        distance_realA_realB = cat(1, distance_realA_realB, distance_neurest_realA_realB);
        distance_fakeB_realB = cat(1, distance_fakeB_realB, distance_neurest_fakeB_realB);
        
        % save values 
        %distance_realA_realB{my_iter} = distance_neurest_realA_realB;
        %distance_fakeB_realB{my_iter} = distance_neurest_fakeB_realB;
    end
    
end

%% plot the counts of the distances to the groundtruth emitter

xy_radius = 50;

figure
histogram(distance_realA_realB)%<xy_radius))
hold on 
histogram(distance_fakeB_realB)%<xy_radius))
hold off

legend 'realA' 'fakeB'
xlabel 'Distance to nearest neighbour groundtruth'
ylabel 'counts'

% average deviation compared to groundtruth:
disp(['Mean of distance realA -> realB: ' num2str(mean(distance_realA_realB(distance_realA_realB<xy_radius))) ...
    ', stdv: ' num2str(var(distance_realA_realB(distance_realA_realB<xy_radius)))])

disp(['Mean of distance fakeB -> realB: ' num2str(mean(distance_fakeB_realB(distance_fakeB_realB<xy_radius))) ...
    ', stdv: ' num2str(var(distance_fakeB_realB(distance_fakeB_realB<xy_radius)))])



%% compute the number of detected emitters within the accuracy regime
n_correct_detected_emitters_realA_realB = sum(distance_realA_realB<xy_radius);
n_correct_detected_emitters_fakeB_realB = sum(distance_fakeB_realB<xy_radius);


% plot the number of events within the threshold over the framenubmers
figure
plot(distance_realA_realB)
hold on 
plot(distance_fakeB_realB)
hold off
legend realA fakeB
xlabel framenumber
ylabel '# of correctly detected frames within threshold circle'


sum(sum_detection_realA_realB)
sum(sum_detection_fakeB_realB)

%% compare the computed result
result_realB = readim([mypath 'result_realB.tif']);
result_realA = readim([mypath 'result_realA.tif']);
result_fakeB = readim([mypath 'result_fakeB.tif']);

cat(3, result_realB, result_realA, result_fakeB)