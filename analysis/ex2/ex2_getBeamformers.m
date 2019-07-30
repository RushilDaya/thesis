function beamformers = ex2_getBeamformers(subject, sampleRate, electrodes, frequencies)

    fileName = strcat('data/subject_',string(subject),'/training.dat');
    fileName = char(fileName);
    
    [data,labels] = rd_preProcessing(fileName,sampleRate, electrodes);
    beamformers = rd_constructBeamformers(data, labels, sampleRate, frequencies);
end
