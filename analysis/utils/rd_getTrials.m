function [trials,eventLabelsStart, eventLabelsEnd] = rd_getTrials( eegData, labels, frequencyOfInterest )
% filters and segments the eeg data to only include trails at the frequency
% of interest.

trials = [];
eventLabelsStart = [];
eventLabelsEnd = [];

frequencyMarkers = find(labels == frequencyOfInterest);
trialStartMarkers = find(labels == 100);
trialEndMarkers = find(labels == 101);
eventStartMarkers = find(labels == 103);
eventEndMarkers = find(labels == 104);


maxTrialLength = 0;
for i = 1:length(frequencyMarkers)
    trialIdx = frequencyMarkers(i);
    singleTrialStart = trialStartMarkers(trialStartMarkers > trialIdx);
    singleTrialStart = singleTrialStart(1);
    singleTrialEnd = trialEndMarkers(trialEndMarkers > trialIdx);
    singleTrialEnd = singleTrialEnd(1);
    trialLength = singleTrialEnd - singleTrialStart;
    if trialLength > maxTrialLength
        maxTrialLength = trialLength;
    end
end


for i = 1:length(frequencyMarkers)
    trialIdx = frequencyMarkers(i);
    singleTrialStart = trialStartMarkers(trialStartMarkers > trialIdx);
    singleTrialStart = singleTrialStart(1);
    dataSegment = eegData(:, singleTrialStart:singleTrialStart + maxTrialLength );
    trials = cat(3, trials, dataSegment);
    
    % event labels need to be re-indexed to match the trial itself
    eventStartsTrial = eventStartMarkers(eventStartMarkers > singleTrialStart & eventStartMarkers < singleTrialStart + maxTrialLength );
    eventEndsTrial = eventEndMarkers(eventEndMarkers > singleTrialStart & eventEndMarkers < singleTrialStart + maxTrialLength );
    
    eventStartTrial =  eventStartsTrial - singleTrialStart;
    eventEndsTrial = eventEndsTrial - singleTrialStart;
    
    eventLabelsStart = cat(3, eventLabelsStart, eventStartTrial);
    eventLabelsEnd = cat(3, eventLabelsEnd, eventEndsTrial);
end
    
    
end