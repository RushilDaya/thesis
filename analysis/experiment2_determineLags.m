
clear;
clc;

% want to determine whats a good lag estimate 
THRESHOLDS = linspace(-4,4,40);
PARADIGM_IDX = 3; % best performing onoff
load('data/experiment2allKnownFreq.mat');

lagByThresh = [];
for threshIdx = 1:length(THRESHOLDS)
    THRESHOLD = THRESHOLDS(threshIdx);
    allLags = [];
    paradigmData = superStructure{PARADIGM_IDX};
    for subject = 1:length(paradigmData)
        subjectData = paradigmData{subject};
        for cvFold  = 1:length(subjectData)
            foldData = subjectData{cvFold};
            trainingPart = foldData('training');

            for freqIdx = 1:length(trainingPart)
                extendedTrials = ex2_binariseEventsModified(trainingPart{freqIdx},THRESHOLD);
                lags = ex2_getLags(extendedTrials);
                allLags = [allLags,lags];
            end

        end
    end
    allLags = allLags(allLags < 20);
    binnedLags = histcounts(allLags);
    binnedLags = [binnedLags,zeros(1,20-length(binnedLags))];
    lagByThresh = cat(1,lagByThresh,binnedLags);
end
 figure, surf(linspace(0,19,20),THRESHOLDS,lagByThresh), colorbar,shading interp,xlabel('Delay between actual and predicted event'),ylabel('Threshold');