% this is the first TRUE experiment
% aggregation across participants and aims to classify labelled segments
% this is the 'offline' case.
% the aim of this is to establish useful parameters and also see if the
% online case will be viable.
clear;
clc;
WRITE_TO_FILE = 'data/temp.mat';
SUBJECTS = {'data/subject_1/','data/subject_2/','data/subject_3/','data/subject_4/'};
PARADIGM = 'onoff'; %[onoff, frequency, phase]
FREQUENCIES = [11,13,15];
ELECTRODES = {'O1','Oz','O2'};
SAMPLE_RATE = 500;
N_BACK_AVERAGE = 1;

meta_info = containers.Map;
meta_info('subjects') = SUBJECTS;
meta_info('paradigm') = PARADIGM;
meta_info('frequencies')= FREQUENCIES;
meta_info('electrodes') = ELECTRODES;
meta_info('sampleRate') = SAMPLE_RATE;
meta_info('n_back_average')=N_BACK_AVERAGE;



subjectsBeamformers = {};
for subIdx = 1:length(SUBJECTS)
    fileName = strcat(SUBJECTS(subIdx),'training.dat');
    fileName = fileName{1};
    [trainingData,trainingLabels] = rd_preProcessing(fileName,SAMPLE_RATE, ELECTRODES);
    subjectBeamformers = rd_constructBeamformers(trainingData, trainingLabels, SAMPLE_RATE ,FREQUENCIES);
    subjectsBeamformers{subIdx} = subjectBeamformers;
    clear training_data fileName subjectBeamformers
end

subjectsBeamformedTrials = {};
for subIdx = 1:length(SUBJECTS)
    fileName = strcat(SUBJECTS(subIdx),PARADIGM,'.dat');
    fileName = fileName{1};
    [experimentData,experimentLabels] = rd_preProcessing(fileName,SAMPLE_RATE,ELECTRODES);
    subjectTrials = {};
    for freqIdx = 1:length(FREQUENCIES)
        [trials,eventLabelsStart,eventLabelsEnd] = rd_getTrials(experimentData,...
            experimentLabels,FREQUENCIES(freqIdx));
        freqAllTrials = containers.Map;
        freqAllTrials('eventStarts')=eventLabelsStart;
        freqAllTrials('eventEnds')=eventLabelsEnd;
        trialData = {};
        for trialIdx = 1:size(trials,3)
            freqBeamformedTrial = {};
            for freqIdxInner = 1:length(FREQUENCIES)
                beamformedTrial = rd_applyBeamformer(trials(:,:,trialIdx),...
                    subjectsBeamformers{subIdx}{freqIdxInner},FREQUENCIES(freqIdxInner),...
                    SAMPLE_RATE,N_BACK_AVERAGE);
                freqBeamformedTrial{freqIdxInner} = beamformedTrial;
            end
            trialData{trialIdx} = freqBeamformedTrial;
        end
        freqAllTrials('signals')=trialData;
        subjectTrials{freqIdx} = freqAllTrials;
    end
    subjectsBeamformedTrials{subIdx}=subjectTrials;
end




save(WRITE_TO_FILE, 'meta_info','subjectsBeamformedTrials');
clear;
clc;
        




