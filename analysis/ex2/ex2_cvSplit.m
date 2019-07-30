function cv_subsets = ex2_cvSplit(data, numFolds)

    numFreqs = length(data);
    numTrialsPerFreq = length(data{1}('signals'));
    cvBlockSize = floor(numTrialsPerFreq/numFolds);
    
    TrialList = linspace(1,numTrialsPerFreq,numTrialsPerFreq);
    
    cv_subsets = {};
    for cvIdx = 1:numFolds
        singleBlock = {};
        for freqIdx = 1:numFreqs
            freqSignals = data{freqIdx}('signals');
            freqEventStarts = data{freqIdx}('eventStarts');
            freqEventStops = data{freqIdx}('eventEnds');
            
            leftIndices = TrialList(TrialList <= cvBlockSize*(cvIdx-1) );
            rightIndices = TrialList(TrialList > cvBlockSize*cvIdx );
            trainIndices = [leftIndices,rightIndices];
            testIndices = setdiff(TrialList,trainIndices);
            
            
            freqEventStartsTrain = freqEventStarts(:,:,trainIndices);
            freqEventStopsTrain = freqEventStops(:,:,trainIndices);
            freqSignalsTrain = freqSignals(trainIndices);
            
            freqEventStartsTest = freqEventStarts(:,:,testIndices);
            freqEventStopsTest = freqEventStops(:,:,testIndices);
            freqSignalsTest = freqSignals(testIndices);
   
            
            freqMap = containers.Map;
            freqMap('signals')= freqSignalsTrain;
            freqMap('eventStarts')= freqEventStartsTrain;
            freqMap('eventEnds')= freqEventStopsTrain;
            freqMap('signalsTest') = freqSignalsTest;
            freqMap('eventStartsTest')= freqEventStartsTest;
            freqMap('eventStopsTest') = freqEventStopsTest;
            
            singleBlock{freqIdx} = freqMap;
        end
        cv_subsets{cvIdx} = singleBlock;
    end
        

end

