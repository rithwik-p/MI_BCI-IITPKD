function read_BCI_III_DSIVa(passBand)
%
%Input:
%passBand: an optional structure defining a frequency band in which
%   filtering all the EEG signals this structure is such that:
%       passBand.low= low cut-off frequency (in Hz)
%       passBand.high= high cut-off frequency (in Hz)
%   by default no filtering is done

%names of the files with the original data
filenames = ['Data\BCI_III_DSIVa\data_set_IVa_aa.mat';
             'Data\BCI_III_DSIVa\data_set_IVa_al.mat';
             'Data\BCI_III_DSIVa\data_set_IVa_av.mat';
             'Data\BCI_III_DSIVa\data_set_IVa_aw.mat';
             'Data\BCI_III_DSIVa\data_set_IVa_ay.mat'];
         
trueLabelsFiles = ['Data\BCI_III_DSIVa\true_labels_aa.mat';
                  'Data\BCI_III_DSIVa\true_labels_al.mat';
                  'Data\BCI_III_DSIVa\true_labels_av.mat';
                  'Data\BCI_III_DSIVa\true_labels_aw.mat';
                  'Data\BCI_III_DSIVa\true_labels_ay.mat'];
         
nbSubjects = 5;
trainingEEGSignals = cell(nbSubjects,1);
testingEEGSignals = cell(nbSubjects,1);

%some constants
fs = 100; %sampling rate
% startEpoch = 0.5; %an epoch starts 0.5s after the cue
% endEpoch = 2.5;%an epoch ends 2.5s after the cue
startEpoch = 0; %an epoch starts 0.5s after the cue
endEpoch = 3;%an epoch ends 2.5s after the cue
nbSamplesPerTrial = ceil((endEpoch - startEpoch) * fs) + 1;

for s=1:nbSubjects    
    
    disp(['Reading data from subject ' num2str(s)]);
    
    %reading the data from this subject
    disp('reading files...');
    load(filenames(s,:));
    load(trueLabelsFiles(s,:));
    disp('...done!');
    
    %conversion to uV values
    cnt= 0.1*double(cnt);
    
    %perform band-pass filtering with a butterworth filter if needed
    if exist('passBand','var')
        disp(['will band-pass filter all signals in ' num2str(passBand.low) '-' num2str(passBand.high) 'Hz']); 
        order = 5; 
        lowFreq = passBand.low * (2/fs);
        highFreq = passBand.high * (2/fs);
        [B A] = butter(order, [lowFreq highFreq]);
        cnt = filter(B,A,cnt);
    end
    
    nbChannels = size(cnt,2);
    
    %identifying the training and testing trials
    labels = mrk.y;
    cues = mrk.pos;
    trueLabels = true_y;
    trainingIndexes = find(~isnan(labels));
    testingIndexes = find(isnan(labels));
    
    nbTrainTrials = length(trainingIndexes);
    disp(['nbTrainTrials = ' num2str(nbTrainTrials)]);
    nbTestTrials = length(testingIndexes);
    disp(['nbTestTrials =  ' num2str(nbTestTrials)]);
    
    %initializing structures
    disp('initializing structures...');
    trainingEEGSignals{s}.x = zeros(nbSamplesPerTrial, nbChannels, nbTrainTrials);
    trainingEEGSignals{s}.y = labels(trainingIndexes)-1;
    trainingEEGSignals{s}.s = fs;
    trainingEEGSignals{s}.c = nfo.clab;
    testingEEGSignals{s}.x = zeros(nbSamplesPerTrial, nbChannels, nbTestTrials);
    testingEEGSignals{s}.y = trueLabels(testingIndexes)-1;
    testingEEGSignals{s}.s = fs;
    testingEEGSignals{s}.c = nfo.clab;
    disp('...done!');
    
    %assigning data to the corresponding structure
    disp('assigning data to the corresponding structure...');
    
    %training set    
    for trial=1:nbTrainTrials    
        %getting the cue
        cueIndex = cues(trainingIndexes(trial));
        %getting the data
        epoch = cnt((cueIndex + round(startEpoch*fs)):(cueIndex + round(endEpoch*fs)),:);
        %disp(size(epoch));
        %disp(size(trainingEEGSignals{s}.x(:,:,trial)));
        trainingEEGSignals{s}.x(:,:,trial) = epoch;
    end
    
    %testing set
    for trial=1:nbTestTrials    
        %getting the cue
        cueIndex = cues(testingIndexes(trial));
        %getting the data
        testingEEGSignals{s}.x(:,:,trial) = cnt((cueIndex + round(startEpoch*fs)):(cueIndex + round(endEpoch*fs)),:);
    end
    
    disp('...done!');
end

%saving the results to the appropriate matlab files
save('Data\BCI_III_DSIVa\trainingEEGSignals.mat','trainingEEGSignals');
save('Data\BCI_III_DSIVa\testingEEGSignals.mat','testingEEGSignals');
    
    
    
    
    
    