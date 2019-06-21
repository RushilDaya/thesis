function a_spatiotemporal = getSpatiotemporalPattern( segments, is_target, subtractNontargets )
%CALCULATESPATIOTEMPORALACTIVATIONPATTERN Calculates the spatiotemporal activation pattern for the SSVEP paradigm

	mean_target = mean(segments(:,:,is_target == 1),3);
	if subtractNontargets
	 	mean_nontarget = mean(segments(:,:,is_target == 0), 3);
	end
	
	if ~subtractNontargets
		a_spatiotemporal = mean_target;
	else
		a_spatiotemporal = mean_target - mean_nontarget	;
	end
end

