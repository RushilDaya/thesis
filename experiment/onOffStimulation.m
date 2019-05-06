function [details] = onOffStimulation( trialsPerFrequency, eventsPerTrial, eventLengthSeconds, frameRate, frequencies, TARGETS )
% perform an on/off stimulation test
% for simplicity we assume a constant set of only 3 frequencies
% number of targets (9)


details = containers.Map;
details('frequencies')=frequencies;
details('frameRate')=frameRate;
details('eventsPerTrial')=eventsPerTrial;
details('eventLengthSeconds')=eventLengthSeconds;
details('trialsPerFrequency')=trialsPerFrequency;
details('experimentType')='ON OFF STIMULATION';

% precompute the display sequences
details('targets')=TARGETS;
TRIAL_SEQUENCE = getSequence(TARGETS, trialsPerFrequency);
details('trialSequence')=TRIAL_SEQUENCE;
HEADER_DISPLAY = getHeaderDisplays(TARGETS, frameRate,1,1);
PRETRIAL_FLICKER_SECONDS = eventLengthSeconds;
details('preTrialFlickerSeconds')=PRETRIAL_FLICKER_SECONDS;
[FLICKER_DISPLAY,FLICKER_EVENT_MARKERS] = getFlickerDisplays(TARGETS, frameRate, eventsPerTrial,eventLengthSeconds ,frequencies, PRETRIAL_FLICKER_SECONDS);

timingData = runProcess(TARGETS, TRIAL_SEQUENCE, HEADER_DISPLAY, FLICKER_DISPLAY, FLICKER_EVENT_MARKERS);
details('timingData')=timingData;

end

function [FlickerDisplay,FlickerEvents] =  getFlickerDisplays(targets, frameRate, eventsPerTrial, eventLengthSeconds, frequencies, preTrialFlickerSeconds)
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
    
    controlMask = zeros(1,totalNumFrames);
    cyclePeriod = framesTrial/eventsPerTrial;
    eventsPerCycle = cyclePeriod/(eventLengthSeconds*frameRate);
    framesPerEvent = cyclePeriod/eventsPerCycle;
    
    eventOffset_corrected = eventOffset -1;
    
    for i = framesPreTrial:totalNumFrames
        periodIndex = mod(i-framesPreTrial,cyclePeriod);
        if periodIndex >= eventOffset_corrected*(framesPerEvent)  && periodIndex < (eventOffset_corrected+1)*(framesPerEvent)
            controlMask(i) = 1; % when the control mask ==1 we are in the event (off)
        end
    end
    
    sequence = zeros(1,totalNumFrames);
    sequenceEvents = zeros(1,totalNumFrames);
    for i = 2:totalNumFrames
        if controlMask(i)==1
            if controlMask(i-1)==0
                sequenceEvents(i) = 103; % 103 is the start of an event
            end
            sequence(i) = 1;
        else
            if controlMask(i-1)==1
                sequenceEvents(i) = 104; % 104 is the end of an event
            end
            sequence(i)=frames(i);
        end
    end
    %plot(sequence);
end

function [timingData] = runProcess(targets, trialSequence, headerDisplay, flickerDisplay, eventMarkers)
    % perform the actual displaying to screen here
    % 1. initialise the screen
    % 2. loop over trials
    %   2.1 print information to screen
    %   2.1 make sure to save trial information?
    
    timingData = cell(length(trialSequence),2);
    
    
