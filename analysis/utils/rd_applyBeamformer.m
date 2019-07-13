function beamformedSignal = rd_applyBeamformer(singleTrial,beamformer, frequency, sampleRate, averagingPeriod)
%takes a beamformer of a particular frequency and applies it to a continous
%signal. 

    beamformedSignal =[];
    periodLength = round(sampleRate/frequency);
    numPeriods = floor(size(singleTrial,2)/periodLength);
    
    periods = [];
    for i = 1:numPeriods
        singlePeriod = singleTrial(:, periodLength*(i-1)+1:periodLength*i);
        periods = cat(3,periods,singlePeriod);
    end
    %perform the averaging step
    periodsAveraged = periods(:,:,1:averagingPeriod-1);
    for i = averagingPeriod:numPeriods
        averagedPeriod = mean(periods(:,:,i-averagingPeriod+1:i),3);
        periodsAveraged = cat(3, periodsAveraged, averagedPeriod);
    end
    
    
    for i=1:numPeriods
        input = periodsAveraged(:,:,i);
        y = beamformer.apply_beamforming(input);
        beamformedSignal = cat(2,beamformedSignal,y);
    end
    

end