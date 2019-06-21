classdef SpatiotemporalBeamformer < handle
	%BEAMFORMER_SPATIOTEMPORAL Summary of this class goes here
	%   Detailed explanation goes here
	
	properties
		activation_pattern;
		weights;
	end

	properties (Access = private)
		nbChannels;
	end
	
	methods
		function B = SpatiotemporalBeamformer(pattern)
			B.activation_pattern = pattern;
			B.nbChannels = size(pattern,1);
		end
		
		function calculate_weights(B, epochs)
			epochs = B.concat_rows(epochs);
			a = B.concat_rows(B.activation_pattern);

			covar = cov(epochs);
			inv_covar = pinv(covar);
			
			B.weights = (inv_covar * a') / (a * inv_covar * a');
		end
		
		function y = apply_beamforming(B, epochs)
			epochs = B.concat_rows(epochs);
			y = epochs * B.weights;
		end
		
		function fig = plotActivationPattern(B, fig)
			if nargin < 3
				fig = figure();
			else
				clf(fig);
			end
	
			imagesc(B.activation_pattern);
		end
		
		function fig = plotWeights(B, fig)
			if nargin < 3
				fig = figure();
			else
				clf(fig);
			end
			
			samples_per_elec = numel(B.weights) / B.nbChannels;
			sep_elec = zeros(B.nbChannels, samples_per_elec);
			for i = 1 : B.nbChannels
				sep_elec(i,:) = B.weights((i-1)*samples_per_elec + 1 : i*samples_per_elec);
			end
			imagesc(sep_elec);
		end
	end
	
	methods (Access = private)
		function ep = concat_rows(~, epochs)
			ep_length = size(epochs,2) * size(epochs,1);
			ep = zeros(size(epochs,3), ep_length);
			for i = 1 : size(epochs, 3)
				ep(i,:) = reshape(epochs(:,:,i)', 1, ep_length);
			end
		end
	end
end

