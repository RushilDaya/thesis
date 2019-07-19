clear;
clc;
load('data/features.mat');

data = dataset('data');

SUBJECT_ID = 1;
FREQUENCY_ID = 3;

featureSet = data{SUBJECT_ID}{FREQUENCY_ID};