function strechedSignal = rd_strechSignal(signal, sampleRate,frequency, actualTime)
%RD_STRECHSIGNAL Summary of this function goes here
%   Detailed explanation goes here

    dataPoints = round(sampleRate*actualTime);
    strechedSignal = zeros(1,dataPoints);
    
    dataPointsPerPeriod = round(sampleRate/frequency);
    numPeriods = floor(dataPoints/dataPointsPerPeriod);
    
    for i = 1:numPeriods
        beamFormedSection = repmat([signal(i)],[1,dataPointsPerPeriod]);
        strechedSignal((i-1)*dataPointsPerPeriod+1:i*dataPointsPerPeriod) = beamFormedSection;
    end


end