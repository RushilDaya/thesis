function singlePeriods = rd_extractPeriods( trials, sampleRate, frequency)
%RD_EXTRACTPERIODS takes a matrix of size (#channels, #samples, #trials)
% breaks it up into individual periods of size (#channels,
% samplesPerPeriod, #periods)

numTrials = size(trials,3);
trialLength = size(trials,2);
stimulationDuration = trialLength/sampleRate;
periodsPerTrial = floor(stimulationDuration*frequency);

periodLength = round(sampleRate/frequency);
%periodsPerTrial = floor(trialLength/periodLength);

singlePeriods = [];
for t = 1:numTrials
    for p = 1:periodsPerTrial
        periodStart = round((p-1)*(sampleRate)*(1/frequency))+1;
        period = trials(:, periodStart: periodStart+periodLength-1 ,t);
        singlePeriods = cat(3,singlePeriods,period);
    end
end
end

% 	nb_electrodes = size(trial,1);
% 	trial_length = size(trial,2);
% 	stimulation_duration = trial_length / sample_rate;
% 	
% 	% Cut individual epochs
% 	nb_epochs = floor(stimulation_duration * frequency);
% 	epoch_start_idx = round((0 : nb_epochs-1) * (1/frequency) * sample_rate) + 1;
% 	epoch_length = floor(sample_rate/frequency);