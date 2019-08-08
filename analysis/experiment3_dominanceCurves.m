% create large matrices for each paradigm. goes across frequencies,
% subjects and trials..
SUBJECTS = [1,2,3,4,5];
SAMPLE_RATE = 256;
ELECTRODES = {'O1','Oz','O2','PO3','PO4','Pz','P3','P4','Cz','Fz'};
AVERAGING = 5;
FEATURE_VECTOR_SIZE = 12;
FREQUENCIES = [11,13,15];
PARADIGM = 'onoff';
RESCALE_POINTS = 200;

subjectBeamformers = {}
subjectFileNames = {};
for subjectIdx = 1:length(SUBJECTS)
    SUBJECT = SUBJECTS(subjectIdx);
    beamformers = ex2_getBeamformers(SUBJECT,SAMPLE_RATE,...
        ELECTRODES,FREQUENCIES);
    subjectBeamformers{subjectIdx}=beamformers;
    subjectFileNames{subjectIdx} = char(strcat('data/subject_',...
        string(SUBJECT),'/',PARADIGM,'.dat'));
end
clear beamformers subjectIdx;

subjectExperimentalData ={};
subjectLabels = {};
for subjectIdx = 1:length(SUBJECTS)
    [expData,expLabels]=rd_preProcessing(subjectFileNames{subjectIdx},...
        SAMPLE_RATE,ELECTRODES);
    subjectExperimentalData{subjectIdx}=expData;
    subjectLabels{subjectIdx}=expLabels;
end
clear expData expLabels;

subjectBeamformedTrials = {};
for subjectIdx = 1:length(SUBJECTS)
    expData = subjectExperimentalData{subjectIdx};
    expLabels = subjectLabels{subjectIdx};
    subjectBeamformedTrials{subjectIdx} = ex2_beamformTrials(expData,...
        expLabels,subjectBeamformers{subjectIdx},FREQUENCIES,...
        AVERAGING,SAMPLE_RATE);
end
clear expData expLabels;

frequencyTrials = {};
for freqIdx = 1:length(FREQUENCIES)
    singleFreqPart = {}
    for subjectIdx = 1:length(SUBJECTS)
        tempTrials = subjectBeamformedTrials{subjectIdx}{freqIdx}('signals');
        singleFreqPart = cat(2, singleFreqPart, tempTrials);
    end
    frequencyTrials{freqIdx}=singleFreqPart;
end
clear tempTrials singleFreqPart;


rescaledFrequencyTrials = {};
for freqIdx = 1:length(FREQUENCIES)
    trialsAtFrequency = frequencyTrials{freqIdx};
    rescaledTrialsAtFrequency={};
    for trialIdx =  1:length(trialsAtFrequency)
        singleTrial = trialsAtFrequency{trialIdx};
        for innerFreqIdx = 1:length(singleTrial)
            toRescale = singleTrial{innerFreqIdx};
            rescaled = resample(toRescale,RESCALE_POINTS,length(toRescale));
            singleTrial{innerFreqIdx}= rescaled;
        end
        rescaledTrialsAtFrequency{trialIdx}=singleTrial;
    end
    rescaledFrequencyTrials{freqIdx} = rescaledTrialsAtFrequency;
end
clear subjectBeamformedTrials frequencyTrials trialsAtFrequency;
clear rescaledTrialsAtFrequency singleTrial;

binarisedData = {};
for freqIdx = 1:length(FREQUENCIES)
    trialsAtFrequency = rescaledFrequencyTrials{freqIdx};
    binarisedTrialsAtFrequency = {};
    for trialIdx = 1:length(trialsAtFrequency)
        singleTrial = trialsAtFrequency{trialIdx};
        frequencyMatchedTrial = singleTrial{freqIdx};
        binarised = [];
        for i = 1:length(frequencyMatchedTrial)
            correspondingVals = [];
            for j = 1:length(FREQUENCIES)
                correspondingVals = [correspondingVals, singleTrial{j}(i)];
            end
            correspondingVals = correspondingVals(correspondingVals > frequencyMatchedTrial(i));
            if length(correspondingVals) == 0
                binarised = [binarised,1];
            else
                binarised = [binarised,0];
            end
            
        end
        binarisedTrialsAtFrequency{trialIdx} = binarised;
    end
    binarisedData{freqIdx} = binarisedTrialsAtFrequency;
end
clear binarised correspondingVals frequencyMatchedTrial singleTrial

%% turn the entire thing into an image
allTrialMatrix = [];
for freqIdx = 1:length(FREQUENCIES)
   freqPart =  binarisedData{freqIdx};
   for trialIdx = 1:length(freqPart)
       if strcmp(PARADIGM,'frequency') & freqIdx ==2
           0;
       else
         allTrialMatrix = cat(1,allTrialMatrix,freqPart{trialIdx});
       end
   end
end
        
        
        