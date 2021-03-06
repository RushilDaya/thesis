% look at the data generated from the first experiment ( the classifier
% results)
clear
clc
load('data/experiment1ResultsAll.mat');

inputData = cell2table(allResultsRows,'VariableNames',{'electrodes','averagePeriod',...
    'paradigm','sampleRate','subject','frequency','numFeatures',...
    'qsvmAcc','lsvmAcc','ldaAcc','qdaAcc'});


% first compute the averages across frequency and subject 
electrodes = [10];
sampleRates = [256];
paradigms = {'onoff'};
averagePeriods = [1,3,5];
numFeatures = [4,8,12];

summary = {};
for paradigmIdx = 1:length(paradigms)
 for electrodesIdx = 1:length(electrodes)
    for sampleRateIdx = 1:length(sampleRates)
        for averagePeriodIdx = 1:length(averagePeriods)
           for numFeaturesIdx = 1:length(numFeatures)

                AVERAGE_PERIOD = averagePeriods(averagePeriodIdx);
                ELECTRODES = electrodes(electrodesIdx);
                SAMPLE_RATE = sampleRates(sampleRateIdx);
                NUM_FEATURES = numFeatures(numFeaturesIdx);
                POI = paradigms{paradigmIdx};
                
                
                data = inputData(strcmp(inputData.paradigm,POI),:);
                data = data(data.averagePeriod == AVERAGE_PERIOD,:);
                data = data(data.electrodes == ELECTRODES,:);
                data = data(data.sampleRate == SAMPLE_RATE,:);
                data = data(data.numFeatures == NUM_FEATURES,:);

                meanLSVM = mean(data.lsvmAcc);
                meanQSVM = mean(data.qsvmAcc);
                meanLDA = mean(data.ldaAcc);
                meanQDA = mean(data.qdaAcc);     
                
                outputRow = {POI,ELECTRODES,SAMPLE_RATE,AVERAGE_PERIOD,NUM_FEATURES,...
                    meanLSVM,meanQSVM,meanLDA,meanQDA};
                summary = cat(1,summary,outputRow);
            end
        end
    end
 end
end
summary = cell2table(summary,'VariableNames',{'paradigm','electrodes','sampleRate',...
    'averagePeriod','numFeatures',...
    'qsvmAcc','lsvmAcc','ldaAcc','qdaAcc'});

% then we want to look at the performance of the differnt classfiers as a
% function of the experimental parameters

byParadigm = grpstats(summary,{'paradigm'},{'min','max','mean','std'},'DataVars',{'qsvmAcc','lsvmAcc','ldaAcc','qdaAcc'});
byElectrodes = grpstats(summary,{'electrodes'},{'min','max','mean','std'},'DataVars',{'qsvmAcc','lsvmAcc','ldaAcc','qdaAcc'});
bySampleRate = grpstats(summary,{'sampleRate'},{'min','max','mean','std'},'DataVars',{'qsvmAcc','lsvmAcc','ldaAcc','qdaAcc'});
byAveragePeriod = grpstats(summary,{'averagePeriod'},{'min','max','mean','std'},'DataVars',{'qsvmAcc','lsvmAcc','ldaAcc','qdaAcc'});
byNumFeatures = grpstats(summary,{'numFeatures'},{'min','max','mean','std'},'DataVars',{'qsvmAcc','lsvmAcc','ldaAcc','qdaAcc'});


