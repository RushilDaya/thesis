clear;
DE = dataExplorerTraining('subject_1/training.dat',[11,13,15]);
CHANNELS = 8;
activation11 = DE.getActivationPattern(CHANNELS);

beamformer = SpatiotemporalBeamformer(activation11);
trainingSegments = DE.getTrainingEpochs(8,100);
beamformer.calculate_weights(trainingSegments(:,:,1:100));


y1 = [];
for i = 1:size(trainingSegments,3)
    
    tempx = trainingSegments(:,:,i);
    absTempx = tempx.^2;
    tempx = tempx/sqrt(sum(absTempx(:)));
    
    t = beamformer.apply_beamforming(tempx);
    y1 = cat(2,y1,t);
end


y2 = [];
for i = 1:size(trainingSegments,3)
    
    tempx = trainingSegments(:,:,i);
    tempx = flip(tempx,2);
    absTempx = tempx.^2;
    tempx = tempx/sqrt(sum(absTempx(:)));
    
    t = beamformer.apply_beamforming(tempx);
    y2 = cat(2,y2,t);
end

plot(beamformer.weights)