function metrics = ex2_computeMetricsModified( extendedTrials )
    
    LAG_WINDOW =10; % may need a better way to tune this

    %computes different metrics 
    metrics = containers.Map;
    metrics('truePositives')=0;
    metrics('falsePositives')=0;
    metrics('falseNegatives')=0;
    metrics('trueNegatives')=0;
    
    for trialIdx = 1:length(extendedTrials)
        tp = 0;
        fp = 0;
        fn = 0;
        tn = 0;
        predictions = extendedTrials{trialIdx}('eventPredictions');
        actual = extendedTrials{trialIdx}('events');
        
        
        % first count the true negatives (pretty meaningless)
        for i = 1:length(predictions)
            if predictions(i) == 0 & actual(i) == 0
                tn = tn+1;
            end
        end
        % then count the true positives and the false positives
        % the predicted event can lag behind the true event to a degree
        for i = LAG_WINDOW+1:length(predictions)
            if predictions(i) == 1
                if ismember(1,actual(i-LAG_WINDOW:i))
                    tp = tp +1;
                else
                    fp = fp +1;
                end
            end
        end
        % last we need to look at the false negatives (missed events)
        for i = 1:length(predictions)-LAG_WINDOW
            if actual(i) == 1
                if ismember(1,predictions(i:i+LAG_WINDOW))
                    1;
                else
                    fn = fn + 1;
                end
            end
        end
        metrics('truePositives')= metrics('truePositives')+tp;
        metrics('falsePositives')= metrics('falsePositives')+fp;
        metrics('falseNegatives')= metrics('falseNegatives')+fn;
        metrics('trueNegatives')= metrics('trueNegatives')+tn;
        
    end
    
end