function filteredEEG = filterBetween(EEG, sampleRate, low, high, order) 
%% Filters the EEG using a low-pass filter (if any) followed by a high-pass filter (if any)
%   (using a four-order Butterworth filter)
%   INPUT
%       EEG : matrix (nbChannels x nbSamples)
%       sampleRate : scalar
%       low : scalar (or [])
%           -> Indicates a frequency
%       high : scalar (or [])
%           -> Indicates a frequency

    % High pass filter
    if ~isempty(low)
        normalizedCutoffFrequency = low / (sampleRate/2); 
        [tmpA, tmpB] = butter( order, normalizedCutoffFrequency, 'high' );
        EEG = filtfilt( tmpA, tmpB, EEG' )';
    end
    
    % Low pass filter
    if ~isempty(high)
        normalizedCutoffFrequency = high / (sampleRate/2); 
        [tmpA, tmpB] = butter( order, normalizedCutoffFrequency, 'low' );
        EEG = filtfilt( tmpA, tmpB, EEG' )';
    end
    
    filteredEEG = EEG;
end