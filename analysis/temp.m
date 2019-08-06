clear
clc

load('data/experiment2_knownFreq_modifiedCase.mat');

% lets for a certain paradigm look at the effect of frequency distribution
% across subject
subset = tabular(strcmp(tabular.paradigm,'frequency'),:);
[1 .0 .0]
frequencies = [11,13,15];
boxData = [];
for freqIdx = 1:3
    frequency = frequencies(freqIdx);
    tempData = subset(subset.frequency == frequency,:);
    allSubjects = []
    for subject = 1:5
        subjectData = tempData(tempData.subject == subject,:);
        column = subjectData.threshBest;
        allSubjects = cat(2,allSubjects,column);
    end
    boxData = cat(3,boxData,allSubjects);
end

% colors = {[1 .0 .0],[.0 .0 1],[.1 0.8 .1]};
% legend_text = {'11 Hz','13 Hz','15 Hz',};
% xlabels = {'1','2','3','4','5'}; 
% figure, rd_makeBoxPlots(boxData, colors, xlabels, legend_text );
% xlabel('subjects');
% ylabel('best Threshold');


subject = 5;
%ranksum(boxData(:,subject,1),boxData(:,subject,2))
ranksum(boxData(:,subject,1),boxData(:,subject,3))
%ranksum(boxData(:,subject,2),boxData(:,subject,3))

