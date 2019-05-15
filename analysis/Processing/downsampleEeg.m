function epochs = downsampleEeg(epochs, current_sample_rate, new_sample_rate) 
    % Downsample
	nb_samples = size(epochs,2);
	idx = round(linspace(1, nb_samples, round(nb_samples/current_sample_rate * new_sample_rate)));
	epochs = epochs(:,idx,:);
end