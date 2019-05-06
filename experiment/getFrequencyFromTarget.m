function [frequency] = getFrequencyFromTarget(target, targets, frequencies)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here
    [numFreqs, tPerFreq]= size(targets);
    for i = 1:numFreqs
        for j = 1:tPerFreq
            if target == targets(i,j)
                frequency = frequencies(i);
            end
        end
    end

end

