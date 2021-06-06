function pooledFeatureSet = concatFeatureSets(featureSets)

%Input:
%featureSets: a cell array with a feature vector set per cell
%
%Output:
%pooledFeatureSet: the concatenation of all feature vectors sets contained
%in the input parameter


nbDataSets = length(featureSets);

%computing the size of the concatenation
nbVectors = 0;
for d=1:nbDataSets
    nbVectors = nbVectors + size(featureSets{d},1);
end

pooledFeatureSet = zeros(nbVectors, size(featureSets{1},2));

currentIndex = 1;
for d=1:nbDataSets
    nbVectorLocal = size(featureSets{d},1);
    pooledFeatureSet(currentIndex:(currentIndex+nbVectorLocal-1),:) = featureSets{d};
    currentIndex = currentIndex+nbVectorLocal;
end

