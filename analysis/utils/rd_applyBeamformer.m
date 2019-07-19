function beamformedSignal = rd_applyBeamformer(singleTrial,beamformer, frequency, sampleRate, averagingPeriod)
%takes a beamformer of a particular frequency and applies it to a continous
%signal. 

    beamformedSignal =[];
    periodLength = round(sampleRate/frequency);
    trialLength = size(singleTrial,2);
    stimulationDuration = trialLength/sampleRate;
    
    numPeriods = floor(stimulationDuration*frequency);
    
    periods = [];
    for i = 1:numPeriods
        singlePeriodStart = round((i-1)*(sampleRate)*(1/frequency))+1;
        singlePeriod = singleTrial(:, singlePeriodStart:singlePeriodStart+periodLength-1);
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