% % to draw the data as a function of average period (across feature sizes)
% temp = inputData(strcmp(inputData.paradigm,'onoff')&...
%        inputData.electrodes == 10 & inputData.sampleRate == 256,: );
%    
% tempCol1 = temp(temp.averagePeriod == 1,:);
% tempCol2 = temp(temp.averagePeriod == 3,:);
% tempCol3 = temp(temp.averagePeriod == 5,:);
% 
% allTemps = cell({tempCol1,tempCol2,tempCol3});
% allTempsClassifiers = [];
% for i = 1:3
%     aa = allTemps{i};
%     bb = [aa.lsvmAcc, aa.qsvmAcc, aa.ldaAcc, aa.qdaAcc];
%     bb = reshape(bb,[45,1,4]);
%     allTempsClassifiers = cat(2,allTempsClassifiers,bb);
% end
% 
% boxData = allTempsClassifiers;
% colors = {[1 .0 .0],[.0 .0 1],[.1 0.8 .1],[.4 .3 0.6]};
% legend_text = {'lsvm','qsvm','lda','qda'};
% xlabels = {'1','3','5'}; 
% figure,rd_makeBoxPlots(boxData, colors, xlabels, legend_text )
% xlabel('moving average window size');
% ylabel('classifier accuracy');
% 
% % use the boxData to calculate the p-values.
% lsvmOne = boxData(:,3,1);
% qsvmOne = boxData(:,3,2);
% ldaOne = boxData(:,3,3);
% qdaOne = boxData(:,3,4);
% signrank(lsvmOne,qsvmOne)
% signrank(lsvmOne,ldaOne)
% signrank(lsvmOne,qdaOne)
% signrank(qsvmOne,ldaOne)
% signrank(qsvmOne,qdaOne)
% signrank(ldaOne,qdaOne)





% to draw the data as a function of feature sizes ( across average period)
% temp = inputData(strcmp(inputData.paradigm,'onoff')&...
%        inputData.electrodes == 10 & inputData.sampleRate == 256,: );
%    
% tempCol1 = temp(temp.numFeatures == 4,:);
% tempCol2 = temp(temp.numFeatures == 8,:);
% tempCol3 = temp(temp.numFeatures == 12,:);
% 
% allTemps = cell({tempCol1,tempCol2,tempCol3});
% allTempsClassifiers = [];
% for i = 1:3
%     aa = allTemps{i};
%     bb = [aa.lsvmAcc, aa.qsvmAcc, aa.ldaAcc, aa.qdaAcc];
%     bb = reshape(bb,[45,1,4]);
%     allTempsClassifiers = cat(2,allTempsClassifiers,bb);
% end
% 
% boxData = allTempsClassifiers;
% colors = {[1 .0 .0],[.0 .0 1],[.1 0.8 .1],[.4 .3 0.6]};
% legend_text = {'lsvm','qsvm','lda','qda'};
% xlabels = {'4','8','12'}; 
% figure, rd_makeBoxPlots(boxData, colors, xlabels, legend_text );
% xlabel('Feature vector size');
% ylabel('classifier accuracy');
% 
% lsvmOne = boxData(:,3,1);
% qsvmOne = boxData(:,3,2);
% ldaOne = boxData(:,3,3);
% qdaOne = boxData(:,3,4);
% signrank(lsvmOne,qsvmOne)
% signrank(lsvmOne,ldaOne)
% signrank(lsvmOne,qdaOne)
% signrank(qsvmOne,ldaOne)
% signrank(qsvmOne,qdaOne)
% signrank(ldaOne,qdaOne)



% %we want to here consider the effect of the beamformer parameters 
% %while fixing the other conditions in place
% temp = inputData(strcmp(inputData.paradigm,'onoff')&...
%        inputData.numFeatures == 12 & inputData.averagePeriod == 5,: );
% 
% electrodes3 = temp(temp.electrodes == 3,:);
% electrodes6 = temp(temp.electrodes == 6,:);
% electrodes10 = temp(temp.electrodes == 10,:);
% byElectrodes =cell({electrodes3, electrodes6, electrodes10});
% 
% boxData = [];
% for i = 1:3
%     electrodeSet = byElectrodes{i};
%     sr256 = electrodeSet(electrodeSet.sampleRate == 256,:);
%     sr512 = electrodeSet(electrodeSet.sampleRate == 512,:); 
%     sr1024 = electrodeSet(electrodeSet.sampleRate == 1024,:);
%     
%     lsvmResults = [sr256.lsvmAcc, sr512.lsvmAcc, sr1024.lsvmAcc];
%     boxData = cat(3,boxData,lsvmResults);
% end
%  
% colors = {[1 .0 .0],[.0 .0 1],[.1 0.8 .1]};
% legend_text = {'3 electrodes','6 electrodes','10 electrodes'};
% xlabels = {'256','512','1024'}; 
% figure, rd_makeBoxPlots(boxData, colors, xlabels, legend_text );
% xlabel('Sample Rate (Hz)');
% ylabel('classifier accuracy');
% 
% elect3 = boxData(:,1,3);
% elect6 = boxData(:,2,3);
% elect10 = boxData(:,3,3);
% 
% ranksum(elect3,elect6)
% ranksum(elect3,elect10)
% ranksum(elect6,elect10)
   

