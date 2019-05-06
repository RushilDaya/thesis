function [ details ] = training(frameRate, frequencies, trainingSeconds, TARGETS)
%performs a round of training at each of the target frequencies.
% details logs metainformation and importantly timestamps of the start and
% end time of each training


details = containers.Map;
details('frequencies')=frequencies;
details('frameRate')=frameRate;
details('secondsPerFrequency')=trainingSeconds;
details('experimentType')='TRAINING';

% precompute the display sequences
details('targets')=TARGETS;
TRIAL_SEQUENCE = getSequence(TARGETS, 1);
details('trialSequence')=TRIAL_SEQUENCE;
HEADER_DISPLAY = getHeaderDisplays(TARGETS, frameRate,1,1);
[FLICKER_DISPLAY,FLICKER_EVENT_MARKERS] = getFlickerDisplays(TARGETS, frameRate, 1, trainingSeconds ,frequencies, 0);

timingData = runProcess(TARGETS, TRIAL_SEQUENCE, HEADER_DISPLAY, FLICKER_DISPLAY, FLICKER_EVENT_MARKERS);
details('timingData')=timingData;

end

function [FlickerDisplay, FlickerEvents] =  getFlickerDisplays(targets, frameRate, eventsPerTrial, eventLengthSeconds, frequencies, preTrialFlickerSeconds)
 % generates the sequence of flashes which will be used or each trial 
 % this is always the same
 % if storage is a problem rather generate this per event sequence
 
 [numberOfFrequencies, numberOfTargetsPerFrequency]=size(targets);
 FRAMES_TRIAL = frameRate*eventsPerTrial*eventLengthSeconds*numberOfTargetsPerFrequency;
 FRAMES_PRETRIAL = frameRate*preTrialFlickerSeconds;
 % an event is the switching off of a single target. thus the total time to
 % eventsPerTrial is the number of events on a single target per trial (we
 % need to multiply by number of targets to account for the time when the
 % target is in the ON state
 
 FlickerDisplay = containers.Map;
 FlickerEvents = containers.Map;
 
 for i = 1:numberOfFrequencies
     for j = 1:numberOfTargetsPerFrequency
         key = int2str(targets(i,j));
         [FlickerDisplay(key),FlickerEvents(key)] = generateOneSequence(frequencies(i),j,FRAMES_TRIAL, FRAMES_PRETRIAL ,frameRate, eventsPerTrial, eventLengthSeconds);
     end
 end
end

function [sequence, sequenceEvents] = generateOneSequence(frequency, eventOffset,framesTrial,framesPreTrial ,frameRate, eventsPerTrial, eventLengthSeconds)
    %lum = 1/2 * (1 + sin(2 * pi * frequency * time + phase));
    
    totalNumFrames = framesTrial + framesPreTrial;
    
    frames = zeros(1,totalNumFrames);
    for i = 1:totalNumFrames
        frames(i) = 1/2*(1+sin( 2 * pi * frequency * ((i-1)/frameRate) ));
    end
    sequenceEvents = zeros(1,totalNumFrames);
    sequence = frames;
end