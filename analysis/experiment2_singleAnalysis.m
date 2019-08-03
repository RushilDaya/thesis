clear;
clc;
load('data/experiment2temp.mat')

THRESHOLD_POINTS = 100;


for cvIdx = 1:length(allClassificationData)
    trainingPart = allClassificationData{cvIdx}('training'); 
    testPart = allClassificationData{cvIdx}('test');
    
    
    % we apply the analysis separate for each freq 
    % as we can have a separate classifier for each frequency
    
    for freqIdx = 1:length(trainingPart)
        minScore = -10;
        maxScore = 20; % from empirical results
        tryThresholds = linspace(minScore,maxScore,THRESHOLD_POINTS);
        
        allMetrics = {};
        for threshIdx = 1:THRESHOLD_POINTS
            threshold = tryThresholds(threshIdx);
            extendedTrials = ex2_binariseEvents(testPart{freqIdx},threshold);
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
        
        
        % make recall adjustment ( obtain a more hull like characteristic
        recallModified = flip(recallCurve);
        for  i = 2:length(recallModified)
            if recallModified(i) < recallModified(i-1)
                recallModified(i) = recallModified(i-1);
            end     
        end
        recallCurve = flip(recallModified);
        
        
        plotableThreshold = tryThresholds-min(tryThresholds);
        plotableThreshold = plotableThreshold/max(plotableThreshold);
        
        
        % a pseudo area under curve calculation
        precisionCurve(isnan(precisionCurve))=1;
        areaUnderCurve = -1*trapz(recallCurve,precisionCurve)
        
        
        figure,plot(recallCurve,precisionCurve,'LineWidth',1.8);
        %xlim([0,1]),ylim([0,1]);
        hold on;
        yyaxis right;
        plot(recallCurve,tryThresholds,'--');
        %ylim([-4,4]);
        
        
    end
    
end