AssertOpenGL;
defaultPriority = Priority();   
    try
        PsychDefaultSetup(2);
        Screen('Preference','Verbosity',0);
        Screen('Preference','SkipSyncTests',1);
        Screen('Preference','VisualDebugLevel',0);
        
        screenNumber = max(Screen('Screens'));
        [window, screenRect]=Screen('OpenWindow', screenNumber,0);
        
        
        
        %% the code for running the stimulator goes here
        
        % determine screen block sizes and loop increments etc
        OUTER_MARGIN_FRACTION = 0.1;
        topBottomMargin = OUTER_MARGIN_FRACTION*RectHeight(screenRect);
        leftRightMargin = OUTER_MARGIN_FRACTION*RectWidth(screenRect);
        [numFrequencies, targetsPerFrequency] = size(targets);
        
        % the outer rectangular block with margin and padding ( the actual target must
        % be square
        targetBoxHeightMargined = RectHeight(screenRect)*(1-OUTER_MARGIN_FRACTION*2)/numFrequencies;
        targetBoxWidthMargined = RectWidth(screenRect)*(1-OUTER_MARGIN_FRACTION*2)/targetsPerFrequency;
        
        % within each of the target boxes we need some small amount of
        % padding
        % following this we need to draw the true stimulator
        INNER_MARGIN_FRACTION=0.1;
        targetBoxTopBottomMargin= targetBoxHeightMargined*INNER_MARGIN_FRACTION;
        targetBoxLeftRightMargin= targetBoxWidthMargined*INNER_MARGIN_FRACTION;
        targetBoxHeightNoMargin = targetBoxHeightMargined*(1-2*INNER_MARGIN_FRACTION);
        targetBoxWidthNoMargin = targetBoxWidthMargined*(1-2*INNER_MARGIN_FRACTION);
        
        stimulatorHeight = min(targetBoxHeightNoMargin, targetBoxWidthNoMargin);
        stimulatorWidth = min(targetBoxHeightNoMargin, targetBoxWidthNoMargin);
        
        targetCenters = zeros(numFrequencies, targetsPerFrequency,2);
        for i = 1:numFrequencies
            for j = 1:targetsPerFrequency
                %first is the vertical position
                targetCenters(i,j,1)= topBottomMargin+(i-1)*targetBoxHeightMargined+targetBoxTopBottomMargin + targetBoxHeightNoMargin/2; % still need to incorporate the side padding
                %second is the horizontal position
                targetCenters(i,j,2)= leftRightMargin+(j-1)*targetBoxWidthMargined+targetBoxLeftRightMargin + targetBoxWidthNoMargin/2;
            end
        end
        
        
        baseStimulator = [0, 0, stimulatorHeight, stimulatorWidth];
        allStimulators = nan(4,numFrequencies*targetsPerFrequency);
        for i = 1:numFrequencies
            for j = 1:targetsPerFrequency
                allStimulators(:, (i-1)*targetsPerFrequency+j) = CenterRectOnPointd(baseStimulator,targetCenters(i,j,2),targetCenters(i,j,1));
            end
        end
        
        headerPartTemp = headerDisplay(int2str(targets(1,1)));
        headerPartLength = length(headerPartTemp(1,1,:))
        flickerFrames = length(flickerDisplay('11'));

        
        for trialIdx = 1:length(trialSequence)
            % show header part
            headerOfInterest = headerDisplay(int2str(trialSequence(trialIdx)));
            trialSequence(trialIdx);
            trialEventMarkers = eventMarkers(int2str(trialSequence(trialIdx)));
           
            vbl = Screen('Flip', window);
            
            %datestr(now,'dd-mm-yyyy HH:MM:SS FFF')
            for frameIdx = 1:headerPartLength
                headerFrame = headerOfInterest(:,:,frameIdx);
                allColors = 255*ones(3,numFrequencies*targetsPerFrequency);
                flatHeader = reshape(headerFrame',[1,numFrequencies*targetsPerFrequency]);
                allColors(2,:) = allColors(2,:).*(flatHeader);
                allColors(3,:) = allColors(3,:).*(flatHeader);
                Screen('FillRect', window, allColors, allStimulators);
                if frameIdx == 1
                    marker = trialSequence(trialIdx);
                    Screen('FillRect', window, getVPixxMarkerColor(marker), [0,0,1,1]);
                end
                vbl=Screen('Flip',window);
            end
            %datestr(now,'dd-mm-yyyy HH:MM:SS FFF')
            
            
            % show trial part
            
            
            %TODO how to get the timing correct?
             
            
            timingData(trialIdx,1)= {string(datestr(now,'dd-mm-yyyy HH:MM:SS FFF'))};
            % note trail begins with a period (one event long) where all
            % targets are flashed - must account for this in the recording
            
            for frameIdx = 1:flickerFrames
                allColors = 255*ones(3,numFrequencies*targetsPerFrequency);
                for i = 1:numFrequencies
                    for j = 1:targetsPerFrequency
                        key = int2str(targets(i,j));
                        sequence = flickerDisplay(key);
                        frameValue = sequence(frameIdx);
                        allColors(:,(i-1)*targetsPerFrequency+j) = frameValue*allColors(:,(i-1)*targetsPerFrequency+j );
                    end
                end
                Screen('FillRect', window, allColors, allStimulators);
                if frameIdx == 1
                    marker = 100; % 100 is when the actual flashing begins
                    Screen('FillRect', window, getVPixxMarkerColor(marker), [0,0,1,1]);
                end
                if trialEventMarkers(frameIdx) ~=0
                    marker = trialEventMarkers(frameIdx);
                    Screen('FillRect', window, getVPixxMarkerColor(marker), [0,0,1,1]);
                end
                
                vbl=Screen('Flip',window);
            end
            timingData(trialIdx,2)=  {string(datestr(now,'dd-mm-yyyy HH:MM:SS FFF'))};
           
           marker = 101; % 101 is when the trial ends
           Screen('FillRect', window, getVPixxMarkerColor(marker), [0,0,1,1]);
           Screen('Flip',window);
           KbStrokeWait;
            
        end
        
        
    catch
        Screen('CloseAll');
        psychrethrow(psychlasterror);
    end
    
    Priority(defaultPriority);
    ShowCursor();
    Screen( 'CloseAll' );
    
end




% issue with synchronisation?? how to solve this?
% how to keep sychronise the recording with the stimulation?












