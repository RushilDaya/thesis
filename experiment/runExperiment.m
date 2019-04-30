%% define the experimental constants

METHOD = 'ONOFF'; % [ONOFF, PHASESWITCH, FREQUENCYSWITCH ]
TRIALS_PER_FREQUENCY = 5;
EVENTS_PER_TRIAL = 10;
EVENT_LENGTH_SECONDS = 1; 
FRAME_RATE = 60;

%% call the appropriate run function

if strcmp(METHOD,'ONOFF')
    onOffStimulation(TRIALS_PER_FREQUENCY,EVENTS_PER_TRIAL, EVENT_LENGTH_SECONDS, FRAME_RATE)
elseif strcmp(METHOD, 'PHASESWITCH')
    2
elseif strcmp(METHOD, 'FREQUENCYSWITCH')
    3
end