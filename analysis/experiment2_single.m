subjects = [1,2,3,4,5];
paradigms = {'onoff','phase','frequency'};
SAMPLE_RATE = 256;
ELECTRODES = {'O1','Oz','O2','PO3','PO4','Pz','P3','P4','Cz','Fz'};
AVERAGING = 5;
FEATURE_VECTOR_SIZE = 12;
FREQUENCIES = [11,13,15];
CV_FOLDS = 5;

subjects = [3];
paradigms = {'onoff'};


superStructure = {};
for paradigmIdx = 1:length(paradigms)
    PARADIGM = paradigms{paradigmIdx}
    paradigmStructure = {};
    for subjectIdx = 1:length(subjects)
        SUBJECT = subjects(subjectIdx)
        

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


        allClassificationData = {}
        for cvIdx = 1:length(cv_sets)
            beamformedTrials = cv_sets{cvIdx};
            % train the classifier
            dataSegments = ex2_getLabelled(beamformedTrials, FREQUENCIES, FEATURE_VECTOR_SIZE, SAMPLE_RATE);
            % datasegments has 3 cells ( one for each frequency)
            classifiers = ex2_trainClassifiers(dataSegments);

            classificationsTraining = ex2_runClassifiers(beamformedTrials, classifiers,...
                    FEATURE_VECTOR_SIZE,FREQUENCIES,SAMPLE_RATE,'signals','eventStarts'); 
            classificationsTest = ex2_runClassifiers(beamformedTrials, classifiers,...
                    FEATURE_VECTOR_SIZE,FREQUENCIES,SAMPLE_RATE,'signalsTest','eventStartsTest');   
            foldObj = containers.Map;
            foldObj('training')=classificationsTraining;
            foldObj('test')=classificationsTest;

            allClassificationData{cvIdx} = foldObj;

            
            for ii = 1:length(classificationsTest)
                pp = classificationsTest{ii};
                for jj = 1:length(pp)
                    aa = pp{jj};
                    figure, plot(aa('predictions'),'LineWidth',2);
                    figure, plot(aa('events'),'LineWidth',2);
                    figure, plot(aa('input'),'LineWidth',2);
                end
            end
            
        end
        paradigmStructure{subjectIdx} = allClassificationData;
        
    end
    superStructure{paradigmIdx} = paradigmStructure;
end

save('data/experiment2allKnownFreqFAKE.mat','superStructure');



