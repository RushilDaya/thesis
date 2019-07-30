function allTrials = ex2_beamformTrials(data,labels,beamformers,frequencies,averagingPeriod, sampleRate)
    %EX2_BEAMFORMTRIALS Summary of this function goes here
    %   Detailed explanation goes here

    allTrials  = {};
    % first level is on frequency
    for freqIdx = 1:length(frequencies)

        [trials, eventLabelsStart, eventLabelsEnd] = rd_getTrials(data,...
            labels, frequencies(freqIdx));

        TrialsAtFreq = containers.Map;
        TrialsAtFreq('eventStarts') = eventLabelsStart;
        TrialsAtFreq('eventEnds') = eventLabelsEnd;
        trialData = {};
        for trialIdx = 1:size(trials,3)
            freqBeamformedTrial = {};
            for freqIdxInner = 1:length(frequencies)
                beamformedTrial = rd_applyBeamformer(trials(:,:,trialIdx),...
                    beamformers{freqIdxInner},frequencies(freqIdxInner),...
                    sampleRate,averagingPeriod);
                freqBeamformedTrial{freqIdxInner} = beamformedTrial;
            end
            trialData{trialIdx} = freqBeamformedTrial;
        end 
        TrialsAtFreq('signals')=trialData;
        allTrials{freqIdx} = TrialsAtFreq;
    end
end