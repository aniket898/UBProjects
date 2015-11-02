fid = fopen('Querylevelnorm.txt','rt');
tmp = textscan(fid,'%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s',69623);
y = tmp{1,1};    
parameters = tmp(:,3:48);
X = [parameters{:}];
X_new = zeros(69623,46);
[rowSize,columnSize] = size(X);
for k=1:rowSize
    for j=1:columnSize
        strings = strsplit(X{k,j},':');
        X_new(k,j) = str2double(strings(2));
    end    
end
Y_new = str2double(Y);

noTrainDocs = floor(0.8 * length(X_new));
noValidationDocs = floor(0.9 * length(X_new));

X_rand = randperm(length(X_new));
X_rand = (X_rand).';

trainingIndexes = X_rand(1:noTrainDocs);
X_training = X_new(trainingIndexes,:);
Y_training = Y_new(trainingIndexes,:);

validationIndexes = X_rand(noTrainDocs+1:noValidationDocs);
X_validation = X_new(validationIndexes,:);
Y_validation = Y_new(validationIndexes,:);

testIndexes = X_rand(noValidationDocs+1:end);
X_test = X_new(testIndexes,:);
Y_test = Y_new(testIndexes,:);
noValidationDocs = noValidationDocs - noTrainDocs;
trainInd1 = trainingIndexes;
validInd1 = validationIndexes;
fclose(fid);