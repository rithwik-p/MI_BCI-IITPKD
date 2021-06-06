function features = extractCSPFeatures(EEGSignals, CSPMatrix, nbFilterPairs)

%initializations
nbTrials = size(EEGSignals.x,3);
features = zeros(nbTrials, 2*nbFilterPairs+1);
Filter = CSPMatrix([1:nbFilterPairs (end-nbFilterPairs+1):end],:);

%extracting the CSP features from each trial
for t=1:nbTrials    
    %projecting the data onto the CSP filters    
    projectedTrial = Filter * EEGSignals.x(:,:,t)';    
    
    %generating the features as the log variance of the projected signals
    variances = var(projectedTrial,0,2);  
%     %%
%     variances=gather(variances);
%     %%
    for f=1:length(variances)
        features(t,f) = log(variances(f));
    end
    features(t,end) = EEGSignals.y(t);    
end