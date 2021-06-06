function CSPMatrix = learn_CSP(targetSubjectEEGSignals)


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
    EE = E * E';
    EE(isnan(EE))=0;
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

[V,D] = eig(covMatrices{1,1},covMatrices{1,1}+covMatrices{2,1});
CSPMatrix = V;