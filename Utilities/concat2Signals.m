function concatenatedSignals = concat2Signals(eegDataSet_A, eegDataSet_B)

%concatenate the 2 input EEG data sets into a single, bigger data set
%
%input:
%eegDataSet_A: the first EEG data set
%eegDataSet_N: the second EEG data set
%
%output:
%concatenatedSignals: the resulting eeg data set, being formed by the
%   concatenation of the 2 input EEG data sets
%

concatenatedSignals.c = eegDataSet_A.c;
concatenatedSignals.s = eegDataSet_A.s;
concatenatedSignals.x = cat(3,eegDataSet_A.x, eegDataSet_B.x);
concatenatedSignals.y = [eegDataSet_A.y eegDataSet_B.y];