function referencedEEG = rereference(EEG, channelNames, referenceTo) 
%% Re-references the EEG to the given channels
%   INPUT 
%       EEG : matrix (nbChannels x nbSamples)
%       channelNames : cell array of strings
%           -> size must be equal to the number of rows in EEG
%       referenceTo : cell array of strings
%           -> elements must be exist in 'channelNames'

    % Check if number of channel names equals the number of rows in EEG
    assert(size(EEG,1) == numel(channelNames));
    
    % Find the rows of the channels to reference to
    refIdc = ismember(channelNames, referenceTo);
    
    % Check if all reference channels are found
    assert(numel(find(refIdc)) == numel(referenceTo));
    
    % Calculate the mean of the reference channels
    ref = mean(EEG(refIdc,:), 1);
    
    % Re-reference the eeg to the mean
    referencedEEG = EEG - repmat(ref, size(EEG,1), 1);
end