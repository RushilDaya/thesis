% 1. define the subject - create the three beamformers for that subject.
clear;
clc;

NUM_ELECTRODES = 8; % a more extensive electrode selection should be implemented
SAMPLE_RATE = 500; % play with this to control number of free parameters
SUBJECT_TRAINING_FILE = 'data/subject_1/training.dat';
FREQUENCIES = [11,13,15];

[eegTraining, labelsTraining] = rd_preProcessing(SUBJECT_TRAINING_FILE,SAMPLE_RATE,NUM_ELECTRODES);
beamformers = rd_constructBeamformers(eegTraining,labelsTraining, SAMPLE_RATE ,FREQUENCIES);
