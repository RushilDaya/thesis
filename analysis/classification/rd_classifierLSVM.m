function [ trainedClassifier, validationPredictions  ] = rd_classifierLSVM(dataset,folds)
%RD_CLASSIFIERLSVM Summary of this function goes here
%   Detailed explanation goes here
numColumns = size(dataset,2);
columnNames = {};
for i = 1:numColumns
    columnNames{i} = char(strcat('column_',string(i)));
end

inputTable = array2table(dataset,'VariableNames', columnNames);
predictorNames = columnNames(1:numColumns-1);
predictors = inputTable(:,predictorNames);
response = dataset(:,numColumns);
isCategoricalPredictor = repmat([false],[1,numColumns-1]);

classificationSVM = fitcsvm(...
    predictors, ...
    response, ...
    'KernelFunction', 'linear', ...
    'PolynomialOrder', [], ...
    'KernelScale', 'auto', ...
    'BoxConstraint', 1, ...
    'Standardize', true, ...
    'ClassNames', [0; 1]);


% Create the result struct with predict function
predictorExtractionFcn = @(x) array2table(x, 'VariableNames', predictorNames);
svmPredictFcn = @(x) predict(classificationSVM, x);
trainedClassifier.predictFcn = @(x) svmPredictFcn(predictorExtractionFcn(x));

% Add additional fields to the result struct
trainedClassifier.ClassificationSVM = classificationSVM;
trainedClassifier.About = 'This struct is a trained classifier exported from Classification Learner R2016b.';
trainedClassifier.HowToPredict = sprintf('To make predictions on a new predictor column matrix, X, use: \n  yfit = c.predictFcn(X) \nreplacing ''c'' with the name of the variable that is this struct, e.g. ''trainedClassifier''. \n \nX must contain exactly 36 columns because this classifier was trained using 36 predictors. \nX must contain only predictor columns in exactly the same order and format as your training \ndata. Do not include the response column or any columns you did not import into \nClassification Learner. \n \nFor more information, see <a href="matlab:helpview(fullfile(docroot, ''stats'', ''stats.map''), ''appclassification_exportmodeltoworkspace'')">How to predict using an exported model</a>.');

inputTable = array2table(dataset,'VariableNames', columnNames);
predictorNames = columnNames(1:numColumns-1);
predictors = inputTable(:,predictorNames);
response = dataset(:,numColumns);
isCategoricalPredictor = repmat([false],[1,numColumns-1]);


partitionedModel = crossval(trainedClassifier.ClassificationSVM, 'KFold', folds);
% Compute validation accuracy
validationAccuracy = 1 - kfoldLoss(partitionedModel, 'LossFun', 'ClassifError');

% Compute validation predictions and scores
[validationPredictions, validationScores] = kfoldPredict(partitionedModel);

end

