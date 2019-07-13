function singlePeriods = rd_extractPeriods( trials, sampleRate, frequency)
%RD_EXTRACTPERIODS takes a matrix of size (#channels, #samples, #trials)
% breaks it up into individual periods of size (#channels,
% samplesPerPeriod, #periods)

numTrials = size(trials,3);
trialLength = size(trials,2);

periodLength = round(sampleRate/frequency);
periodsPerTrial = floor(trialLength/periodLength);

singlePeriods = [];
for t = 1:numTrials
    for p = 1:periodsPerTrial
        period = trials(:, periodLength*(p-1)+1: periodLength*p ,t);
        singlePeriods = cat(3,singlePeriods,period);
    end
end
end