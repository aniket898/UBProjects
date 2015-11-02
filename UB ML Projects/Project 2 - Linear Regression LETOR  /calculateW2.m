%% SYNTHETIC DATA - PART 1 %%
load('/home/aniket/Downloads/synthetic.mat')

%% Creating Data %%
noTrainDocsSyn = floor(0.9 * length(x));
noValidationDocsSyn = size(x,2) - noTrainDocsSyn;
x = x.';
D = 10;
%t=t.';
X_rand2 = randperm(length(x));
X_rand2 = (X_rand2).';

trainingIndexesSyn = X_rand2(1:noTrainDocsSyn);
X_trainingSyn = x(trainingIndexesSyn,:);
Y_trainingSyn = t(trainingIndexesSyn,:);

validationIndexesSyn = X_rand2(noTrainDocsSyn+1:size(x,1));
X_validationSyn = x(validationIndexesSyn,:);
Y_validationSyn = t(validationIndexesSyn,:);

trainInd2 = trainingIndexesSyn;
validInd2 = validationIndexesSyn;

minlambda2 = 0;
minValidPer2 = 9999;
minw2 = zeros(4,1);
minM2 = 99;

%% Calculating Mu2 and Sigma2
%M2 = 4;
for M2=4:9
XforMrand2 = randperm(noTrainDocsSyn,M2);
XforMrand2 = (XforMrand2).';

mu2 = zeros(D,M2);
for i = 1:M2
    mu2(:,i) = X_trainingSyn(XforMrand2(i),:);
end    

sigma2 = zeros(D,D);
sigma2 = 0.1 * var(X_trainingSyn);
%sigma = var(X_training);

for i=1:D
    if sigma2(1,i)<0.0001
        sigma2(1,i)=0.01;
    end    
end    
%sigma(~sigma) = 0.1;
sigma2 = diag(sigma2);
Sigma2 = zeros(D,D,M2);
for i=1:M2
   Sigma2(:,:,i) = sigma2;
end

%% Calculating phi for Synthetic X Training and Y Training %%
phi3 = zeros(noTrainDocsSyn,M2);
phi3(:,1) = 1;

for j = 2:M2
    Sigma1inv2 = inv(Sigma2(:,:,j));
    for i = 1:noTrainDocsSyn
        r1 = (X_trainingSyn(i,:).'-mu2(:,j)).';
        r2 = r1 * Sigma1inv2;
        r3 = X_trainingSyn(i,:).'-mu2(:,j);
        r4 = -0.5 * r2 * r3;
        phi3(i,j) = exp(r4);
        %phi(i,j) = exp (-0.5 * (X_training(i,:).'-mu1(:,j)).' * Sigma1inv * (X_training(i,:).'-mu1(:,j)) );
    end
end 

%% Calculating phi for Synthetic X Validation and Y Validation %%
%oldvalid = noValidationDocs;
%noValidationDocs = noValidationDocs - noTrainDocs;
phi4 = zeros(noValidationDocsSyn,M2);
phi4(:,1) = 1;

for j = 2:M2
    Sigma1inv2 = inv(Sigma2(:,:,j));
    for i = 1:noValidationDocsSyn
        r1 = (X_validationSyn(i,:).'-mu2(:,j)).';
        r2 = r1 * Sigma1inv2;
        r3 = X_validationSyn(i,:).'-mu2(:,j);
        r4 = -0.5 * r2 * r3;
        phi4(i,j) = exp(r4);
        %phi(i,j) = exp (-0.5 * (X_training(i,:).'-mu1(:,j)).' * Sigma1inv * (X_training(i,:).'-mu1(:,j)) );
    end
end 

%% Hypertuning lambda2 %%
lambda2 = 0.1;
for k =1 : 5

    lambda2 = lambda2 + 0.1;
    w2 =  inv((lambda2 * eye(M2,M2))+(phi3.'*phi3)) * (phi3.' * Y_trainingSyn); 
    %lambda1 = 0.5;
    %wvalidation =  inv((lambda1 * eye(M1,M1))+(phi2.'*phi2)) * (phi2.' * Y_validation); 

    validationErrorSyn = 0.5 * (Y_validationSyn - (phi4 * w2)).' * (Y_validationSyn - (phi4 * w2));  
    validPer2 = sqrt(((2 * validationErrorSyn) / noValidationDocsSyn));
    if minValidPer2>validPer2
        minlambda2 = lambda2;
        minValidPer2 = validPer2;
        minw2 = w2;
        minM2 = M2;
        minphi3=phi3;
        minmu2 = mu2;
        minSigma2 = Sigma2;
    end
end
end

phi3=minphi3;
M2=minM2;
w2 = minw2;
validPer2 = minValidPer2;
lambda2 = minlambda2;
mu2=minmu2;
Sigma2=minSigma2;
%% Calculating training error %%
trainingErrorSyn = 0.5 * (Y_trainingSyn - (phi3 * w2)).' * (Y_trainingSyn - (phi3 * w2));  
trainPer2 = sqrt(((2 * trainingErrorSyn) / noTrainDocsSyn));
