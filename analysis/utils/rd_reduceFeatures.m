function newDataset = rd_reduceFeatures(oldDataset,numFeatures)
% reduces the number of features in a labelled dataset
% assumption is that the event is in the center of the
% feature vector so reduction happens from the sides

newDataset = zeros(size(oldDataset,1),numFeatures+1);

currentFeatures = size(oldDataset,2)-1;
leftOffset = floor((currentFeatures - numFeatures)/2)+1;

newDataset(:,1:numFeatures)=oldDataset(:,leftOffset:leftOffset+numFeatures-1);
newDataset(:,numFeatures+1)=oldDataset(:,currentFeatures+1);
end

