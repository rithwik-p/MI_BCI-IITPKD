function accuracy  = evaluateAlgorithm(algo,dataSet,low,high,nbFilterPairs)

addpath 'Utilities';

%loading EEG data from files
display('reading EEG data...');

if strcmp(dataSet,'BCI_III_DSIVa')
    if exist('Data\BCI_III_DSIVa\trainingEEGSignals.mat','file')==0
        read_BCI_III_DSIVa;
    end
    disp('reading BCI competition III, data set IVa');
    load 'Data\BCI_III_DSIVa\trainingEEGSignals.mat'
    load 'Data\BCI_III_DSIVa\testingEEGSignals.mat'
    load 'Data\Emap\elecCoord118.mat' %the electrodes 3D coordinates
    emap = load('Data\Emap\EMapAll.mat');
        
elseif strcmp(dataSet, 'BCI_IV_DSIIa')
    disp('reading BCI competition IV, data set IIa');
    if exist('Data\BCI_IV_DSIIa\trainingEEGSignals.mat','file')==0
        read_BCI_IV_DSIIa([1 2])
    end
    load 'Data\BCI_IV_DSIIa\trainingEEGSignals.mat'
    load 'Data\BCI_IV_DSIIa\testingEEGSignals.mat'  
    load 'Data\Emap\elecCoord22.mat' %the electrodes 3D coordinates
    emap = load('Data\Emap\EMapAll.mat');    

elseif strcmp(dataSet, 'BCI_IV_DSIIb')
    disp('reading BCI competition IV, data set IIb');
    if exist('Data\BCI_IV_DSIIb\trainingEEGSignals.mat','file')==0
        read_BCI_IV_DSIIb([1 2])
    end
    load 'Data\BCI_IV_DSIIb\trainingEEGSignals.mat'
    load 'Data\BCI_IV_DSIIb\testingEEGSignals.mat'  
    load 'Data\Emap\elecCoord22.mat' %the electrodes 3D coordinates
    emap = load('Data\EMap\EMapAll.mat');
    
elseif strcmp(dataSet, 'BCI_IV_DSIIb4')
    disp('reading BCI competition IV, data set IIb');
    if exist('Data\BCI_IV_DSIIb4\trainingEEGSignals.mat','file')==0
        read_BCI_IV_DSIIb4([1 2 3 4])
    end
    load 'Data\BCI_IV_DSIIb4\trainingEEGSignals.mat'
    load 'Data\BCI_IV_DSIIb4\testingEEGSignals.mat'  
    load 'Data\Emap\elecCoord22.mat' %the electrodes 3D coordinates
    emap = load('Data\EMap\EMapAll.mat');
    
elseif strcmp(dataSet,'iitpkd')
    disp('reading IIT Palakkad data set');
    if exist('Data\iitpkd\trainingEEGSignals.mat','file')==0
        read_iitpkd;
    end
    load 'Data\iitpkd\trainingEEGSignals.mat'
    load 'Data\iitpkd\testingEEGSignals.mat'
    load 'Data\Emap\elecCoord60.mat' %the electrodes 3D coordinates
    emap = load('Data\EMap\EMapAll.mat');

else
    disp('!! ERROR !! Incorrect data set!');    
    return
end

emap = emap.EMapAll;

display('done reading dataset!');

