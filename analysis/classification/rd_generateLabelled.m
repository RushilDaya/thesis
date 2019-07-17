function [ features, labels ] = rd_generateLabelled( bformedTrials, eventStarts, eventEnds, featuresPerVect,sampleRate, bfFrequency)
   % generates labelled data around the feature point for a single signal
   % returns vectors of length featuresPerVect with labels for events /
   % non-events
   
   eventSegments = [];
   nonEventSegments = [];
   
   nBack = ceil(featuresPerVect/2);
   nForward = floor(featuresPerVect/2);
   
   for trialIdx = 1:size(bformedTrials,3)
       wholeTrial = bformedTrials(1,:,trialIdx);
       eventsTrialStart = eventStarts(1,:,trialIdx);
       eventsTrialStop = eventEnds(1,:,trialIdx);
       eventsTrialStop = cat(2,[1],eventsTrialStop);
       
       for eventIdx = 1:size(eventsTrialStart,2)
           eventTime = eventsTrialStart(eventIdx);
           nearestBFSample  = round(eventTime/(sampleRate/bfFrequency));
           eventSegment = wholeTrial(nearestBFSample-nBack+1:nearestBFSample+nForward);
           eventSegments = cat(3,eventSegments,eventSegment);
       end
       
       for nEventIdx = 1:size(eventsTrialStart,2)
           % get a non-event segment - from the sequences that fall between
           % two events.
           leftBound = eventsTrialStop(nEventIdx);
           rightBound = eventsTrialStart(nEventIdx);
           centerPoint = round(mean([rightBound,leftBound]));
           nearestBFSample = round(centerPoint/(sampleRate/bfFrequency));
           nonEventSegment = wholeTrial(nearestBFSample-nBack+1:nearestBFSample+nForward);
           nonEventSegments = cat(3,nonEventSegments, nonEventSegment);
       end
       
       
   end
   features = cat(3, eventSegments, nonEventSegments);
   labels = cat(2,ones(1,size(eventSegments,3)),zeros(1,size(nonEventSegments,3)));
   
   
end