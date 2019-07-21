% look at the data generated from the first experiment ( the classifier
% results)
clear
clc
load('data/experiment1Results.mat');

inputData = cell2table(allResultsRows,'VariableNames',{'electrodes','averagePeriod',...
    'paradigm','sampleRate','subject','frequency','numFeatures',...
    'qsvmAcc','lsvmAcc','ldaAcc','qdaAcc'});

POI = 'phase';

averagePeriods = [1];
electrodes = [3,6,10];
sampleRates = [256,512,1024];
numFeatures = [12];

summary = {};
 for electrodesIdx = 1:length(electrodes)
    for sampleRateIdx = 1:length(sampleRates)
        for averagePeriodIdx = 1:length(averagePeriods)
           for numFeaturesIdx = 1:length(numFeatures)

                AVERAGE_PERIOD = averagePeriods(averagePeriodIdx);
                ELECTRODES = electrodes(electrodesIdx);
                SAMPLE_RATE = sampleRates(sampleRateIdx);
                NUM_FEATURES = numFeatures(numFeaturesIdx);
                
                
                data = inputData(strcmp(inputData.paradigm,POI),:);
                data = data(data.averagePeriod == AVERAGE_PERIOD,:);
                data = data(data.electrodes == ELECTRODES,:);
                data = data(data.sampleRate == SAMPLE_RATE,:);
                data = data(data.numFeatures == NUM_FEATURES,:);

                meanLSVM = mean(data.lsvmAcc);
                meanQSVM = mean(data.qsvmAcc);
                meanLDA = mean(data.ldaAcc);
                meanQDA = mean(data.qdaAcc);     
                
                outputRow = {ELECTRODES,SAMPLE_RATE,AVERAGE_PERIOD,NUM_FEATURES,...
                    meanLSVM,meanQSVM,meanLDA,meanQDA};
                summary = cat(1,summary,outputRow);
            end
        end
    end
end
