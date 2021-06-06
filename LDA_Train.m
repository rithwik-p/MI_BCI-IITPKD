function ldaParams = LDA_Train(trainingData)

%checking that the number of training classes is 2
if size(unique(trainingData(:,size(trainingData,2))),1) ~= 2
    display('ERROR: The LDA classifier can only deal with two classes !');
    return;
end

%dividing data into two classes (and removing the label)
ldaParams.classLabels = unique(trainingData(:,end));
class1Data = trainingData(trainingData(:,end)==ldaParams.classLabels(1),1:(end-1));
class2Data = trainingData(trainingData(:,end)==ldaParams.classLabels(2),1:(end-1));

%mean vector estimation for each class
mu1 = mean(class1Data);
mu2 = mean(class2Data);

%covariance matrix estimation
sigma1 = cov(class1Data);
sigma2 = cov(class2Data);
sigma = (sigma1 + sigma2)/2;

%computing the discriminant hyperplane coefficients
sigmaInv = inv(sigma);
a0 = - (1/2) * (mu1 + mu2) * sigmaInv * (mu1 - mu2)';
a1N = sigmaInv * (mu1 - mu2)';

ldaParams.a0 = a0;
ldaParams.a1N = a1N;