function [ trialSequence ] = getSequence( targets, trialsPerFrequency )
% returns a randomised trial sequence
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