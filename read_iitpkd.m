function read_iitpkd(passBand)
%
%Input:
%passBand: an optional structure defining a frequency band in which
%   filtering all the EEG signals this structure is such that:
%       passBand.low= low cut-off frequency (in Hz)
%       passBand.high= high cut-off frequency (in Hz)
%   by default no filtering is done

%names of the files with the original data
filenames = 'Data\iitpkd\data_iitpkd.mat';
         
trueLabelsFiles = 'Data\iitpkd\labels.mat';
         
nbSubjects = 15;
trainingEEGSignals = cell(nbSubjects,1);
testingEEGSignals = cell(nbSubjects,1);

%some constants
fs = 500; %sampling rate
% startEpoch = 0.5; %an epoch starts 0.5s after the cue
% endEpoch = 2.5;%an epoch ends 2.5s after the cue
startEpoch = 4; %an epoch starts 0.5s after the cue
endEpoch = 7;%an epoch ends 2.5s after the cue
nbSamplesPerTrial = ceil((endEpoch - startEpoch) * fs);% + 1;

 
    
disp('Reading data');

%reading the data from this subject
disp('reading files...');
load(filenames);
load(trueLabelsFiles);
disp('...done!');

nbChannels = size(data,2);

nbTrainTrials = size(data,3)-5;%length(trainingIndexes);
disp(['nbTrainTrials = ' num2str(nbTrainTrials)]);
nbTestTrials = 5;%length(testingIndexes);
disp(['nbTestTrials =  ' num2str(nbTestTrials)]);

for s=1:nbSubjects          
    %initializing structures
    disp('initializing structures...');
    trainingEEGSignals{s}.x = zeros(nbSamplesPerTrial, nbChannels, nbTrainTrials);
    trainingEEGSignals{s}.y = labels(1,1:15);%labels(trainingIndexes)-1;
    trainingEEGSignals{s}.s = fs;
    trainingEEGSignals{s}.c = 0;%nfo.clab;
    testingEEGSignals{s}.x = zeros(nbSamplesPerTrial, nbChannels, nbTestTrials);
    testingEEGSignals{s}.y = labels(1,15:20);%trueLabels(testingIndexes)-1;
    testingEEGSignals{s}.s = fs;
    testingEEGSignals{s}.c = 0;%nfo.clab;
    disp('...done!');
    
    %assigning data to the corresponding structure
    disp('assigning data to the corresponding structure...');
    
    %training set    
    for trial=1:nbTrainTrials    
        trainingEEGSignals{s}.x(:,:,trial) = data(round(startEpoch*fs):round(endEpoch*fs)-1,:,trial,s);%epoch;
    end
    
    %testing set
    for trial=1:nbTestTrials    
        testingEEGSignals{s}.x(:,:,trial) = data(round(startEpoch*fs):round(endEpoch*fs)-1,:,15+trial,s);
    end
    
    disp('...done!');
end

%saving the results to the appropriate matlab files
save('Data\iitpkd\trainingEEGSignals.mat','trainingEEGSignals');
save('Data\iitpkd\testingEEGSignals.mat','testingEEGSignals');
    
    
    
    
    
    