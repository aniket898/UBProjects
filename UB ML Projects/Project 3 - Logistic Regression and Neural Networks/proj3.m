%**********************************Loading the Data******************************%
%% Sigmoid Function
sigmoid = @(P) 1.0./(1.0 + exp(-P));
%loadMNISTImages returns a 28x28x[number of MNIST images] matrix containing
%the raw MNIST images
filename = 'train-images.idx3-ubyte';
fp = fopen('train-images.idx3-ubyte', 'rb');
assert(fp ~= -1, ['Could not open ', filename, '']);
magic = fread(fp, 1, 'int32', 0, 'ieee-be');
assert(magic == 2051, ['Bad magic number in ', filename, '']);
numImages = fread(fp, 1, 'int32', 0, 'ieee-be');
numRows = fread(fp, 1, 'int32', 0, 'ieee-be');
numCols = fread(fp, 1, 'int32', 0, 'ieee-be');
trainImages = fread(fp, inf, 'unsigned char');
trainImages = reshape(trainImages, numCols, numRows, numImages);
% images = permute(images,[2 1 3]);
fclose(fp);
% Reshape to #pixels x #examples
trainImages = reshape(trainImages, size(trainImages, 1) * size(trainImages, 2), size(trainImages, 3));
% Convert to double and rescale to [0,1]
trainImages = double(trainImages) / 255;

%loadMNISTLabels returns a [number of MNIST images]x1 matrix containing
%the labels for the MNIST images
filename = 't10k-labels.idx1-ubyte';
fp = fopen('t10k-labels.idx1-ubyte', 'rb');
assert(fp ~= -1, ['Could not open ', filename, '']);
magic = fread(fp, 1, 'int32', 0, 'ieee-be');
assert(magic == 2049, ['Bad magic number in ', filename, '']);
numLabels = fread(fp, 1, 'int32', 0, 'ieee-be');
testLabels = fread(fp, inf, 'unsigned char');
assert(size(testLabels,1) == numLabels, 'Mismatch in label count');
fclose(fp);

%loadMNISTLabels returns a [number of MNIST images]x1 matrix containing
%the labels for the MNIST images
filename = 'train-labels.idx1-ubyte';
fp = fopen('train-labels.idx1-ubyte', 'rb');
assert(fp ~= -1, ['Could not open ', filename, '']);
magic = fread(fp, 1, 'int32', 0, 'ieee-be');
assert(magic == 2049, ['Bad magic number in ', filename, '']);
numLabels = fread(fp, 1, 'int32', 0, 'ieee-be');
trainLabels = fread(fp, inf, 'unsigned char');
assert(size(trainLabels,1) == numLabels, 'Mismatch in label count');
fclose(fp);

%loadMNISTtest_images returns a 28x28x[number of MNIST testImages] matrix containing
%the raw MNIST testImages
filename = 't10k-images.idx3-ubyte';
fp = fopen('t10k-images.idx3-ubyte', 'rb');
assert(fp ~= -1, ['Could not open ', filename, '']);
magic = fread(fp, 1, 'int32', 0, 'ieee-be');
assert(magic == 2051, ['Bad magic number in ', filename, '']);
numtest_images = fread(fp, 1, 'int32', 0, 'ieee-be');
numRows = fread(fp, 1, 'int32', 0, 'ieee-be');
numCols = fread(fp, 1, 'int32', 0, 'ieee-be');
testImages = fread(fp, inf, 'unsigned char');
testImages = reshape(testImages, numCols, numRows, numtest_images);
% testImages = permute(testImages,[2 1 3]);
fclose(fp);
% Reshape to #pixels x #examples
testImages = reshape(testImages, size(testImages, 1) * size(testImages, 2), size(testImages, 3));
% Convert to double and rescale to [0,1]
testImages = double(testImages) / 255;

%trainImages = loadMNISTImages('train-images.idx3-ubyte');
%trainLabels = loadMNISTLabels('train-labels.idx1-ubyte');
%testImages = loadMNISTImages('t10k-images.idx3-ubyte');
%testLabels = loadMNISTLabels('t10k-labels.idx1-ubyte');

%trainImages = trainImages;
%trainLabels = trainLabels;
%testImages = testImages;
%testLabels = testLabels;
trainNumImages = 60000;
validNumImages = 10000;

maintrainLabels = zeros(trainNumImages,10);
cntr = 1;
while cntr <= trainNumImages
    i = trainLabels(cntr,1);
    maintrainLabels(cntr,(i+1)) = 1;
    cntr = cntr + 1;
end  

mainvalidLabels = zeros(validNumImages,10);
cntr = 1;
while cntr <= validNumImages
    i = testLabels(cntr,1);
    mainvalidLabels(cntr,(i+1)) = 1;
    cntr = cntr + 1;
end

