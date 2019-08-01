% in this file we calculate the AUC for the single frequency ( known
% frequency) - " we don't prematurally summarise instead write to a file

clear;
clc;
load('data/experiment2allKnownFreq.mat');

paradigms = {'onoff','phase','frequency'};
frequencies = [11,13,15];
THRESHOLD_POINTS = 100;

completeSummary = {};

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
                precisionCurve(isnan(precisionCurve))=1;
                
                
                areaUnderCurve = -1*trapz(recallCurve,precisionCurve);
                rowData = {paradigm,subject,cvFold,frequencies(freqIdx),areaUnderCurve};
                completeSummary=cat(1,completeSummary,rowData);
            end
            
        end
    end
end

tabular = cell2table(completeSummary,'VariableNames',{'paradigm','subject','cvFold','frequency','AUC'});
save('data/experiment2_knownFreq_baseCase.mat','tabular');
    