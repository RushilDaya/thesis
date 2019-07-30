function classifiers = ex2_trainClassifiers( labelledData )
    
    classifiers = {};
    for freqIdx = 1:length(labelledData)
        [trainedClassifier, validationPredictions] = rd_classifierLSVM(labelledData{freqIdx},4);
        acc = rd_computeAccuracy(validationPredictions, labelledData{freqIdx}(:,end));
        classifiers{freqIdx} = trainedClassifier;
    end
end