function result = LDA_Test(testData, ldaParams)

%Input:
%testData: a matrix representing the feature vectors to be classified by LDA
%this matrix is a matrix with size [nT,nF+1] where
%          nT          = number of training data,
%          nF          = number of features (input dimension),
%          lastcol     = class labels (one per training data) 
%ldaParams: the LDA hyperplane params (obtained after training with LDA_Train)
%
%Output: 
%result: the classification results where:
%   result.output: the predicted classification output for each feature vector
%   result.classes: the predicted class label for each feature vector
%   result.accuracy: the accuracy obtained (%)
%

nbData = size(testData,1);
nbFeaturesPlus1 = size(testData,2);
trueLabels = testData(:,nbFeaturesPlus1);
result.output = zeros(nbData,1);
result.classes = zeros(nbData,1);

%classifying the input data
for i=1:size(testData,1)
        inputVec = testData(i,1:(nbFeaturesPlus1-1))';
        result.score(i) = ldaParams.a0 + ldaParams.a1N' * inputVec;
        if result.score(i) >= 0       
           result.classes(i) = ldaParams.classLabels(1);
        else
           result.classes(i) = ldaParams.classLabels(2);
        end        
        result.output(i) = result.score(i);
end
result.trueLabels = trueLabels;

%computing the classification accuracy
nbErrors = sum(trueLabels~=result.classes);
result.accuracy = ((nbData - nbErrors)/nbData) * 100;
