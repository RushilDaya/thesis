function strechedMat = rd_splinesStrech(unstrechedMat, timeWindowSize,sampleRate)
%takes an unstreached matrix of length N and cubic spline interpolates it
%to cover a length equaling the timeWindowSize*sampleRate

newLength = round(timeWindowSize*sampleRate);
strechedMat =[];

for i = 1:size(unstrechedMat,3)
    oldSignal = unstrechedMat(:,:,i);
    newSignal = resample(oldSignal, newLength, size(unstrechedMat,2));
    strechedMat = cat(3, strechedMat, newSignal);
end
end

