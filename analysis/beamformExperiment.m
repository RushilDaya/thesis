% 1. define the subject - create the three beamformers for that subject.
clear;
clc;

NUM_ELECTRODES = 3; % a more extensive electrode selection should be implemented
SAMPLE_RATE = 500; % play with this to control number of free parameters
SUBJECT_TRAINING_FILE = 'data/subject_1/training.dat';
SUBJECT_EXPERIMENT_FILE = 'data/subject_1/phase.dat';
FREQUENCIES = [11,13,15];
FREQUENCY_OF_INTEREST = 13;
PERIOD_AVERAGES = 5; % moving average on the beamformer - larger number should improve performance


[eegTraining, labelsTraining] = rd_preProcessing(SUBJECT_TRAINING_FILE,SAMPLE_RATE,NUM_ELECTRODES);
beamformers = rd_constructBeamformers(eegTraining,labelsTraining, SAMPLE_RATE ,FREQUENCIES);

[eegExperiment, labelsExperiment] = rd_preProcessing(SUBJECT_EXPERIMENT_FILE, SAMPLE_RATE, NUM_ELECTRODES);
[trialAtFrequency, eventLabelsStart, eventLabelsEnd] = rd_getTrials(eegExperiment, labelsExperiment, FREQUENCY_OF_INTEREST);

signalTimeActual = size(trailAtFrequency,2)/SAMPLE_RATE;

for trialIdx = 1:size(trialAtFrequency,3)
    figure;
    for freqIdx = 1:size(FREQUENCIES,2)
        beamformedTrial = rd_applyBeamformer(trialAtFrequency(:,:,trialIdx),beamformers{freqIdx},FREQUENCIES(freqIdx),SAMPLE_RATE,PERIOD_AVERAGES);
        beamformedTrial = rd_strechSignal(beamformedTrial,SAMPLE_RATE, signalTimeActual );
        hold on;
    end
end