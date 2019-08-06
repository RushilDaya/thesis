% clear;
% clc;
% load('data/experiment2temp.mat')
% 
% THRESHOLD_POINTS = 100;
% 
% allPrecCV = {};
% allRecallCV = {};
% allF1CV = {};
% 
% for cvIdx = 1:length(allClassificationData)
%     trainingPart = allClassificationData{cvIdx}('training'); 
%     testPart = allClassificationData{cvIdx}('test');
%     
%     
%     % we apply the analysis separate for each freq 
%     % as we can have a separate classifier for each frequency
%     %figure
%     allExtendedFreq = {};
%     allPrecFreq = {};
%     allRecallFreq = {};
%     allF1CurveFreq = {};
%     for freqIdx = 1:length(trainingPart)
%         minScore = -1;
%         maxScore = 2; % from empirical results
%         tryThresholds = linspace(minScore,maxScore,THRESHOLD_POINTS);
%         
%         allMetrics = {};
%         allExtended = {};
%         for threshIdx = 1:THRESHOLD_POINTS
%             threshold = tryThresholds(threshIdx);
%             extendedTrials = ex2_binariseEvents(testPart{freqIdx},threshold);
%             storable = {};
%             for itemIdx = 1:length(extendedTrials)
%                 storable{itemIdx} = containers.Map(extendedTrials{itemIdx}.keys,extendedTrials{itemIdx}.values);
%             end
%             allExtended{threshIdx} = storable;
%             metrics = ex2_computeMetricsModified(extendedTrials,10);
%             allMetrics{threshIdx} = metrics;
%         end
%         allExtendedFreq{freqIdx} = allExtended;
%         
%         % the key metric we want to show is the precision recall curves
%         precisionCurve = [];
%         recallCurve = [];
%         f1Curve = [];
%         for i = 1:THRESHOLD_POINTS
%             precision = allMetrics{i}('truePositives')/(allMetrics{i}('truePositives')+allMetrics{i}('falsePositives'));
%             recall = allMetrics{i}('truePositives')/(allMetrics{i}('truePositives')+allMetrics{i}('falseNegatives'));
%             f1 = 2*(precision*recall)/(recall+precision);
%             precisionCurve = [precisionCurve, precision];
%             recallCurve = [recallCurve, recall];
%             f1Curve = [f1Curve,f1];
%         end
%         allPrecFreq{freqIdx} = precisionCurve;
%         allRecallFreq{freqIdx} = recallCurve;
%         allF1CurveFreq{freqIdx} = f1Curve;
%         
%         
%         
% %         % make recall adjustment ( obtain a more hull like characteristic
% %         recallModified = flip(recallCurve);
% %         for  i = 2:length(recallModified)
% %             if recallModified(i) < recallModified(i-1)
% %                 recallModified(i) = recallModified(i-1);
% %             end     
% %         end
% %         recallCurve = flip(recallModified);
% %         
% %         plotableThreshold = tryThresholds-min(tryThresholds);
% %         plotableThreshold = plotableThreshold/max(plotableThreshold);
% %         
% %         
% %         % a pseudo area under curve calculation
% %         precisionCurve(isnan(precisionCurve))=1;
% %         areaUnderCurve = -1*trapz(recallCurve,precisionCurve)
%         
%         
% %          plot(tryThresholds,f1Curve,'LineWidth',1.8);
% %          ylim([0,1]);
% %          hold on
% %         hold on;
% %         yyaxis right;
% %         plot(recallCurve,tryThresholds,'--');
% %         %ylim([-4,4]);
%         
%         
%     end
%     
%     allPrecCV{cvIdx} = allPrecFreq;
%     allRecallCV{cvIdx} = allRecallFreq;
%     allF1CV{cvIdx} = allF1CurveFreq;
%     
% end


% subscript for the looking at an f-score as a function of the threshold 

% as well as the same function for the looking at the precision recall
% curves ( here we overly the validation folds so thre is no point in
% overlying the thresholds ( just the frequencies and the curves) 

freqIdx = 1;
colorset = {[0.2 0.2 1],[1 0.2 0.2],[0.8 0.2 0.8],[0.8 0.8 0.2],[0.2 0.8 0.8]};
% plot all the f1 curves for this one particular frequency
figure

for i = 1:5
    f1Part = allF1CV{i}{freqIdx};
    f1Part(isnan(f1Part))=0;
    maxf1 = max(f1Part);
    bestIndices = find(f1Part == maxf1);
    
    for j = 1:length(bestIndices)
        line([tryThresholds(bestIndices(j)),tryThresholds(bestIndices(j))],[0,maxf1],...
            'LineWidth',0.8,'Color',colorset{i}),hold on;
    end
    
    
end

for i = 1:5
    f1Part = allF1CV{i}{freqIdx};
    f1Part(isnan(f1Part))=0;
    plot(tryThresholds,f1Part,'LineWidth',1.5,'Color',colorset{i}) ,hold on;
    xlabel('threshold');
    ylabel('f1 score');
end

figure
for freqIdx = 1:3
for i = 1:5
    recallPart = allRecallCV{i}{freqIdx};
    precisionPart = allPrecCV{i}{freqIdx};
    precisionPart(isnan(precisionPart))=0;
    f1Part = allF1CV{i}{freqIdx};
    recallPart(isnan(recallPart))=0;
    
%     [hullIndices,volume]=convhull(recallPart,precisionPart);
%     hullPrec = precisionPart(hullIndices);
%     hullRec = recallPart(hullIndices);
%     plot(hullRec,hullPrec, 'Color',colorset{i},'LineWidth',2.5),hold on;
%     
%     plot(recallPart,precisionPart,'Color',colorset{i},'LineWidth',0.5);
%     xlabel('Recall');
%     ylabel('Precision');
%     hold on;
    
    % we need to limit results to monotonic recall
%     recallPart = flip(recallPart);
%       for  j = 2:length(recallPart)
%         if recallPart(j) < recallPart(j-1)
%              recallPart(j) = recallPart(j-1);
%         end     
%       end
%     recallPart = flip(recallPart); 
    
    
    % place some dots on the points which haev maximal f1 scores.
    f1max = max(f1Part);
    maxf1Points = find(f1Part == f1max);
    for jj = 1
        scatter(recallPart(maxf1Points(jj))+rand*0.05,precisionPart(maxf1Points(jj))+rand*0.01,30,colorset{freqIdx},'filled'),...
        xlim([0 1]),ylim([0 1]),hold on;
    end
    xlabel('Recall');
    ylabel('Precision');
%     
%     % trim off the unsightly vertical lines on the precision curves
%     recallWall = recallPart(1);
%     recallWallIdxs = find(recallPart == recallWall);
%     lastWallPoint = recallWallIdxs(end);
%     
%     recallPartTrimed = recallPart(lastWallPoint-1:end);
%     precisionPartTrimed = precisionPart(lastWallPoint-1:end);
%     
%     
%     plot(recallPart,precisionPart,'Color',colorset{i},'LineWidth',2.5),hold on;
%     xlabel('Recall');
%     ylabel('Precision');
end
end



% % subscript to generate plots based on the allExtendedFreq structure
% frIdx = 1;
% thresholds = [0.5,1,1.95];
% tr = 1;
% 
% for thresholdIdx = 1:length(thresholds)
% 
% threshold = thresholds(thresholdIdx);    
%     
% temp = tryThresholds(tryThresholds > threshold);
% threshIdx = find(tryThresholds==temp(1));
% 
% trialsOfInterest = allExtendedFreq{frIdx}{threshIdx}{tr};
% 
% bfed = trialsOfInterest('input');
% cscore = trialsOfInterest('predictions');
% events = find(trialsOfInterest('events'));
% predicts = find(trialsOfInterest('eventPredictions'));
% 
% threshLine = threshold*ones(1,length(bfed));
% 
% figure('Renderer', 'painters', 'Position', [10 10 1500 600]),plot(bfed,'LineWidth',1),hold on;
% 
% % plot all the actual events
% for eventIdx = 1:length(events)
%     line([events(eventIdx),events(eventIdx)],[  min(bfed)   , max(bfed) ],'Color','blue','LineStyle','--','LineWidth',2 );
% end
% 
% for eventIdx = 1:length(predicts)
%     line([predicts(eventIdx),predicts(eventIdx)],[  min(bfed)   , max(bfed) ],'Color','red' );
% end
% 
% yyaxis right, plot(cscore,'LineWidth',1.5,'Color','red');
% plot(threshLine, 'Color',[0 0 0],'LineStyle','-');
% 
% end



