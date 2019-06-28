function [eeg] = loadTraining(name)
    data = loadCurryData(name,'Synamps');
    ref_idc = ismember(data.channel_names,{'TP9','TP10'});
    assert(numel(find(ref_idc)) == 2);
    EEG = data.EEG - repmat(mean(data.EEG(ref_idc,:),1), size(data.EEG,1),1);
    eeg = filterBetween(EEG, data.sample_rate,4,30,4);  
end

clear all;
clc;

rawEEG = loadTraining('../data/subject_1p/training');