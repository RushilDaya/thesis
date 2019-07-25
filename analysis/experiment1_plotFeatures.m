% generate a plot of the beamformer feature vectors.
% would be good to look at it for different amounts of averaging.

% define the parameters indices (look at experiment1_genData.m) we are looking for
paradigmIdx = 2;
subject = 3;
sampleRateIdx = 1;
frequencyIdx = 1;
averagingPeriodIdx = 1;
electrodesIdx = 2;

% open the corresponding feature file
numElecConfs = 3;
numRateConfs = 3;
numParaConfs = 3;
numAvesConfs = 3;

c = 1;
configLabel = 0;
for eP = 1:numElecConfs
    for sP = 1:numRateConfs
        for pP = 1:numParaConfs
            for aP = 1:numAvesConfs
                if eP == electrodesIdx & sP == sampleRateIdx & aP == averagingPeriodIdx & pP == paradigmIdx
                    configLabel = c;
                end
                c = c +1;
            end
        end
    end
end
featureFileName = strcat('data/trialFeatures/config',string(configLabel),'.mat');
load(char(featureFileName));
meta = dataset('meta_info');
meta('electrodes')
meta('paradigm')
meta('sampleRate')
meta('n_back_average')

data = dataset('data');
data = data{subject};
data = data{frequencyIdx};

% extract the correct frequency feature  from the training data 
numFeatures = size(data,2) -1;
featuresPerFreq = numFeatures/3;
labels = data(:,end);
features = data(:, featuresPerFreq*(frequencyIdx -1)+1:featuresPerFreq*frequencyIdx);
features = data(:,1:end-1);
events = [];
nonEvents = [];

for i = 1:length(labels)
    if labels(i) == 1
        events = cat(1,events,features(i,:));
    else
        nonEvents = cat(1,nonEvents,features(i,:));
    end
end

events = events(1:20,:);
nonEvents = nonEvents(1:20,:);

figure,plot(events','color',[.0 .0 .5 .1])
hold on
plot(mean(events),'color','b','lineWidth',2)
plot(nonEvents','color',[.0 .5 .0 .1])
hold on 
plot(mean(nonEvents),'color','g','lineWidth',2)


% meanEvent = mean(events);
% plot(meanEvent)
% hold on
% meanNonEvent = mean(nonEvents);
% plot(meanNonEvent)


