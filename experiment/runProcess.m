function [ timingData ] = runProcess(targets, trialSequence, headerDisplay, flickerDisplay, eventMarkers, frequencies)

    % perform the actual displaying to screen here
    % 1. initialise the screen
    % 2. loop over trials
   
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
        [allStimulators, numFrequencies, targetsPerFrequency] = screenSetup(screenRect, targets);
        
        headerPartTemp = headerDisplay(int2str(targets(1,1)));
        headerPartLength = length(headerPartTemp(1,1,:));
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
                    target = trialSequence(trialIdx);
                    frequencyMarker = getFrequencyFromTarget(target,targets,frequencies)
                    Screen('FillRect', window, getVPixxMarkerColor(frequencyMarker), [0,0,1,1]);
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
                    marker = 100 % 100 is when the actual flashing begins
                    Screen('FillRect', window, getVPixxMarkerColor(marker), [0,0,1,1]);
                end
                if trialEventMarkers(frameIdx) ~=0
                    marker = trialEventMarkers(frameIdx)
                    Screen('FillRect', window, getVPixxMarkerColor(marker), [0,0,1,1]);
                end
                
                vbl=Screen('Flip',window);
            end
            timingData(trialIdx,2)=  {string(datestr(now,'dd-mm-yyyy HH:MM:SS FFF'))};
           
           marker = 101 % 101 is when the trial ends
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

