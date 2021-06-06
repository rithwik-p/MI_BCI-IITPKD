function [bestGamma bestBeta bestScore] = R_CSPWithBestParams(trainingEEGSignals, gammaList, betaList, k, nbFilterPairs)

%identifying the k subtraining set and validation set
disp('generating the subtraining and validation sets for each fold...');
subTrainingSets = cell(k,1);
validationSets = cell(k,1);
classLabels = unique(trainingEEGSignals.y);
%dividing the data according to each class
trainingSetClass1 = getSubDataSet(trainingEEGSignals, trainingEEGSignals.y == classLabels(1));
trainingSetClass2 = getSubDataSet(trainingEEGSignals, trainingEEGSignals.y == classLabels(2));
nbTrials1 = length(trainingSetClass1.y);
nbTrials2 = length(trainingSetClass2.y);
sizeChunk1 = floor(nbTrials1/k);
sizeChunk2 = floor(nbTrials2/k);
clear trainingEEGSignals;

%generating the different training/testing sets of the cross validation
for iter=1:k            
    subTrainingSetClass1 = getSubDataSet(trainingSetClass1, [1:(iter-1)*sizeChunk1 (iter*sizeChunk1+1):nbTrials1]);
    subTrainingSetClass2 = getSubDataSet(trainingSetClass2, [1:(iter-1)*sizeChunk2 (iter*sizeChunk2+1):nbTrials2]);
    validationSetClass1 = getSubDataSet(trainingSetClass1, ((iter-1)*sizeChunk1+1):(iter*sizeChunk1));
    validationSetClass2 = getSubDataSet(trainingSetClass2, ((iter-1)*sizeChunk2+1):(iter*sizeChunk2));
    subTrainingSets{iter} = concat2Signals(subTrainingSetClass1, subTrainingSetClass2);
    clear subTrainingSetClass1; clear subTrainingSetClass2;
    validationSets{iter} = concat2Signals(validationSetClass1, validationSetClass2);
    clear validationSetClass1; clear validationSetClass2;
end

%evaluating the performances of the difference potential hyperparameters
bestScore = 0;

roc_score = [];
roc_labels = [];

%computing the k-fold cross validation accuracy for each hyperparameter
%values using a LDA as classifier
for gamma = gammaList
    for beta = betaList        
        score = 0;
        for iter=1:k
            %learning CSP spatial filters
            CSPMatrix = learn_R_CSP(subTrainingSets{iter},gamma, beta);
            featureTrain = extractCSPFeatures(subTrainingSets{iter}, CSPMatrix, nbFilterPairs);
            LDAModel = LDA_Train(featureTrain);            
            featureTest = extractCSPFeatures(validationSets{iter}, CSPMatrix, nbFilterPairs);
            results = LDA_Test(featureTest, LDAModel);
            localScore = results.accuracy;
            score = score + localScore;

            roc_score = horzcat(roc_score,results.score);
            roc_labels = vertcat(roc_labels,results.trueLabels);
            
        end
        score = score / k;             
        if score > bestScore
            bestScore = score;
            bestGamma = gamma;
            bestBeta = beta;
        end
    end
end         