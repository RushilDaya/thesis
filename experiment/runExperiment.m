%% user name

    USER_NAME = 'SUBJECT1';
    METHOD    = 'PHASESWITCH'; % [ONOFF, PHASESWITCH, FREQUENCYSWITCH ]

%% define the experimental constants

TRIALS_PER_FREQUENCY = 1;
EVENTS_PER_TRIAL = 2;
EVENT_LENGTH_SECONDS = 1; 
FRAME_RATE = 60;
FREQUENCIES = [11, 13, 15 ]; %can change the frequencies but not the number of frequencies

%% call the appropriate run function

if strcmp(METHOD,'ONOFF')
    details = onOffStimulation(TRIALS_PER_FREQUENCY,EVENTS_PER_TRIAL, EVENT_LENGTH_SECONDS, FRAME_RATE, FREQUENCIES);
elseif strcmp(METHOD, 'PHASESWITCH')
    details = phaseReversalStimulation(TRIALS_PER_FREQUENCY,EVENTS_PER_TRIAL, EVENT_LENGTH_SECONDS, FRAME_RATE, FREQUENCIES);
elseif strcmp(METHOD, 'FREQUENCYSWITCH')
    3
end  

saveDetails(details, USER_NAME);