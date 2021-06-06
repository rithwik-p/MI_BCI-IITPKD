
algo = 'CSP';
% algo ='R_CSP';

dataset = 'BCI_III_DSIVa';
% dataset = 'BCI_IV_DSIIa';
% dataset = 'BCI_IV_DSIIb';

nbFilterPairs = 1; %we use 1 pairs of filters

% low=[8,6,0.1,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40];
% high=[30,40,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44];

%% FBCSP
for i=1:10   
    accuracy{i}  = evaluateAlgorithm(algo, dataset,4*i,4*(i+1),nbFilterPairs);
%     accuracy{i}  = evaluateAlgorithm(algo, dataset,low(i),high(i),nbFilterPairs);
end

for i=1:10
    acc = accuracy{1,i};
end