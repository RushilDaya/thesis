function newFeatureSet = rd_isolateFreqFeatures( featureSet, blockIndex, blockCount)
%RD_ISOLATEFREQFEATURES Summary of this function goes here
%   Detailed explanation goes here

numFeatures = size(featureSet,2)-1;
blockWidth = numFeatures/blockCount;

newFeatureSet = zeros(size(featureSet,1),blockWidth+1);
newFeatureSet(:,1:blockWidth) = featureSet(:, blockWidth*(blockIndex-1)+1:blockWidth*blockIndex);
newFeatureSet(:,blockWidth+1)=featureSet(:,numFeatures+1)';

end
