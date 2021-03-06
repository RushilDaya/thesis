function [ minScore,maxScore ] = ex2_getMinMaxScore(trials)
%returns the minimum and classifier score for a set of trials

    minScore = 0;
    maxScore = 0;
    for i = 1:length(trials)
        predictions = trials{i}('predictions');
        trialMax = max(predictions);
        trialMin = min(predictions);
        
        if trialMax > maxScore
            maxScore = trialMax;
        end
        if trialMin < minScore
            minScore = trialMin;
        end
    end
end

