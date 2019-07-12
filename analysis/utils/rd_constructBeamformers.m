function beamformers = rd_constructBeamformers(eegData, labels, sampleRate, frequencies)
% will make one beamformer for each of the frequencies provided
% the output is an array of beamformers in the order of the frequencies


beamformers = {};
for freqIdx = 1:length(frequencies)
   frequency = frequencies(freqIdx);
   
   markers = find(labels == frequency);
   markersStart = find(labels == 100);
   markersStop = find(labels == 101);
   
   maxLength = 0;
   for i = 1:length(markers)
       marker = markers(i);
       start = markersStart(markersStart > marker);
       start = start(1);
       finish = markersStop(markersStop > marker);
       finish = finish(1);
       
       if finish - start > maxLength
           maxLength = finish - start;
       end
   end
   trials = [];
   for i = 1:length(markers)
       marker = markers(i);
       start = markersStart(markersStart > marker);
       start = start(1);
       trial = eegData(:,start:start+maxLength);
       trials = cat(3,trials, trial);
   end
   singlePeriods = rd_extractPeriods(trials, sampleRate, frequency);
   activationPattern = mean(singlePeriods,3);
   
   beamformer = SpatiotemporalBeamformer(activationPattern);
   beamformer.calculate_weights(singlePeriods);
   beamformers{freqIdx} = beamformer;
   
end
end 