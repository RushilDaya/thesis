function [newData, newLabels] = rd_randomiseLabels(oldData, oldLabels )
%RD_RANDOMISELABELS the oldData and newData are both cell arrays 
% the each row ACROSS cell arrays is a single featureRow - they must all be
% shifted together

newIdxs = randperm(size(oldLabels,2));
newLabels = oldLabels(1,newIdxs);

for i = 1:size(oldData,2)
    newData{i} = oldData{i}(:,:,newIdxs);
end
end
