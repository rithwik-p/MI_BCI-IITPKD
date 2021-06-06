function [samplesClass1 samplesClass2] = getClassSamples(eegDataSet)
%this function divide the EEG samples according to their class (it is
%assumed that the data set contains only 2 classes), and, for each class, 
%concatenate the EEG samples of each trial all together
%
%Input:
%eegDataSet: a data set of EEG trials (structure)
%
%Output:
%samplesClass1: a matrix with the concatenation of EEG samples
%   from the 1st class. This matrix has as many rows as samples from class 1, 
%   and as many columns as EEG channels.
%samplesClass2: a matrix with the concatenation of EEG samples
%   from the 2nd class. This matrix has as many rows as samples from class 2, 
%   and as many columns as EEG channels.


%getting the data from each class
classLabels = unique(eegDataSet.y);
Class1EEGTmp = eegDataSet.x(:,:,eegDataSet.y == classLabels(1));
Class2EEGTmp = eegDataSet.x(:,:,eegDataSet.y == classLabels(2));

%getting some descriptive values
nbChannels = size(Class1EEGTmp,2);
nbSamplesPerTrial = size(Class1EEGTmp,1);
nbTrials1 = size(Class1EEGTmp,3);
nbTrials2 = size(Class2EEGTmp,3);
nbSamples1 = nbTrials1*nbSamplesPerTrial;
nbSamples2 = nbTrials2*nbSamplesPerTrial;

%concatenating the EEG samples from all trials for each class separately
samplesClass1 = zeros(nbSamples1,nbChannels);
samplesClass2 = zeros(nbSamples2,nbChannels);
for t=1:nbTrials1
    samplesClass1(((t-1)*nbSamplesPerTrial+1):(t*nbSamplesPerTrial),:) = Class1EEGTmp(:,:,t);
end
for t=2:nbTrials2
    samplesClass2(((t-1)*nbSamplesPerTrial+1):(t*nbSamplesPerTrial),:) = Class2EEGTmp(:,:,t);
end
clear Class1EEGTmp;
clear Class2EEGTmp;