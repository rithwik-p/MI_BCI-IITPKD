function CSPMatrix = learn_R_CSP(targetSubjectEEGSignals, gamma, beta)


%check and initializations
nbChannels = size(targetSubjectEEGSignals.x,2);
nbTrials = size(targetSubjectEEGSignals.x,3);
classLabels = unique(targetSubjectEEGSignals.y);
nbClasses = length(classLabels);
if nbClasses ~= 2
    disp('ERROR! CSP can only be used for two classes');
    return;
end

%building the covariance matrices for the target subject
covMatrices = cell(nbClasses,1); %the covariance matrices for each class

%computing the normalized covariance matrices for each trial
trialCov = zeros(nbChannels,nbChannels,nbTrials);
for t=1:nbTrials
    E = targetSubjectEEGSignals.x(:,:,t)';
    E(isnan(E))=0;
    EE = E * E';
    trialCov(:,:,t) = EE ./ trace(EE);
    g(:,:,t)=cov(E');
end
clear E;
clear EE;

genCovMatrices=cell(nbClasses,1);

%computing the covariance matrix for each class
for c=1:nbClasses      
    covMatrices{c,1} = sum(trialCov(:,:,targetSubjectEEGSignals.y == classLabels(c)),3); 
    genCovMatrices{c}= sum(g(:,:,targetSubjectEEGSignals.y == classLabels(c)),3);
    %covMatrices{c,1} = covMatrices{c,1} ./ sum(targetSubjectEEGSignals.y == classLabels(c)); %IS THIS NECESSARY? TO CHECK !!
end

%computing the regularized covariance matrices
covMatricesReg = cell(nbClasses,1); 
for c=1:nbClasses 
    sigmaHat = ((1-beta)*covMatrices{c,1} + beta*genCovMatrices{c}) / nbTrials;%((1-beta)*nbTrials + beta*nbTrialOtherTotal);
    covMatricesReg{c} = (1-gamma)*sigmaHat + (gamma/size(sigmaHat,1))*trace(sigmaHat)*eye(size(sigmaHat));
end

%computing the matrix M to be decomposed
M = inv(covMatricesReg{2}) * covMatricesReg{1};

%eigen value decomposition of matrix M
[U D] = eig(M);
eigenvalues = diag(D);
[eigenvalues egIndex] = sort(eigenvalues, 'descend');
U = U(:,egIndex);
CSPMatrix = U';