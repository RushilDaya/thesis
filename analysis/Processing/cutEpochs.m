function [epochs, cues, trialMarkers] = cutEpochs(EEG, sampleRate, markers, window, markersOfInterest)
%% Cuts the EEG into trials of a given length
%   There will be one epoch for each marker

    windowInSamples = fix(window * sampleRate);
    nbSamples = numel(windowInSamples(1):windowInSamples(2));
    
    % Get the samples that mark the onset of the stimuli of interest
    if ~isempty(markersOfInterest)
        % only use the markers of interest
        onsets = find(ismember(markers, markersOfInterest));
    else 
        % if none specified, use all markers
        onsets = find(markers);
    end
    
    % Make the matrix where we will store the epochs
    epochs = zeros(size(EEG,1), nbSamples, numel(onsets));
    trialMarkers = zeros(numel(onsets), nbSamples);
    % Find the labels corresponding to the onsets
    cues = markers(onsets);
    for i = 1 : numel(onsets)
        % Cut an epoch
        currentEpoch = EEG(:, onsets(i)+windowInSamples(1):onsets(i)+windowInSamples(2));
        
        % Save the epoch in the matrix we made before
        epochs(:,:,i) = currentEpoch;
        trialMarkers(i,:) = markers(onsets(i)+windowInSamples(1):onsets(i)+windowInSamples(2));
    end
end