clear;
clc;

NUM_ELECTRODES = 8; % a more extensive electrode selection should be implemented
SAMPLE_RATE = 1000; % play with this to control number of free parameters
SUBJECT_TRAINING_FILE = 'data/subject_1/training.dat';
SUBJECT_EXPERIMENT_FILE = 'data/subject_1/phase.dat';
FREQUENCIES = [11,13,15];
FREQUENCY_OF_INTEREST = 11;
PERIOD_AVERAGES = 1; % moving average on the beamformer - larger number should improve performance
N_POINTS_FEATURES = 10; % how many points are used as features around events


[eegTraining, labelsTraining] = rd_preProcessing(SUBJECT_TRAINING_FILE,SAMPLE_RATE,NUM_ELECTRODES);
beamformers = rd_constructBeamformers(eegTraining,labelsTraining, SAMPLE_RATE ,FREQUENCIES);

[eegExperiment, labelsExperiment] = rd_preProcessing(SUBJECT_EXPERIMENT_FILE, SAMPLE_RATE, NUM_ELECTRODES);
[trialAtFrequency, eventLabelsStart, eventLabelsEnd] = rd_getTrials(eegExperiment, labelsExperiment, FREQUENCY_OF_INTEREST);

beamformedOutputs = {};
labelledData = {};
for i = 1:size(FREQUENCIES,2)
    beamformedOutputs{i}=[];
    labelledData{i} = [];
end

for trialIdx = 1:size(trialAtFrequency,3)
    for freqIdx = 1:size(FREQUENCIES,2)
        beamformedTrial = rd_applyBeamformer(trialAtFrequency(:,:,trialIdx),beamformers{freqIdx},FREQUENCIES(freqIdx),SAMPLE_RATE,PERIOD_AVERAGES);
        beamformedOutputs{freqIdx} = cat(3,beamformedOutputs{freqIdx}, beamformedTrial);
    end
end

signalTimeActual = size(trialAtFrequency,2)/SAMPLE_RATE;
horizontal_axes = linspace(0,signalTimeActual,signalTimeActual*SAMPLE_RATE);

for freqIdx = 1:size(FREQUENCIES,2)
    [labelledData{freqIdx},labels] = rd_generateLabelled(beamformedOutputs{freqIdx},eventLabelsStart, eventLabelsEnd, N_POINTS_FEATURES,SAMPLE_RATE,FREQUENCIES(freqIdx));
end

[labelledData,labels] = rd_randomiseLabels(labelledData,labels);

formattedData = [];
for i = 1:size(labels,2)
    singleRow = [];
    for  j = 1:size(FREQUENCIES,2)
        partial = labelledData{j}(1,:,i)-mean(labelledData{j}(1,:,i));
        singleRow = cat(2,singleRow,partial);
    end
    formattedData = cat(3,formattedData,singleRow);
end
formattedData = reshape(formattedData,[size(formattedData,2),size(formattedData,3)])';
labels = labels';

featureSet = cat(2,formattedData,labels);




