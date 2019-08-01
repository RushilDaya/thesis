clear;
clc;
load('data/experiment2temp.mat')

THRESHOLD_POINTS = 50;


for cvIdx = 1:length(allClassificationData)
    trainingPart = allClassificationData{cvIdx}('training'); 
    testPart = allClassificationData{cvIdx}('test');
    
    
    % we apply the analysis separate for each freq 
    % as we can have a separate classifier for each frequency
    
    for freqIdx = 1:length(trainingPart)
        [minScore,maxScore]=ex2_getMinMaxScore(trainingPart{freqIdx});
        tryThresholds = linspace(minScore,maxScore,THRESHOLD_POINTS);
        
        allMetrics = {};
        for threshIdx = 1:THRESHOLD_POINTS
            threshold = tryThresholds(threshIdx);
            extendedTrials = ex2_binariseEvents(trainingPart{freqIdx},threshold);
            metrics = ex2_computeMetrics(extendedTrials);
            allMetrics{threshIdx} = metrics;
        end
        
    end
    
end