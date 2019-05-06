function [ allStimulators, numFrequencies, targetsPerFrequency ] = screenSetup( screenRect, targets)
% determines the positioning of the screen rectangles

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

end

