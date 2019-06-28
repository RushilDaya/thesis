clear;
clc;

% Load the training data

data = loadCurryData('../data/subject_1/training','Synamps');
ref_idc = ismember(data.channel_names, {'TP9', 'TP10'});
assert(numel(find(ref_idc)) == 2);
EEG = data.EEG - repmat(mean(data.EEG(ref_idc,:),1), size(data.EEG,1),1);
EEG = filterBetween(EEG, data.sample_rate,4,30,4);

frequencies = [11,13,15];

markers15 = find(data.labels == 11);
markersStart = find(data.labels == 100);
markersStop  = find(data.labels == 101);



allSegments = zeros(32,4,20000);

for i = 1:length(markers15)
    marker = markers15(i);
    start = markersStart(markersStart > marker);
    start = start(1);
    finish = markersStop(markersStop > marker);
    finish = finish(1);
    finish - start
    
    segment = EEG(:,start:finish);
    segment = segment(:,1:20000);
    allSegments(:,i,:)= segment;
end

single = reshape(allSegments(1,4,:),[1,20000]);
[p,q] = rat(1100/2000);
rsSingle = resample(single, p,q);

segments = zeros(1,110);
for i = 1:100
    segments = segments + rsSingle( 110*(i-1)+1 : 110*i );
end
plot(segments)


