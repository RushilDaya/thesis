function [segments, marker] = cutSegments( trial, markers, frequency, sample_rate )
%CUTSEGMENTS Cuts the trial into a set of segments.
%	INPUT
%		Trial : matrix (nb_electrodes, samples)
%			The segement of the recording to be cut.
%       Markers : vector (1 x samples)
%           The markers sent during the trial
%		Frequency : int
%			The frequency to use for cutting
%		Sample_Rate : int
%			The sample rate of the recording
%	OUTPUT
%		Epochs : matrix (nb_electrodes, samples, nb_epochs)
%			The segments

	nb_electrodes = size(trial,1);
	trial_length = size(trial,2);
	stimulation_duration = trial_length / sample_rate;
	
	% Cut individual epochs
	nb_epochs = floor(stimulation_duration * frequency);
	epoch_start_idx = round((0 : nb_epochs-1) * (1/frequency) * sample_rate) + 1;
	epoch_length = floor(sample_rate/frequency);

	segments = zeros(nb_electrodes, epoch_length, nb_epochs);
    marker = zeros(1, nb_epochs);
    for e = 1 : nb_epochs
		segments(:,:,e) = trial(:, epoch_start_idx(e):epoch_start_idx(e)+epoch_length-1);
        
        tmpMarkers = markers(epoch_start_idx(e):epoch_start_idx(e)+epoch_length-1);
        markerIndex = find(tmpMarkers);
        if numel(markerIndex) > 0 
            if numel(markerIndex) > 1
                error('Cut Segments : Invalid markers!');
            else
                marker(e) = tmpMarkers(markerIndex);
            end
        else
            marker(e) = 0;
        end
    end
end

