function [ details ] = frequencySwitchStimulation(  trialsPerFrequency, eventsPerTrial, eventLengthSeconds, frameRate, frequencies, TARGETS)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

details = containers.Map;
details('frequencies')=frequencies;
details('frameRate')=frameRate;
details('eventsPerTrial')=eventsPerTrial;
details('eventLengthSeconds')=eventLengthSeconds;
details('trialsPerFrequency')=trialsPerFrequency;
details('experimentType')='FREQUENCY SWITCHING STIMULATION';

% precompute the display sequences
details('targets')=TARGETS;
TRIAL_SEQUENCE = getSequence(TARGETS, trialsPerFrequency);
details('trialSequence')=TRIAL_SEQUENCE;
HEADER_DISPLAY = getHeaderDisplays(TARGETS, frameRate,1,1);
PRETRIAL_FLICKER_SECONDS = eventLengthSeconds;
details('preTrialFlickerSeconds')=PRETRIAL_FLICKER_SECONDS;
[FLICKER_DISPLAY,FLICKER_EVENT_MARKERS] = getFlickerDisplays(TARGETS, frameRate, eventsPerTrial,eventLengthSeconds ,frequencies, PRETRIAL_FLICKER_SECONDS, @generateOneSequence);

timingData = runProcess(TARGETS, TRIAL_SEQUENCE, HEADER_DISPLAY, FLICKER_DISPLAY,FLICKER_EVENT_MARKERS);
details('timingData')=timingData;

end

function [sequence, sequenceEvents] = generateOneSequence(frequency, eventFrequency, eventOffset,framesTrial,framesPreTrial ,frameRate, eventsPerTrial, eventLengthSeconds)
    %lum = 1/2 * (1 + sin(2 * pi * frequency * time + phase));
    
    totalNumFrames = framesTrial + framesPreTrial;
    
    frames = zeros(1,totalNumFrames);
    framesEvent = zeros(1,totalNumFrames);
    for i = 1:totalNumFrames
        frames(i) = 1/2*(1+sin( 2 * pi * frequency * ((i-1)/frameRate) ));
        framesEvent(i) = 1/2*(1+sin( 2 * pi * eventFrequency * ((i-1)/frameRate) ));
    end
    
    controlMask = zeros(1,totalNumFrames);
    cyclePeriod = framesTrial/eventsPerTrial;
    eventsPerCycle = cyclePeriod/(eventLengthSeconds*frameRate);
    framesPerEvent = cyclePeriod/eventsPerCycle;
    
    eventOffset_corrected = eventOffset -1;
    
    for i = framesPreTrial:totalNumFrames
        periodIndex = mod(i-framesPreTrial,cyclePeriod);
        if periodIndex > eventOffset_corrected*(framesPerEvent)  && periodIndex < (eventOffset_corrected+1)*(framesPerEvent)
            controlMask(i) = 1; % when the control mask ==1 we are in the event (off)
        end
    end
    %%% todo lets do frequency switching
    sequence = zeros(1,totalNumFrames);
    sequenceEvents = zeros(1, totalNumFrames);
    for i = 2:totalNumFrames
        if controlMask(i)==1
            sequence(i) = framesEvent(i);
            if controlMask(i-1)==0
                sequenceEvents(i) = 103; % 103 is the start of an event
            end
        else
            if controlMask(i-1)==1
                sequenceEvents(i) = 104; % 104 is the end of an event
            end           
            sequence(i)=frames(i);
        end
    end
end