root = ['OutputData\Pictures\' algo '\' dataSet '\nf' num2str(nbFilterPairs) '\']; %to save the filter topography pictures

nbSubjects = length(trainingEEGSignals);
accuracy = zeros(1,nbSubjects);
% nbFilterPairs = 3; %we use 3 pairs of filters

%parameters for band pass filtering the signals in the mu+beta band (8-30 Hz)
order = 5; %we use a 5th-order butterworth filter

gammaList = 0:0.1:0.9; %first regularization parameter for covariance matrix regularization
betaList = 0:0.1:0.9; %second regularization parameter for covariance matrix regularization

k = 5; %for hyperparameter selecting using k-fold cross validation

root = ['OutputData\Pictures\' algo '\' dataSet '\nf' num2str(nbFilterPairs) '\']; %to save the filter topography pictures

for s=1:nbSubjects
    trainingEEGSignals{s} = eegButterFilter(trainingEEGSignals{s}, low, high, order);
    testingEEGSignals{s} = eegButterFilter(testingEEGSignals{s}, low, high, order);
end

      
for s=1:nbSubjects

    if strcmp(algo,'CSP')
        disp('Learning CSP filters assuming invertible covariance matrices');
        CSPMatrix = learn_CSP(trainingEEGSignals{s});

        elseif strcmp(algo,'CSP_CV')
         disp('Learning CSP filters assuming invertible covariance matrices');

        %identifying the k subtraining set and validation set
        disp('generating the subtraining and validation sets for each fold...');
        subTrainingSets = cell(k,1);
        validationSets = cell(k,1);
        classLabels = unique(trainingEEGSignals{s}.y);
        
        nbTrials = length(trainingEEGSignals{s}.y);
        sizeChunk = floor(nbTrials/k);

        %generating the different training/testing sets of the cross validation
        for iter=1:k            
            subTrainingSets{iter} = getSubDataSet(trainingEEGSignals{s}, [1:(iter-1)*sizeChunk (iter*sizeChunk+1):nbTrials]);
            validationSets{iter} = getSubDataSet(trainingEEGSignals{s}, ((iter-1)*sizeChunk+1):(iter*sizeChunk));
        end
        
        %evaluating the performances of the difference potential hyperparameters
        bestScore = 0;

        %computing the k-fold cross validation accuracy for each hyperparameter
        %values using a LDA as classifier
       
        score = 0;
        for iter=1:k
            %learning CSP spatial filters
            CSPMatrix = learn_CSP(subTrainingSets{iter});
            featureTrain = extractCSPFeatures(subTrainingSets{iter}, CSPMatrix, nbFilterPairs);
            LDAModel = LDA_Train(featureTrain);            
            featureTest = extractCSPFeatures(validationSets{iter}, CSPMatrix, nbFilterPairs);
            results = LDA_Test(featureTest, LDAModel);
            localScore = results.accuracy;
            score = score + localScore;
        end
        acc(s) = score / k;             
        disp(['CV accuracy for subject' num2str(s) ' = ' num2str(acc(s)) ' %']);  

    elseif strcmp(algo,'R_CSP')
        disp('Learning Regularized CSP filters');  
        [bestGamma bestBeta] = R_CSPWithBestParams(trainingEEGSignals{s}, gammaList, betaList, k, nbFilterPairs);
        CSPMatrix = learn_R_CSP(trainingEEGSignals{s}, bestGamma, bestBeta);        

    elseif strcmp(algo,'SR_CSP')        
        disp('Learning Spatially Regularized CSP filters');    
            [bestAlpha bestR] = SR_CSPWithBestParams(trainingEEGSignals{s}, elecCoord, alphaList, rList, k, nbFilterPairs);
            CSPMatrix = learn_SR_CSP(trainingEEGSignals{s}, elecCoord, bestAlpha, bestR);
        else
            disp('!! ERROR !! Incorrect CSP algorithm !');
             return;
    end
    
    trainFeatures = extractCSPFeatures(trainingEEGSignals{s}, CSPMatrix, nbFilterPairs);
    ldaParams = LDA_Train(trainFeatures);
    testFeatures = extractCSPFeatures(testingEEGSignals{s}, CSPMatrix, nbFilterPairs);
    result = LDA_Test(testFeatures, ldaParams);    
    accuracy(s) = result.accuracy;
    disp(['test set accuracy for subject' num2str(s) ' = ' num2str(accuracy(s)) ' %']);  
end
%accuracyFilename = ['..\GeneratedData\accuracy_' algo '-' dataSet '.mat'];
% save(['OutputData\accuracy\' algo '\' dataSet '\nf' num2str(nbFilterPairs) '\accuracy_' sprintf('%i-%iHz_subject_%i.png',low,high,s) '.mat'],'accuracy');
% save(['OutputData\accuracy_' algo '-' dataSet '-nf-' num2str(nbFilterPairs) '.mat'],'accuracy');