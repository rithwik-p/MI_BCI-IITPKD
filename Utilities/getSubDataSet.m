function subDataSet = getSubDataSet(dataSet, trialIndexes)

%This function returns a subset of a given EEG, as specified by a list of
%trial indexes
%
%Input:
%dataSet: an EEG data set
%trialIndexes: an array with the indexes of the trials to be kept in the
%   sub data set
%
%Output
%subDataSet: an EEG data set containing only the selected trials 


subDataSet.x = dataSet.x(:,:,trialIndexes);
subDataSet.y = dataSet.y(trialIndexes);
subDataSet.c = dataSet.c;
subDataSet.s = dataSet.s;