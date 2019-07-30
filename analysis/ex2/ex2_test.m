function ex2_test(classifiers, beamformedTrials)
% a scratch function which is being used 
% just to make sure things are going as expected
% its not for actual work
    cc =2;

    classifier = classifiers{cc};
    data = beamformedTrials{cc};
    testTrials = data('signalsTest');
    for trialIdx = 1:size(testTrials,2)
        trial = testTrials{trialIdx}{cc};
        c_outs = [];
        for pt = 1:size(trial,2)-12
            segment = trial(pt:pt+11);
            segment = segment - mean(segment,2);
            [pred,score] = classifier.predictFcn(segment);
            c_outs = cat(2,c_outs, [score(1)]);
        end 
        figure,plot(c_outs)
        hold on 
        plot(trial)
    end
end

