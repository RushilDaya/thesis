classdef dataExplorer < handle
    % data container for processing stage
    
    properties
        rawEEG;
        trainingSegments;
        rawLabels;
        channelLabels;
        selectedChannel;
        frequencyMarkers;
        frequency;
        sampleRate;
    end
    
    methods
        function DE = dataExplorer(fileName, frequencies)
            
            data = loadCurryData(fileName,'Synamps');
            ref_idc = ismember(data.channel_names, {'TP9', 'TP10'});
            assert(numel(find(ref_idc)) == 2);
            EEG = data.EEG - repmat(mean(data.EEG(ref_idc,:),1), size(data.EEG,1),1);
            DE.rawEEG = filterBetween(EEG, data.sample_rate,4,30,4);
            DE.channelLabels = data.channel_names;
            
            DE.rawLabels = data.labels;
            DE.selectedChannel = 1;
            DE.sampleRate = data.sample_rate;
            
            DE.setFrequency(frequencies(1));
        end
        
        function changeChannel(DE,newChannel)
            for i = 1:length(DE.channelLabels)
                if strcmp(DE.channelLabels(i),newChannel)
                    DE.selectedChannel = i;
                end
            end
        end
        
        function setFrequency(DE,frequency)
            DE.frequency = frequency;
            
            markers = find(DE.rawLabels == frequency);
            markersStart = find(DE.rawLabels == 100);
            markersStop = find(DE.rawLabels == 101);
            
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
            
            segments = zeros(length(markers),size(DE.rawEEG,1),maxLength);
            
            for i = 1:length(markers)
                marker = markers(i);
                start = markersStart(markersStart > marker);
                start = start(1);
                temp = reshape(DE.rawEEG(:,start:start+maxLength-1),size(segments(i,:,:)));
                segments(i,:,:) = temp;
            end
            DE.trainingSegments = segments;
        end
        function plotFFT(DE)
            % shows good behaviour on the fft
            channel = DE.selectedChannel;
            frequency = DE.frequency;
            sampleRate = DE.sampleRate;
            
            signals = DE.trainingSegments(:,channel,:);
            numSignals = size(signals,1);
            
            for i = 1:numSignals
                signal = signals(i,1,:);
                signal = reshape(signal, [1,size(signal,3)]);
                
                fftSig = fft(signal);
                fftSig = abs(fftSig);
                frequencies = sampleRate/2*linspace(0,1,length(fftSig)/2+1);
                figure,plot(frequencies,fftSig(1:floor(length(fftSig)/2)+1));
                xlim([0.0 50]);
                
            end     
            
        end
        
        function plotAverages(DE, periods)
            % shows good behavior on the averaging
            channel = DE.selectedChannel;
            frequency = DE.frequency;
            sampleRate = DE.sampleRate;
            
            signals = DE.trainingSegments(:,channel,:);
            numSignals = size(signals,1);
            
            for i = 1:numSignals
                signal = signals(i,1,:);
                signal = reshape(signal,[1,size(signal,3)]);
                periodLength = round(sampleRate/frequency);
                
                meanSignal = zeros(1,periodLength);
                for j = 1:periods
                    meanSignal = meanSignal + signal((j-1)*periodLength+1:j*periodLength);
                end
                figure,plot(meanSignal)
                
            end
        end
      
        
    end
    
end

