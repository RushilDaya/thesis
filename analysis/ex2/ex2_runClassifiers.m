function softClassifications = ex2_runClassifiers(wholeData, classifiers, featureVectorSize,frequencies,sampleRate,signalKey,eventKey)
    % runs the classifiers "in an online" manner for each of the trails
    % this function ASSUMES we know the frequency and looks only for events
    
    softClassifications = {};
    for freqIdx = 1:length(wholeData)
        trialStruct = {};
        testTrials = wholeData{freqIdx}(signalKey);
        eventMarkers = wholeData{freqIdx}(eventKey);
        classifierOfInterest = classifiers{freqIdx};
        
        trialStruct = {};
        for trialIdx = 1:length(testTrials)
            trialOfInterest = testTrials{trialIdx}{freqIdx}; % only consider single frequency
            classifierOutputs = [];
            for pt = 1:length(trialOfInterest)-featureVectorSize
                segment = trialOfInterest(pt:pt+featureVectorSize-1);
                segment = segment - mean(segment,2);
                [prediction,score] = classifierOfInterest.predictFcn(segment);
                cOut = score(2);
                classifierOutputs = cat(2,classifierOutputs,cOut);
            end
            prePad = zeros([1,floor(featureVectorSize/2)]);
            postPad = zeros([1,ceil(featureVectorSize/2)]);
            classifierOutputs = cat(2,prePad,classifierOutputs,postPad);
            
            % get the events (transition) events in beamformer time
            events = eventMarkers(:,:,trialIdx);
            eventLocations = round(events*(frequencies(freqIdx)/sampleRate));
            events = zeros([1,length(trialOfInterest)]);
            events(eventLocations) = 1;
            
            singleTrial = containers.Map;
            singleTrial('predictions') = classifierOutputs;
            singleTrial('events') = events;
            singleTrial('input') = trialOfInterest;
            trialStruct{trialIdx} = singleTrial;
                 
        end
        softClassifications{freqIdx} = trialStruct;
    end


end