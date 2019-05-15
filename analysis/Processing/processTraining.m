function [ trials, cues, markers, channelNames, sampleRate ] = processTraining( filename, window, markers )
%PROCESSTRAINING Summary of this function goes here
%   Detailed explanation goes here
    
    Data = loadCurryData(filename, 'Synamps');
    
    % Rereference
    ref_idc = ismember(Data.channel_names, {'TP9', 'TP10'});
    assert(numel(find(ref_idc)) == 2);
    EEG = Data.EEG - repmat(mean(Data.EEG(ref_idc,:),1), size(Data.EEG,1),1);
    
    % Filtering
    EEG = filterBetween(EEG, Data.sample_rate, 4, 20, 4);
    
    % Cut epochs
    [trials,cues,markers] = cutEpochs(EEG, Data.sample_rate, Data.labels, window, markers); 
    
%     trials = downsampleEeg(trials,Data.sample_rate, 1000);
  
    sampleRate = Data.sample_rate;
    channelNames = Data.channel_names;
%     sampleRate = 1000;
end

