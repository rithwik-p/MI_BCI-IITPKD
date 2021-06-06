function concatenatedSignals = concatSignals(eegDataSet)

%concatenate the input EEG data sets into a single, bigger data set
%
%input:
%eegDataSet: a cell array, with each cell containing an eegDataSet
%
%output:
%concatenatedSignals: the resulting eeg data set, being formed by the
%   concatenation of all input EEG data sets
%


concatenatedSignals = eegDataSet{1};

for d=2:length(eegDataSet)
    concatenatedSignals.x = cat(3,concatenatedSignals.x, eegDataSet{d}.x);
    concatenatedSignals.y = [concatenatedSignals.y eegDataSet{d}.y];
end