optWlr = zeros(784,10);
opterror = 9999999;
%% LOGISTIC REGRESSION
Wlr = ones(784,10);
ak = zeros(1,10);
yk = zeros(60000,10);
eta = 0.01;
for epochs=1:75
    for i=1:60000
        ak = (Wlr.' * trainImages(:,i)).' + ones(1,10); % ones for bias factor
        maxelement = max(ak);
        yk(i,:) = exp(ak/maxelement)/sum(exp(ak/maxelement));
        indexMax = find(yk(i,:)==max(yk(i,:)));
        for l = 1:10
            if(l==indexMax)
                yk(i,l) = 0.9999;
            else
                yk(i,l) = 0.0001;
            end
        end
        % Find error
        error = -sum(maintrainLabels(i,:) .* log(yk(i,:)));
        % Update Weights
        Wlr = Wlr - (eta * trainImages(:,i) * (yk(i,:) - maintrainLabels(i,:)) );
        %%Adaptive Learning Method
%         if error < opterror
%             opterror = error;
%             optWlr = Wlr;
%             preveta = eta;
%             eta = eta + eta * 0.05;
%             prevWlr = Wlr;       
%         else 
%             eta = eta * 0.05;
%             Wlr = prevWlr;
%         end 
%         if eta<0.000001
%                 eta = 0.0001;
%         end        
%         %0.01 minimum error
    end
    %disp epochs
end
correct = 0;
yk2 = zeros(10000,10);
%finalyk = zeros(10000,1);
blr = ones(1,10);
for i=1:10000
    ak = (Wlr.' * testImages(:,i)).' + ones(1,10); % ones for bias factor
    maxelement = max(ak);
    yk2(i,:) = exp(ak/maxelement)/sum(exp(ak/maxelement));
    indexMax = find(yk2(i,:)==max(yk2(i,:)));
    for l = 1:10
        if(l==indexMax)
            yk2(i,l) = 1;
        else
            yk2(i,l) = 0;
        end
    end
    
    if(yk2(i,:)==mainvalidLabels(i,:))
        correct = correct + 1;
    end    
    %w1 = w1 - (0.5 * trainImages(:,i) * (yk(i,:) - maintrainLabels(i,:)) );
end    

%%NEURAL NETWORK

%% Defining Parameters
D = 784;
K = 10;
trainImagesNum = 60000;
h = 'sigmoid';
J_arr = [300];
%J_arr = [5 10 15 17 20 50 100 200 300 400 500 784];
for q = 1: size(J_arr , 2)
    J = J_arr(q);
%eta_arr = [10 1 0.1 0.01 0.001 0.0001 0.00001 0.000001 ];
eta_arr = [0.01];
for qr = 1: size(eta_arr , 2)
    eta = eta_arr(qr);
    Wnn1 = randn(D,J);
    Wnn2 = randn(J,K);
    bnn1 =  zeros(1,J);
    bnn2 =  zeros(1,K);
    % 1-of-K encoding scheme
    train1toK = zeros(trainImagesNum,K);         
    for trainImagesNum = 1:trainImagesNum
        train1toK(trainImagesNum,trainLabels(trainImagesNum)+1)=1;         
    end

%for epochs = 1:30
for i = 1: trainImagesNum
    z = zeros(1,J);
    y = zeros(1,K);
    aj = zeros(1,J);
    ak = zeros(1,K);
    for j= 1:J
        aj(j) = (Wnn1(:,j)'* trainImages(:,i)) + bnn1(j); 
    end
    z = sigmoid(aj);
    for k = 1:K 
        ak(k) = (Wnn2(:,k)'* z') + bnn2(k);
    end
    for k = 1:K 
        y(k) = exp(ak(k))./ sum(exp(ak));
    end
    dk = y - train1toK(i,:);
    for j=1:J
        for k=1:10
            err1(k) = Wnn2(j,k).*dk(k);
        end
        dj(j) = (sigmoid(z(j)).*(1 - sigmoid(z(j)))).*(sum(err1)) ;
    end
    % Weight Update
    for j=1:J
        Wnn1(:,j) = Wnn1(:,j) - eta.*(dj(j).*trainImages(:,i));
    end
    for k=1:K
        Wnn2(:,k) = Wnn2(:,k) - (eta.*(dk(k).*z))';
    end
end
%end
%% Testing 
testImagesNum = 10000;
correct=0;
wrong=0;
for i = 1:testImagesNum
    z = zeros(1,J);
    y = zeros(1,K);
    aj = zeros(1,J);
    ak = zeros(1,K);
    for j= 1:J
        aj(j) = (Wnn1(:,j)'* testImages(:,i)) + bnn1(j);                  
    end
    z = sigmoid(aj);
    for k = 1:K 
        ak(k) = (Wnn2(:,k)'* z') + bnn2(k);
    end
    for k = 1:K 
        y(k) = exp(ak(k))./sum(exp(ak));
    end
    [value index]=max(y);
	if(index==testLabels(i,1)+1)
		correct=correct+1;
	else
		wrong=wrong+1;
    end
end
fprintf('eta: %d ',eta);
fprintf('\tJ: %d ',J);
fprintf('\tCorrectly Classified : %d ',correct);
fprintf('\tWrongly Classified : %d \trainImagesNum',wrong);
end
end
    
