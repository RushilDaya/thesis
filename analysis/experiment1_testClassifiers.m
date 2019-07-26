clear;
clc;

allResultsRows = {};
saveFile = 'data/experiment1Results14.mat';
numConfigs = 81
FEATURE_FILE_ROOT = 'data/trialFeatures/config';

for configIdx = 1:numConfigs
    FEATURE_FILE = char(strcat(FEATURE_FILE_ROOT,string(configIdx),'.mat'));
    load(FEATURE_FILE);

    data = dataset('data');
    meta_info = dataset('meta_info');

    electrodes = meta_info('electrodes');
    numElectrodes = length(electrodes);
    frequencies = meta_info('frequencies');
    numFrequencies = length(frequencies);
    averagingPeriod = meta_info('n_back_average');
    paradigm = meta_info('paradigm');
    sampleRate=meta_info('sampleRate');
    subjects=meta_info('subjects');
    numSubjects = length(subjects);
    featureSizes = [12,8,4];
    numFeatureSizes = length(featureSizes);

    for subjectIdx = 1:numSubjects
        for frequencyIdx = 1:numFrequencies
            for numFeaturesIdx = 1:numFeatureSizes
                featureSet = data{subjectIdx}{frequencyIdx};
                featureSet = rd_isolateFreqFeatures(featureSet,frequencyIdx,numFrequencies);
                featureSet = rd_reduceFeatures(featureSet, featureSizes(numFeaturesIdx));
                [ trainedClassifier, validationPredictions ] = rd_classifierQSVM(featureSet,5);
                qsvmAcc = rd_computeAccuracy(validationPredictions,featureSet(:,end));
                [ trainedClassifier, validationPredictions ] = rd_classifierLSVM(featureSet,5);
                lsvmAcc = rd_computeAccuracy(validationPredictions,featureSet(:,end));
                [ trainedClassifier, validationPredictions ] = rd_classifierLDA(featureSet,5);
                ldaAcc = rd_computeAccuracy(validationPredictions,featureSet(:,end));
                [ trainedClassifier, validationPredictions ] = rd_classifierQDA(featureSet,5);
                qdaAcc = rd_computeAccuracy(validationPredictions,featureSet(:,end));

                outputRow = {numElectrodes,averagingPeriod,paradigm,sampleRate,...
                    subjectIdx, frequencies(frequencyIdx),featureSizes(numFeaturesIdx),...
                    qsvmAcc,lsvmAcc,ldaAcc,qdaAcc};
                allResultsRows = cat(1,allResultsRows,outputRow);

            end
        end
    end
end
save(saveFile,'allResultsRows');
