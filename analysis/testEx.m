clear ;
clc;

FILE_NAME = 'subject_1/phase.dat';
FREQUENCY_MARKER = 11;
TRIAL_MARKER_START = 100;
TRIAL_MARKER_STOP = 101;
EVENT_MARKER_START = 103;
EVENT_MARKER_STOP = 104;
ELECTRODE_OF_INTEREST = 2;

PERFORM_BASIC_FFT = false;
PERFORM_VALIDATION = true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data = loadCurryData(FILE_NAME,'Synamps');
ref_idc = ismember(data.channel_names, {'TP9', 'TP10'});
assert(numel(find(ref_idc)) == 2);
EEG = data.EEG - repmat(mean(data.EEG(ref_idc,:),1), size(data.EEG,1),1);
LABELS = data.labels;
SAMPLE_RATE = data.sample_rate;
CHANNEL_LABELS = data.channel_names;
EEG = filterBetween(EEG, SAMPLE_RATE, 4, 30, 4);
clear data;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

frequencyLabels = find(LABELS == FREQUENCY_MARKER);
trialLabelsStart = find(LABELS == TRIAL_MARKER_START);
trialLabelsStop = find(LABELS == TRIAL_MARKER_STOP);
allEventMarkersStart = find(LABELS == EVENT_MARKER_START);
allEventMarkersStop = find(LABELS == EVENT_MARKER_STOP);


maxTL = 0; % don't expect more than a few sample deviation
for i = 1:length(frequencyLabels)
    trialsStartAfter = trialLabelsStart( trialLabelsStart > frequencyLabels(i)); 
    trialsEndAfter = trialLabelsStop(trialLabelsStop > frequencyLabels(i));
    trialStart = trialsStartAfter(1);
    trialEnd = trialsEndAfter(1);
    trialLength = trialEnd - trialStart;
    if trialLength > maxTL
        maxTL = trialLength;
    end
    
end

trials = [];
eventStartsPerTrial = [];
eventStopsPerTrial = [];

for i = 1:length(frequencyLabels)
    trialsStartAfter = trialLabelsStart( trialLabelsStart > frequencyLabels(i)); 
    
    trialStart = trialsStartAfter(1);
    trialEnd = trialStart + maxTL;
    
    eventStartsTrial = allEventMarkersStart(allEventMarkersStart > trialStart & allEventMarkersStart < trialEnd );
    eventStopsTrial = allEventMarkersStop(allEventMarkersStop > trialStart & allEventMarkersStop < trialEnd );
    
    eventStartsTrial = eventStartsTrial -trialStart;
    eventStopsTrial = eventStopsTrial - trialStart;
    
    eventStartsPerTrial = cat(3, eventStartsPerTrial,eventStartsTrial);
    eventStopsPerTrial = cat(3,eventStopsPerTrial, eventStopsTrial);
    
    trialSegment = EEG(:,trialStart:trialEnd);
    trials = cat(3, trials, trialSegment);
end

clear trialsStartAfter trialsEndAfter trialStart trialEnd eventStartsTrial eventStopsTrial trialSegment;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% here we take the segmented trials and event markers and validate the
% behaviour as being as expected

%% perform fft on the trails.
if PERFORM_BASIC_FFT
    for i = 1:size(trials,3)
        signal = trials(ELECTRODE_OF_INTEREST,:,i);
        fftSig =fft(signal);
        fftSig =abs(fftSig);

        frequencyAxis = SAMPLE_RATE/2*linspace(0,1,length(fftSig)/2+1);
        figure,plot(frequencyAxis, fftSig(1:floor(length(fftSig)/2)+1));
        xlim([0.0 50]);
    end
end

%% see if the signals have the correct event / phase characteristics
if PERFORM_VALIDATION
    for i = 1:size(trials,3)
        % break up each trial into sections divided by the event markers
        signal = trials(ELECTRODE_OF_INTEREST,:,i);
        eventStarts = eventStartsPerTrial(:,:,i);
        eventStops = eventStopsPerTrial(:,:,i);
        nonEventParts = {};
        eventParts = {};
        
        for j = 1:length(eventStarts)
            eventParts{j} = signal(eventStarts(j):eventStops(j));
            if j == 1
                nonEventParts{1} = signal(1:eventStarts(1));
            else
                nonEventParts{j+1} = signal(eventStops(j-1):eventStarts(j));
            end
        end
        
        
        for j = 1:length(eventParts)
            
            segment = eventParts{j};
            periodLength = round(SAMPLE_RATE/(FREQUENCY_MARKER));
            numPeriods = floor(length(segment)/periodLength);
            meanSignalE = zeros(1,periodLength);    
            for k = 1:numPeriods
                meanSignalE =meanSignalE + segment((k-1)*periodLength+1:k*periodLength);
            end
            meanSignalE =  meanSignalE/numPeriods;
            
            segment = nonEventParts{j};
            periodLength = round(SAMPLE_RATE/(FREQUENCY_MARKER));
            numPeriods = floor(length(segment)/periodLength);
            meanSignalNE = zeros(1,periodLength);
            for k = 1:numPeriods
                meanSignalNE = meanSignalNE + segment((k-1)*periodLength+1:k*periodLength);
            end
            meanSignalNE = meanSignalNE/numPeriods;
            
            
            figure,plot(meanSignalNE);
            hold on;
            plot(meanSignalE);
            
        end
        
        
    end
end