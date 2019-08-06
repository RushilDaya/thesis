function extendedTrials = ex2_binariseEvents( trials, threshold )
% to each trial add a key value pair which contains the 'thresholded'
% events
extendedTrials = {};
for trIdx = 1:length(trials)
    trial = trials{trIdx};
    predictions = trial('predictions');
    predictions(predictions < threshold) = threshold;
    predictions = predictions  - threshold;
    
    candidates = find(predictions);
    
    % in this point we can play around with how to quantify events
    % do they need to be high for extended periods? do we take the mean?
    % do we take the first cross ??
    
    % as long as we look at the point of first crossing the first event is
    % always valid
    
   
    predictedEventList = zeros([1, length(predictions)]);
    
    if length(candidates) > 2
        filteredCandidates = [candidates(1)];
        for i = 2:length(candidates)
            if candidates(i) > candidates(i-1) + 1
                filteredCandidates =[filteredCandidates,candidates(i)];
            end
        end
        predictedEventList(filteredCandidates) = 1;
    end
    trial('eventPredictions') = predictedEventList;
    extendedTrials{trIdx}=trial;
end
end

