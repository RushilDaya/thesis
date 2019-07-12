function [eeg,labels] = rd_preProcessing(filePath, newSampleRate, numElectrodes )
    
    data = loadCurryData(filePath,'Synamps');
    ref_idc = ismember(data.channel_names,{'TP9','TP10'});
    assert(numel(find(ref_idc))==2);
    
    % bandpass filter the eeg signal
    rawEEG = data.EEG - repmat(mean(data.EEG(ref_idc,:),1), size(data.EEG,1),1);
    rawLabels = data.labels;
    rawSampleRate = data.sample_rate;
    rawEEG = filterBetween(rawEEG, rawSampleRate, 4,30,4);
    
    % reduce the number of electrodes
    rawEEG = rawEEG(1:numElectrodes,:);
    
    %resample the EEG signal and the labels
    rawEEG = rawEEG';
    rawEEG = resample(rawEEG, newSampleRate, rawSampleRate);
    rawEEG = rawEEG';
    
    %resample the labels *note not a true resampling but rather just a
    %shift
    newSequenceLength = size(rawEEG,2);
    ratio = newSampleRate/rawSampleRate;
    rawMarkerPositions = find(rawLabels);
    
    labels = zeros(1,newSequenceLength);
    for i = 1:length(rawMarkerPositions)
        rawIndex = rawMarkerPositions(i);
        newIndex = round(rawIndex*ratio);
        
        markerValue = rawLabels(rawIndex);
        labels(newIndex) = markerValue;
    end
   
    labels = labels;
    eeg = rawEEG;
end