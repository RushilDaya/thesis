% this script goes from the segmented training data to labeled feature
% vectors
% once validated this script should be integrated into the genData script.
clear;
clc;

DATA_ROOT = 'data/trialData/config';
FEATURES_ROOT = 'data/trialFeatures/config';
for configIdx = 1:81
    LOAD_FILE_NAME = char(strcat(DATA_ROOT,string(configIdx),'.mat'));
    SAVE_FILE_NAME = char(strcat(FEATURES_ROOT,string(configIdx),'.mat'));
    
    load(LOAD_FILE_NAME);
    N_FEATURE_POINTS = 12;

    SUBJECTS = meta_info('subjects');
    PARADIGM = meta_info('paradigm');
    FREQUENCIES = meta_info('frequencies');
    ELECTRODES = meta_info('electrodes');
    SAMPLE_RATE = meta_info('sampleRate');
    DATA = subjectsBeamformedTrials;
    clear subjectsBeamformedTrials;

    dataset = containers.Map;
    dataset('meta_info')=meta_info;


    subjectData = {};
    for subIdx = 1:length(SUBJECTS)
        frequencyTrials = {};
        for trialFreqIdx = 1:length(FREQUENCIES)
            eventStarts = DATA{subIdx}{trialFreqIdx}('eventStarts');
            eventEnds = DATA{subIdx}{trialFreqIdx}('eventEnds');
            beamformedTrials = DATA{subIdx}{trialFreqIdx}('signals');

            %compatibility hack
            trailsFreqSplit = {};
            for i = 1:length(FREQUENCIES)
                trialsFreqSplit{i} = [];
                for j = 1:size(beamformedTrials,2)
                    trialsFreqSplit{i} = cat(3,trialsFreqSplit{i},beamformedTrials{j}{i});
                end
            end

            featureVector = [];
            for bfFreqIdx = 1:length(FREQUENCIES)
                [segments,labels]= rd_generateLabelled(trialsFreqSplit{bfFreqIdx},eventStarts,eventEnds,...
                    N_FEATURE_POINTS, SAMPLE_RATE,FREQUENCIES(bfFreqIdx));
                segments = reshape(segments,[size(segments,2),size(segments,3)])';
                segments = segments - mean(segments);
                featureVector=cat(2,featureVector,segments);
            end
            labels = labels'; % bad way of generating labels
            combinedMatrix = cat(2,featureVector,labels);
            scrambleIdx = randperm(size(combinedMatrix,1));
            combinedMatrix = combinedMatrix(scrambleIdx,:);
            frequencyTrials{trialFreqIdx} = combinedMatrix;
        end
        subjectData{subIdx} = frequencyTrials;
    end
    dataset('data')=subjectData;
    save(SAVE_FILE_NAME,'dataset');   
    
    
end
    


