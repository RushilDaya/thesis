function [ details ] = frequencySwitchStimulation(  trialsPerFrequency, eventsPerTrial, eventLengthSeconds, frameRate, frequencies)
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
TARGETS = getTargets();
details('targets')=TARGETS;
TRIAL_SEQUENCE = getSequence(TARGETS, trialsPerFrequency);
details('trialSequence')=TRIAL_SEQUENCE;
HEADER_DISPLAY = getHeaderDisplays(TARGETS, frameRate);
PRETRIAL_FLICKER_SECONDS = eventLengthSeconds;
details('preTrialFlickerSeconds')=PRETRIAL_FLICKER_SECONDS;
FLICKER_DISPLAY = getFlickerDisplays(TARGETS, frameRate, eventsPerTrial,eventLengthSeconds ,frequencies, PRETRIAL_FLICKER_SECONDS);

timingData = runProcess(TARGETS, TRIAL_SEQUENCE, HEADER_DISPLAY, FLICKER_DISPLAY);
details('timingData')=timingData;

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
         
         targetPatterns = ones(numberOfFrequencies,numberOfTargetsPerFrequency, framesGuide+framesPause);
         targetPatterns(i,j,1:framesGuide) = zeros(1,1,framesGuide);
         headerDisplay(key) = targetPatterns;
     end
 end
end
function [FlickerDisplay] =  getFlickerDisplays(targets, frameRate, eventsPerTrial, eventLengthSeconds, frequencies, preTrialFlickerSeconds)
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
 
 for i = 1:numberOfFrequencies
     for j = 1:numberOfTargetsPerFrequency
         key = int2str(targets(i,j));
         iNext = mod(i,numberOfFrequencies)+1;
         FlickerDisplay(key) = generateOneSequence(frequencies(i),frequencies(iNext),j,FRAMES_TRIAL, FRAMES_PRETRIAL ,frameRate, eventsPerTrial, eventLengthSeconds);
     end
 end
end

function [sequence] = generateOneSequence(frequency, eventFrequency, eventOffset,framesTrial,framesPreTrial ,frameRate, eventsPerTrial, eventLengthSeconds)
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
        if periodIndex >= eventOffset_corrected*(framesPerEvent)  && periodIndex < (eventOffset_corrected+1)*(framesPerEvent)
            controlMask(i) = 1; % when the control mask ==1 we are in the event (off)
        end
    end
    %%% todo lets do frequency switching
    sequence = zeros(1,totalNumFrames);
    for i = 1:totalNumFrames
        if controlMask(i)==1
            sequence(i) = framesEvent(i);
        else
            sequence(i)=frames(i);
        end
    end
    plot(sequence);
end

function [timingData] = runProcess(targets, trialSequence, headerDisplay, flickerDisplay)
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
        
        ifi = Screen('GetFlipInterval', window);

        
        for trialIdx = 1:length(trialSequence)
            % show header part
            headerOfInterest = headerDisplay(int2str(trialSequence(trialIdx)));
            trialSequence(trialIdx);
           
            vbl = Screen('Flip', window);
            
            %datestr(now,'dd-mm-yyyy HH:MM:SS FFF')
            for frameIdx = 1:headerPartLength
                headerFrame = headerOfInterest(:,:,frameIdx);
                allColors = 255*ones(3,numFrequencies*targetsPerFrequency);
                flatHeader = reshape(headerFrame',[1,numFrequencies*targetsPerFrequency]);
                allColors(2,:) = allColors(2,:).*(flatHeader);
                allColors(3,:) = allColors(3,:).*(flatHeader);
                Screen('FillRect', window, allColors, allStimulators);
                vbl=Screen('Flip',window,vbl+ifi);
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
                vbl=Screen('Flip',window,vbl+0.9*ifi);
            end
            timingData(trialIdx,2)=  {string(datestr(now,'dd-mm-yyyy HH:MM:SS FFF'))};
           
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

