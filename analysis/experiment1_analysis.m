% look at the data generated from the first experiment ( the classifier
% results)
clear
clc
load('data/experiment1ResultsAll.mat');

inputData = cell2table(allResultsRows,'VariableNames',{'electrodes','averagePeriod',...
    'paradigm','sampleRate','subject','frequency','numFeatures',...
    'qsvmAcc','lsvmAcc','ldaAcc','qdaAcc'});


% first compute the averages across frequency and subject 
electrodes = [10];
sampleRates = [256];
paradigms = {'onoff','phase','frequency'};
averagePeriods = [5];
numFeatures = [12];

summary = {};
for paradigmIdx = 1:length(paradigms)
 for electrodesIdx = 1:length(electrodes)
    for sampleRateIdx = 1:length(sampleRates)
        for averagePeriodIdx = 1:length(averagePeriods)
           for numFeaturesIdx = 1:length(numFeatures)

                AVERAGE_PERIOD = averagePeriods(averagePeriodIdx);
                ELECTRODES = electrodes(electrodesIdx);
                SAMPLE_RATE = sampleRates(sampleRateIdx);
                NUM_FEATURES = numFeatures(numFeaturesIdx);
                POI = paradigms{paradigmIdx};
                
                
                data = inputData(strcmp(inputData.paradigm,POI),:);
                data = data(data.averagePeriod == AVERAGE_PERIOD,:);
                data = data(data.electrodes == ELECTRODES,:);
                data = data(data.sampleRate == SAMPLE_RATE,:);
                data = data(data.numFeatures == NUM_FEATURES,:);

                meanLSVM = mean(data.lsvmAcc);
                meanQSVM = mean(data.qsvmAcc);
                meanLDA = mean(data.ldaAcc);
                meanQDA = mean(data.qdaAcc);     
                
                outputRow = {POI,ELECTRODES,SAMPLE_RATE,AVERAGE_PERIOD,NUM_FEATURES,...
                    meanLSVM,meanQSVM,meanLDA,meanQDA};
                summary = cat(1,summary,outputRow);
            end
        end
    end
 end
end
summary = cell2table(summary,'VariableNames',{'paradigm','electrodes','sampleRate',...
    'averagePeriod','numFeatures',...
    'qsvmAcc','lsvmAcc','ldaAcc','qdaAcc'});

% then we want to look at the performance of the differnt classfiers as a
% function of the experimental parameters

byParadigm = grpstats(summary,{'paradigm'},{'min','max','mean','std'},'DataVars',{'qsvmAcc','lsvmAcc','ldaAcc','qdaAcc'})
byElectrodes = grpstats(summary,{'electrodes'},{'min','max','mean','std'},'DataVars',{'qsvmAcc','lsvmAcc','ldaAcc','qdaAcc'})
bySampleRate = grpstats(summary,{'sampleRate'},{'min','max','mean','std'},'DataVars',{'qsvmAcc','lsvmAcc','ldaAcc','qdaAcc'})
byAveragePeriod = grpstats(summary,{'averagePeriod'},{'min','max','mean','std'},'DataVars',{'qsvmAcc','lsvmAcc','ldaAcc','qdaAcc'})
byNumFeatures = grpstats(summary,{'numFeatures'},{'min','max','mean','std'},'DataVars',{'qsvmAcc','lsvmAcc','ldaAcc','qdaAcc'})


% visually lets take the parameters which seemingly provide the best
% performance
PARADIGM = 'phase';
ELECTRODES = 10 ;
SAMPLE_RATE = 512;
AVERAGE_PERIOD = 1;
NUM_FEATURES = 12;


best = inputData;
best = best(strcmp(best.paradigm, PARADIGM),:);
best = best(best.averagePeriod == AVERAGE_PERIOD,:);
best = best(best.electrodes == ELECTRODES,:);
best = best(best.sampleRate == SAMPLE_RATE,:);
best = best(best.numFeatures == NUM_FEATURES,:);

bestBySubject = grpstats(best,{'subject'},{'min','max','mean','std'},'DataVars',{'qsvmAcc','lsvmAcc','ldaAcc','qdaAcc'})
bestByFrequency = grpstats(best,{'frequency'},{'min','max','mean','std'},'DataVars',{'qsvmAcc','lsvmAcc','ldaAcc','qdaAcc'})