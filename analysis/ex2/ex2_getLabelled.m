function labelledData = ex2_getLabelled( trials, frequencies, featureVectorSize, sampleRate )
    
    labelledData = {};
    for freqIdx = 1:length(frequencies)
        beamformedTrials = trials{freqIdx}('signals');
        eventStarts = trials{freqIdx}('eventStarts');
        eventEnds = trials{freqIdx}('eventEnds');
        
        trialsFreqSplit = {};
        for i = 1:length(frequencies)
             trialsFreqSplit{i} = [];
             for j = 1:size(beamformedTrials,2)
                 trialsFreqSplit{i} = cat(3,trialsFreqSplit{i},beamformedTrials{j}{i});
             end
        end
        
        [features, labels] = rd_generateLabelled(trialsFreqSplit{freqIdx},eventStarts,eventEnds,...
            featureVectorSize,sampleRate, frequencies(freqIdx));
        features =  reshape(features,[size(features,2),size(features,3)])';
        features = features - mean(features,2);
        labels = labels';
        combined = cat(2, features,labels);
        scrambleIdx = randperm(size(combined,1));
        combined = combined(scrambleIdx,:);
        
        labelledData{freqIdx} = combined;
        
    end
end