
% data = allSegments;
% singleTrial = data(:,2,:);
% 
% cycles = 1818;
% singleTrial = singleTrial(:,:,1:19998);
% singleTrial =  reshape(singleTrial, [32, 19998]);
% 
% single = zeros(32,182);
% 
% for i = 1:1818
%     sIndex = (i-1)*182+1;
%     fIndex = (i)*182;
%     tmp = singleTrial(:,sIndex:fIndex);
%     single = single + tmp;
% end
% 
% heatmap(single);


% Select channels
channels = (1:6);

% Build the three beamformers
freqs = [13];
BFs = cell(1);
    mask = (cues == b);
    tmptrials = trials(channels,:,mask);
    tmpcues = cues(mask);

    % Cut into segments
    trainingSegments = [];
    for t = 1 : size(tmptrials,3)
        [seg,~] = cutSegments(tmptrials(:,:,t), zeros(1,size(tmptrials,2)), freqs(b), sampleRate);

        trainingSegments = cat(3, trainingSegments, seg);
    end

    % Make the beamformer
    pattern = getSpatiotemporalPattern(trainingSegments, ones(1,size(trainingSegments,3)), false);
    BF = SpatiotemporalBeamformer(pattern);
    BF.calculate_weights(trainingSegments);
    
    BFs{b} = BF;