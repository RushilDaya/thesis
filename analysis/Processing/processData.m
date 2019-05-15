clear;
clc;

subjects = {'s1', 's2', 's3', 's4', 's5'};

for s = 1 : numel(subjects)
    filename = sprintf('Data/Raw/%s/Online', subjects{s});
    
    [trials, cues, markers, channelNames, sampleRate] = processTraining(filename, [0 8], (100:125));
    
    saveFolder = sprintf('Data/Processed/%s', subjects{s});
    if ~exist(saveFolder, 'dir')
        mkdir(saveFolder);
    end
    
    save(sprintf('%s/Online.mat', saveFolder), 'trials', 'cues', 'markers', ...
        'channelNames', 'sampleRate', '-v7.3');
end