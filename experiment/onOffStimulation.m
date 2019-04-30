function [ output_args ] = onOffStimulation( trialsPerFrequency, eventsPerTrial, eventLengthSeconds, frameRate )
% perform an on/off stimulation test
% for simplicity we assume a constant set of frequencies (11,13,15) and
% number of targets (9)

% precompute the display sequences
TARGETS = getTargets();
TRIAL_SEQUENCE = getSequence(TARGETS, trialsPerFrequency);
HEADER_DISPLAY = getHeaderDisplays(TARGETS, frameRate);
FLICKER_DISPLAY = getFlickerDisplays(TARGETS, frameRate);

end


function [targets] = getTargets()
% each row is a frequency (11,13,15) each column is a target at that frequency
    targets = [11, 12, 13;
               21, 22, 23;
               31, 32, 33];
end
function [trialSequence] = getSequence(targets, trialsPerFrequency)
    % generates the exicitation sequence which will be followed
    % aim to make excitations random
    % but still cover all frequencies in equal measure
    targetArraySize = size(targets);
    numFrequencies = targetArraySize(1);
    numTargetsPerFrequency = targetArraySize(2);
    
    randomIndices = zeros(numFrequencies, trialsPerFrequency);
    for i = 1:numFrequencies
        randomIndices(i,:)= 10*i + randi([1 numTargetsPerFrequency],1,trialsPerFrequency);
    end
    randomIndices = reshape(randomIndices,[1,numFrequencies*trialsPerFrequency]);
    trialSequence = randomIndices(randperm(numel(randomIndices)));
    
    
end
function [headerDisplay] = getHeaderDisplays(targets, frameRate)
% the headerDisplay is a structure which provides the frame by frame
% sequence to be displayed in the header(target identification and pause)
% for each possible trial option

 SECONDS_GUIDE = 1; % how long is the intended target shown
 SECONDS_PAUSE = 1; % how long is the pause before SSVEP flashing

 headerDisplay = containers.Map;
 [numberOfFrequencies,numberOfTargetsPerFrequency]=size(targets);
 for i = 1:numberOfFrequencies
     for j = 1:numberOfTargetsPerFrequency
         key = int2str(targets(i,j));
         
         framesGuide = frameRate*SECONDS_GUIDE; 
         framesPause = frameRate*SECONDS_PAUSE;
         
         targetPatterns = zeros(numberOfFrequencies,numberOfTargetsPerFrequency, framesGuide+framesPause);
         targetPatterns(i,j,1:framesGuide) = ones(1,1,framesGuide);
         headerDisplay(key) = targetPatterns;
     end
 end
end
function [flickerDisplay] =  getFlickerDisplays(targets, frameRate, eventsPerTrial, eventLengthSeconds)
    % generates the sequence of flashes which will be used or each trial 
    % this is always the same
    % if storage is a problem rather generate this per event sequence
    
    flickerDisplay = 1;
end