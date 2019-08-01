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
        
        % the key metric we want to show is the precision recall curves
        precisionCurve = [];
        recallCurve = [];
        for i = 1:THRESHOLD_POINTS
            precision = allMetrics{i}('truePositives')/(allMetrics{i}('truePositives')+allMetrics{i}('falsePositives'));
            recall = allMetrics{i}('truePositives')/(allMetrics{i}('truePositives')+allMetrics{i}('falseNegatives'));
            precisionCurve = [precisionCurve, precision];
            recallCurve = [recallCurve, recall];
        end
        
        % for visual purposes it doesn't make sense to consider points
        % after maximum recall
        bestRecall = max(recallCurve);
        bestRecallIdx = find(recallCurve == bestRecall);
        recallCurve(1:bestRecallIdx) = bestRecall;
        
        plotableThreshold = tryThresholds-min(tryThresholds);
        plotableThreshold = plotableThreshold/max(plotableThreshold);
        
        
        
        figure,plot(recallCurve,precisionCurve,'LineWidth',1.8);
        xlim([0,1]),ylim([0,1]);
        hold on;
        yyaxis right;
        plot(recallCurve,tryThresholds,'--');
        ylim([-4,4]);
        
        
    end
    
end