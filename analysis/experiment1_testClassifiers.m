clear;
clc;
load('data/features.mat');

data = dataset('data');

SUBJECT_ID = 4;
FREQUENCY_ID = 1;

featureSet = data{SUBJECT_ID}{FREQUENCY_ID};