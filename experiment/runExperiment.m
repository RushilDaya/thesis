%% user name

    USER_NAME = 'SUBJECT1';
    METHOD    = 'FREQUENCYSWITCH'; % [ONOFF, PHASESWITCH, FREQUENCYSWITCH ]

%% define the experimental constants

TRIALS_PER_FREQUENCY = 1;
EVENTS_PER_TRIAL = 1    ;
EVENT_LENGTH_SECONDS = 1; 
FRAME_RATE = 60;
FREQUENCIES = [11, 13, 15 ]; %can change the frequencies but not the number of frequencies
TRAINING_SECONDS = 5  ;

%% call the appropriate run function

if strcmp(METHOD,'ONOFF')
    details = onOffStimulation(TRIALS_PER_FREQUENCY,EVENTS_PER_TRIAL, EVENT_LENGTH_SECONDS, FRAME_RATE, FREQUENCIES);
elseif strcmp(METHOD, 'PHASESWITCH')
    details = phaseReversalStimulation(TRIALS_PER_FREQUENCY,EVENTS_PER_TRIAL, EVENT_LENGTH_SECONDS, FRAME_RATE, FREQUENCIES);
elseif strcmp(METHOD, 'FREQUENCYSWITCH')
    details = frequencySwitchStimulation(TRIALS_PER_FREQUENCY,EVENTS_PER_TRIAL, EVENT_LENGTH_SECONDS, FRAME_RATE, FREQUENCIES);
elseif strcmp(METHOD, 'TRAINING')
    details = training(FRAME_RATE, FREQUENCIES, TRAINING_SECONDS);
end  

saveDetails(details,USER_NAME, METHOD);       
