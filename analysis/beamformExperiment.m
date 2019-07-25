% 1. define the subject - create the three beamformers for that subject.
clear;
clc;

NUM_ELECTRODES = {'O1','Oz','O2','PO3','PO4','Pz','P3','P4','Cz','Fz'}; % a more extensive electrode selection should be implemented
SAMPLE_RATE = 256; % play with this to control number of free parameters
SUBJECT_TRAINING_FILE = 'data/subject_3/training.dat';
SUBJECT_EXPERIMENT_FILE = 'data/subject_3/phase.dat';
FREQUENCIES = [11,13,15];
FREQUENCY_OF_INTEREST = 13;
PERIOD_AVERAGES = 1; % moving average on the beamformer - larger number should improve performance



[eegTraining, labelsTraining] = rd_preProcessing(SUBJECT_TRAINING_FILE,SAMPLE_RATE,NUM_ELECTRODES);
beamformers = rd_constructBeamformers(eegTraining,labelsTraining, SAMPLE_RATE ,FREQUENCIES);

[eegExperiment, labelsExperiment] = rd_preProcessing(SUBJECT_EXPERIMENT_FILE, SAMPLE_RATE, NUM_ELECTRODES);
[trialAtFrequency, eventLabelsStart, eventLabelsEnd] = rd_getTrials(eegExperiment, labelsExperiment, FREQUENCY_OF_INTEREST);

signalTimeActual = size(trialAtFrequency,2)/SAMPLE_RATE;
horizontal_axes = linspace(0,signalTimeActual,signalTimeActual*SAMPLE_RATE);

for trialIdx = 1:size(trialAtFrequency,3)
    figure;
   
    for eventIdx = 1:size(eventLabelsStart,2)
        leftX = eventLabelsStart(1,eventIdx, trialIdx)/SAMPLE_RATE;
        rightX = eventLabelsEnd(1,eventIdx, trialIdx)/SAMPLE_RATE;
        width = rightX - leftX;
        rectangle('Position',[leftX,-2,width,4],'FaceColor',[.9 .9 .9]);
        hold on;        
    end

    for freqIdx = 1:size(FREQUENCIES,2)
        beamformedTrial = rd_applyBeamformer(trialAtFrequency(:,:,trialIdx),beamformers{freqIdx},FREQUENCIES(freqIdx),SAMPLE_RATE,PERIOD_AVERAGES);
        beamformedTrial = rd_strechSignal(beamformedTrial,SAMPLE_RATE,FREQUENCIES(freqIdx),signalTimeActual);
        plot(horizontal_axes,beamformedTrial,'LineWidth',1.5);
        hold on;
    end
    legend('11 Hz','13 Hz','15 Hz');
end