% we want to look at the box plot for the different stimulation paradigms
% in this case.

temp = inputData(inputData.numFeatures == 12 & inputData.averagePeriod == 5 &...
        inputData.electrodes == 10 & inputData.sampleRate == 256 & inputData.frequency ~= 13,:);

tempOnoff = temp(strcmp(temp.paradigm,'onoff'),:);
tempPhase = temp(strcmp(temp.paradigm,'phase'),:);
tempFreq =  temp(strcmp(temp.paradigm,'frequency'),:);

allTemps = cell({tempOnoff,tempPhase,tempFreq});
allTempsClassifiers = [];
for i = 1:3
    aa = allTemps{i};
    bb = [aa.lsvmAcc];
    bb = reshape(bb,[10,1,1]);
    allTempsClassifiers = cat(2,allTempsClassifiers,bb);
end

boxData = allTempsClassifiers;
colors = {[1 .0 .0]};
legend_text = {'lsvm'};
xlabels = {'onoff','phase switching','frequency switching'}; 
figure, rd_makeBoxPlots(boxData, colors, xlabels, legend_text );
xlabel('Stimulation Paradigm');
ylabel('classifier accuracy');

onoff= boxData(:,1);
phase = boxData(:,2);
freq = boxData(:,3);

ranksum(onoff,phase)
ranksum(onoff,freq)
ranksum(phase,freq)

% tempCol1 = temp(temp.numFeatures == 4,:);
% tempCol2 = temp(temp.numFeatures == 8,:);
% tempCol3 = temp(temp.numFeatures == 12,:);
% 
% allTemps = cell({tempCol1,tempCol2,tempCol3});
% allTempsClassifiers = [];
% for i = 1:3
%     aa = allTemps{i};
%     bb = [aa.lsvmAcc, aa.qsvmAcc, aa.ldaAcc, aa.qdaAcc];
%     bb = reshape(bb,[45,1,4]);
%     allTempsClassifiers = cat(2,allTempsClassifiers,bb);
% end
% 
% boxData = allTempsClassifiers;
% colors = {[1 .0 .0],[.0 .0 1],[.1 0.8 .1],[.4 .3 0.6]};
% legend_text = {'lsvm','qsvm','lda','qda'};
% xlabels = {'4','8','12'}; 
% figure, rd_makeBoxPlots(boxData, colors, xlabels, legend_text );
% xlabel('Feature vector size');
% ylabel('classifier accuracy');










%makeBoxPlots(byNumFeaturesPlotable,colors,xlabels,legent_text)

% % visually lets take the parameters which seemingly provide the best
% % performance
% PARADIGM = 'phase';
% ELECTRODES = 10 ;
% SAMPLE_RATE = 256;
% AVERAGE_PERIOD = 5;
% NUM_FEATURES = 12;
% 
% 
% best = inputData;
% best = best(strcmp(best.paradigm, PARADIGM),:);
% best = best(best.averagePeriod == AVERAGE_PERIOD,:);
% best = best(best.electrodes == ELECTRODES,:);
% best = best(best.sampleRate == SAMPLE_RATE,:);
% best = best(best.numFeatures == NUM_FEATURES,:);
% 
% bestBySubject = grpstats(best,{'subject'},{'min','max','mean','std'},'DataVars',{'qsvmAcc','lsvmAcc','ldaAcc','qdaAcc'})
% bestByFrequency = grpstats(best,{'frequency'},{'min','max','mean','std'},'DataVars',{'qsvmAcc','lsvmAcc','ldaAcc','qdaAcc'})