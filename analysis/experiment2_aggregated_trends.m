% here we want to generate 2 curves
% firstly the easy one : which is the threshold curves across all subjects
% paradigms and subjects

clear;
clc;
load('data/experiment2allKnownFreq.mat');

paradigms = {'onoff','phase','frequency'};
frequencies = [11,13,15];
THRESHOLD_POINTS = 100;

completeSummary = {};

allF1Curves = [];
allRecallsAtBest = [];
allPrecisionsAtBest = [];

for paradigmIdx = 1:length(paradigms)
    paradigm = paradigms{paradigmIdx};
    paradigmData = superStructure{paradigmIdx};
    for subject = 1:length(paradigmData)
        subjectData = paradigmData{subject};
        for cvFold  = 1:length(subjectData)
            foldData = subjectData{cvFold};
            testPart = foldData('test');
            
            for freqIdx = 1:length(testPart)
                [minScore,maxScore]=ex2_getMinMaxScore(testPart{freqIdx});
                tryThresholds = linspace(-1,2,THRESHOLD_POINTS);

                allMetrics = {};
                for threshIdx = 1:THRESHOLD_POINTS
                    threshold = tryThresholds(threshIdx);
                    extendedTrials = ex2_binariseEventsModified(testPart{freqIdx},threshold);
                    % we use the extended trials to compute a graph of lag
                    % times
                    metrics = ex2_computeMetricsModified(extendedTrials,10);
                    allMetrics{threshIdx} = metrics;
                end
                % the key metric we want to show is the precision recall curves
                precisionCurve = [];
                recallCurve = [];
                f1Curve = [];
                for i = 1:THRESHOLD_POINTS
                    precision = allMetrics{i}('truePositives')/(allMetrics{i}('truePositives')+allMetrics{i}('falsePositives'));
                    recall = allMetrics{i}('truePositives')/(allMetrics{i}('truePositives')+allMetrics{i}('falseNegatives'));
                    allMetrics{i}('truePositives')+allMetrics{i}('falseNegatives');
                    f1 = 2*(recall*precision)/(recall+precision);
                    precisionCurve = [precisionCurve, precision];
                    recallCurve = [recallCurve, recall];
                    f1Curve = [f1Curve,f1];
                end
                allF1Curves = cat(1,allF1Curves,f1Curve);
                f1Best = max(f1Curve);
                
                
                %------- find the best precision and recall points
                subBestIndices = find(f1Curve==f1Best);
                subBestRecalls = recallCurve(subBestIndices);
                subBestPrecions = precisionCurve(subBestIndices);
                allRecallsAtBest = [allRecallsAtBest,subBestRecalls];
                allPrecisionsAtBest = [allPrecisionsAtBest,subBestPrecions];
                %-------------------------------------------------
                
                threshBest = tryThresholds(find(f1Curve == f1Best));
                threshBest = mean(threshBest);
                rowData = {paradigm,subject,cvFold,frequencies(freqIdx),f1Best,threshBest};
                completeSummary=cat(1,completeSummary,rowData);
            end
            
        end
    end
end

% subfigure showing aggreagated trends
meanF1Curve = nanmean(allF1Curves,1);
stdF1Curve = nanstd(allF1Curves);
upperBound = meanF1Curve + stdF1Curve;
lowerBound = meanF1Curve - stdF1Curve;

figure('Renderer', 'painters', 'Position', [10 10 900 900]);
plot(tryThresholds,allF1Curves,'Color',[0.7 0.7 0.7 0.5]),hold on;
plot(tryThresholds,meanF1Curve,'LineWidth',2.5, 'Color',[0 0 0]),hold on;
plot(tryThresholds,upperBound ,'LineWidth',2.5, 'Color',[1 0 0], 'LineStyle',':');
plot(tryThresholds,lowerBound ,'LineWidth',2.5, 'Color',[1 0 0], 'LineStyle',':');
xlabel('Threshold Values');
ylabel('f1 Score');

figure('Renderer', 'painters', 'Position', [10 10 900 900]);
jitterAmount = 0.08;
noise1 = jitterAmount*rand([1 length(allRecallsAtBest)]);
noise2 = jitterAmount*rand([1 length(allRecallsAtBest)]);

xNoise = allRecallsAtBest+noise1;
yNoise = allPrecisionsAtBest+noise2;

scatter(xNoise,yNoise,15,[1 0 0.3],'filled'),xlim([0 1]),ylim([0 1]),hold on;
line([0 1],[0 1],'Color',[0.3 0 0.2],'LineStyle','-','LineWidth',2);
line([0 1],[0.25 1.25],'Color',[0.3 0 0.2],'LineStyle','--','LineWidth',2);
line([0 1],[-0.25 0.75],'Color',[0.3 0 0.2],'LineStyle','--','LineWidth',2);
xlabel('Recall');
ylabel('Precision');
    
    
    
    