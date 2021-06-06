function filteredEEGData = eegButterFilter(EEGData, low, high, order)

%band-pass filter a set of EEG signals using a butterworth filter
%
%input params:
%EEGData: extracted EEG signals
%low:low cutoff frequency
%high: high cutoff frequency
%order: filter order
%
%output
%filteredEEGData: the EEG data band-pass filtered in the specified
%   frequency band

%identifying various constants
nbSamples = size(EEGData.x,1);
nbChannels = size(EEGData.x,2);
nbTrials = size(EEGData.x,3);

%preparing the output data
filteredEEGData.x = zeros(nbSamples, nbChannels, nbTrials);
filteredEEGData.c = EEGData.c;
filteredEEGData.s = EEGData.s;
filteredEEGData.y = EEGData.y;

%designing the butterworth band-pass filter 
lowFreq = low * (2/EEGData.s);
highFreq = high * (2/EEGData.s);
[B A] = butter(order, [lowFreq highFreq]);

%filtering all channels in this frequency band, for the training data
for i=1:nbTrials %all trials
    for j=1:nbChannels %all channels
        filteredEEGData.x(:,j,i) = filter(B,A,EEGData.x(:,j,i));
    end
end
   