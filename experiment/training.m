function [ details ] = training(frameRate, frequencies, trainingSeconds,trainingsPerFrequency , TARGETS, headerDisplaySeconds, headerPauseSeconds)
%performs a round of training at each of the target frequencies.
% details logs metainformation and importantly timestamps of the start and
% end time of each training


details = containers.Map;
details('frequencies')=frequencies;
details('frameRate')=frameRate;
details('secondsPerFrequency')=trainingSeconds;
details('headerDisplaySeconds')=headerDisplaySeconds;
details('headerPauseSeconds')=headerPauseSeconds;
details('experimentType')='TRAINING';

% precompute the display sequences
details('targets')=TARGETS;
TRIAL_SEQUENCE = getSequence(TARGETS, trainingsPerFrequency);
details('trialSequence')=TRIAL_SEQUENCE;
HEADER_DISPLAY = getHeaderDisplays(TARGETS, frameRate,headerDisplaySeconds,headerPauseSeconds);
[FLICKER_DISPLAY,FLICKER_EVENT_MARKERS] = getFlickerDisplays(TARGETS, frameRate, 1, trainingSeconds ,frequencies, 0, @generateOneSequence);

timingData = runProcess(TARGETS, TRIAL_SEQUENCE, HEADER_DISPLAY, FLICKER_DISPLAY, FLICKER_EVENT_MARKERS, frequencies);
details('timingData')=timingData;

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