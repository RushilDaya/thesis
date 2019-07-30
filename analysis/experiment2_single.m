SUBJECT = 3;
PARADIGM = 'onoff';
SAMPLE_RATE = 256;
ELECTRODES = {'O1','Oz','O2','PO3','PO4','Pz','P3','P4','Cz','Fz'};
AVERAGING = 5;
FEATURE_VECTOR_SIZE = 12;
FREQUENCIES = [11,13,15];
CV_FOLDS = 5;

% get the beamformers (in frequency order)
beamformers = ex2_getBeamformers(SUBJECT,SAMPLE_RATE,ELECTRODES,FREQUENCIES);

% load the raw data.
fileName = char(strcat('data/subject_',string(SUBJECT),'/',PARADIGM,'.dat'));
[experimentData,experimentLabels] = rd_preProcessing(fileName,SAMPLE_RATE,ELECTRODES);

% beamform the trials
beamformedTrials = ex2_beamformTrials(experimentData, experimentLabels,...
    beamformers,FREQUENCIES,AVERAGING,SAMPLE_RATE);
clear fileName experimentData experimentLabels

% partition the data into cross-validation ready sets
cv_sets = ex2_cvSplit(beamformedTrials,CV_FOLDS);
clear beamformedTrials

for cvIdx = 1:length(cv_sets)
    beamformedTrials = cv_sets{cvIdx};
    
    % train the classifier
    dataSegments = ex2_getLabelled(beamformedTrials, FREQUENCIES, FEATURE_VECTOR_SIZE, SAMPLE_RATE);
    % datasegments has 3 cells ( one for each frequency)
    classifiers = ex2_trainClassifiers(dataSegments);
end



