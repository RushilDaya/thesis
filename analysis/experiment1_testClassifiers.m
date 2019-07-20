clear;
clc;
load('data/features.mat');

data = dataset('data');

SUBJECT_ID = 1;
FREQUENCY_ID = 3;

featureSet = data{SUBJECT_ID}{FREQUENCY_ID};

[ trainedClassifier, validationPredictions ] = rd_classifierQSVM(featureSet,5);

truePred = featureSet(:,37);
error =  sum(abs(truePred - validationPredictions)); 
100-error