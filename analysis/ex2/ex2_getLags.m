function lags = ex2_getLags( extendedTrials )
%EX2_GETLAGS Summary of this function goes here
%   Detailed explanation goes here

lags = [];
for trialIdx = 1:length(extendedTrials)
    trueEvents = extendedTrials{trialIdx}('events');
    predictedEvents = extendedTrials{trialIdx}('eventPredictions');
    
    % here we look at each event in the true events and determine determine
    % the lag between that event and the next predicted event
    % should see a lot of noise but an underlying gaussian as well.
    
    eventLocations = find(trueEvents);
    for eventIdx = 1:length(eventLocations)
        eventLoc = eventLocations(eventIdx);
        filteredPredictions = predictedEvents(eventLoc:end);
        predEvents  = find(filteredPredictions);
        if length(predEvents) >=1
            lags = [lags,predEvents(1)-1];
        end
    end
    
end


end

