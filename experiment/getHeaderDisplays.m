function [headerDisplay] = getHeaderDisplays(targets, frameRate, guideSeconds, offSeconds)
% given a frame rate and a particular target
% returns the specific sequence of header display frames
    
   headerDisplay = containers.Map;
   [numberOfFrequencies, numberOfTargetsPerFrequency] = size(targets);
   
   for i = 1:numberOfFrequencies
       for j = 1:numberOfTargetsPerFrequency
           key = int2str(targets(i,j));
           framesGuide = frameRate*guideSeconds;
           framesPause = frameRate*offSeconds;
           
           targetPatterns = ones(numberOfFrequencies, numberOfTargetsPerFrequency, framesGuide+framesPause);
           targetPatterns(i,j,1:framesGuide) = zeros(1,1,framesGuide);
           headerDisplay(key) = targetPatterns;
           
       end
   end
end
