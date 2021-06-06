function read_BCI_IV_DSIIb(classLabel2Keep, passBand)

% addpath 't200_FileAccess';
%
nbSubjects = 9; %number of subjects
fs = 250;
nbChannels = 3;
% nbChannels = 6;

segmentLength = 3; %we use a two seconds time window
segmentOffset = 0.5; %our time window starts 0.5s after the cue
stimCodes = [769 770 771 772];
%keeping only the trials from the required classes, if needed
if ~exist('classLabel2Keep','var')
    classLabel2Keep = [1 2 ];%3 4];
end
stimCodes = stimCodes(classLabel2Keep);
% channelList = {'Fz';...
%             'FC3';'FC1';'FCz';'FC2';'FC4';...
%             'C5';'C3';'C1';'Cz';'C2';'C4';'C6';...
%             'CP3';'CP1';'CPz';'CP2';'CP4';...
%             'P1';'Pz';'P2';...
%             'POz'};

%defining the parameter of a butterworth filter if needed
if exist('passBand','var')
    disp(['will band-pass filter all signals in ' num2str(passBand.low) '-' num2str(passBand.high) 'Hz']); 
    order = 5; 
    lowFreq = passBand.low * (2/fs);
    highFreq = passBand.high * (2/fs);
    [B A] = butter(order, [lowFreq highFreq]);
end

%defining the cell array that will contain the (raw) training and testing EEG data
trainingEEGSignals = cell(nbSubjects,1);
testingEEGSignals = cell(nbSubjects,1);

%define the finenames
dataPrefix= 'Data\BCI_IV_DSIIb\';

%reading the data for each subject
for subjectNo = 1:nbSubjects   
        
    for t=1:5        
        if t<4 %we read the train set
            disp('reading train set');
            EEGDataFilename = [dataPrefix 'B0' int2str(subjectNo) '0' int2str(t) 'T.gdf'];
            testLabels = load([dataPrefix 'B0' int2str(subjectNo) '0' int2str(t) 'T.mat']);
            EEGdata.y = testLabels.classlabel';
            EEGdata.y = EEGdata.y(ismember(EEGdata.y, classLabel2Keep));%keeping only the selected classes
        
        else %we read the test set
            disp('reading test set');
            EEGDataFilename = [dataPrefix 'B0' int2str(subjectNo) '0' int2str(t) 'E.gdf'];
            %reading the true labels (not present in the gdf files)
            testLabels = load([dataPrefix 'B0' int2str(subjectNo) '0' int2str(t) 'E.mat']);
            EEGdata.y = testLabels.classlabel';
            EEGdata.y = EEGdata.y(ismember(EEGdata.y, classLabel2Keep));%keeping only the selected classes
        end
        
        %reading the gdf file
        [s,h] = sload(EEGDataFilename,0,'OVERFLOWDETECTION:OFF');
        EEGdata.s = h.SampleRate;
%         s = s(:,1:nbChannels); %we remove the EOG channels

        %if required, band-pass filter the signal in a given frequency band
        %using a butterworth filter of order 5
        if exist('passBand','var')
            disp('band-pass filtering');
            s = filter(B,A,s);
        end

        %counting the total number of trials for the kept classes
        if t==1
            nbTrials = sum(ismember(h.EVENT.TYP,stimCodes));
            EEGdata.y = zeros(1,nbTrials);
        else
            nbTrials = length(EEGdata.y);
        end
        disp(['nbTrials: ' num2str(nbTrials)]);        
        EEGdata.x = zeros((segmentLength * fs)+1, nbChannels, nbTrials);

        %extracting the two second long segments for each trial
        currentTrial = 1;
        allTrialCount=1;
        for e=1:length(h.EVENT.TYP)
            code = h.EVENT.TYP(e);
            if t == 1 %for the training set we know the labels
                if ismember(code,stimCodes)                    
                    EEGdata.y(currentTrial) = code - 768;
                    pos = h.EVENT.POS(e);                    
                    range = pos+((fs*segmentOffset):(fs*(segmentOffset+segmentLength)));                    
%                     EEGdata.x(:,:,currentTrial) = s(range,:);
                    EEGdata.x(:,:,currentTrial) = s(range,1:nbChannels);                    
                    currentTrial = currentTrial + 1;
                end
            else %for the testing set, only the start of the trial is indicated in the gdf file
                if code == 768
                    if ismember(testLabels.classlabel(allTrialCount),classLabel2Keep) %is this trial belonging to a kept class?                        
                        pos = h.EVENT.POS(e);
                        %the cue appears 2s after the start of the trials (code 768)
%                         EEGdata.x(:,:,currentTrial) = s((pos+(2*fs)+(segmentOffset*fs)):(pos+(2*fs)+(segmentOffset*fs)+(segmentLength*fs)),:);
                        EEGdata.x(:,:,currentTrial) = s((pos+(2*fs)+(segmentOffset*fs)):(pos+(2*fs)+(segmentOffset*fs)+(segmentLength*fs)),1:nbChannels);                        
                        currentTrial = currentTrial + 1;
                    end
                    allTrialCount = allTrialCount+1;
                end
                
            end
        end
        channelList=h.Label;
        EEGdata.c = channelList;
        
        if t==1
            trainingEEGSignals{subjectNo} = EEGdata;
        else
            testingEEGSignals{subjectNo} = EEGdata;
        end
    end    
end

%saving the results to the appropriate matlab files
save('Data\BCI_IV_DSIIb\trainingEEGSignals.mat','trainingEEGSignals');
save('Data\BCI_IV_DSIIb\testingEEGSignals.mat','testingEEGSignals');
