minlambda1 = 0;
minValidPer1 = 9999;
minw1 = zeros(4,1);

for M1=4:9
D=46;
XforMrand = randperm(noTrainDocs,M1);
XforMrand = (XforMrand).';
mu1 = zeros(46,M1);
for i = 1:M1
    mu1(:,i) = X_training(XforMrand(i),:);
end    

sigma = zeros(D,D);
sigma = 0.1 * var(X_training);
%sigma = var(X_training);

for i=1:D
    if sigma(1,i)<0.0001
        sigma(1,i)=0.01;
    end    
end    
sigma = diag(sigma);
Sigma1 = zeros(D,D,M1);
for i=1:M1
   Sigma1(:,:,i) = sigma;
end

%% Calculating phi for X Training and Y Training %%
phi = zeros(noTrainDocs,M1);
phi(:,1) = 1;

for j = 2:M1
    Sigma1inv = inv(Sigma1(:,:,j));
    for i = 1:noTrainDocs
        r1 = (X_training(i,:).'-mu1(:,j)).';
        r2 = r1 * Sigma1inv;
        r3 = X_training(i,:).'-mu1(:,j);
        r4 = -0.5 * r2 * r3;
        phi(i,j) = exp(r4);
        %phi(i,j) = exp (-0.5 * (X_training(i,:).'-mu1(:,j)).' * Sigma1inv * (X_training(i,:).'-mu1(:,j)) );
    end
end


%% Calculating phi for X Validation and Y Validation %%
oldvalid = noValidationDocs;
%noValidationDocs = noValidationDocs - noTrainDocs;
phi2 = zeros(noValidationDocs,M1);
phi2(:,1) = 1;

for j = 2:M1
    Sigma1inv = inv(Sigma1(:,:,j));
    for i = 1:noValidationDocs
        r1 = (X_validation(i,:).'-mu1(:,j)).';
        r2 = r1 * Sigma1inv;
        r3 = X_validation(i,:).'-mu1(:,j);
        r4 = -0.5 * r2 * r3;
        phi2(i,j) = exp(r4);
        %phi(i,j) = exp (-0.5 * (X_training(i,:).'-mu1(:,j)).' * Sigma1inv * (X_training(i,:).'-mu1(:,j)) );
    end
end 

%% Hypertuning lambda1 %%
lambda1 = 0.1;

for k =1 : 5
    lambda1 = lambda1 + 0.1;
    w1 =  inv((lambda1 * eye(M1,M1))+(phi.'*phi)) * (phi.' * Y_training); 
    %wvalidation =  inv((lambda1 * eye(M1,M1))+(phi2.'*phi2)) * (phi2.' * Y_validation); 
    validationError = 0.5 * (Y_validation - (phi2 * w1)).' * (Y_validation - (phi2 * w1));  
    validPer1 = sqrt(((2 * validationError) / noValidationDocs));

    if minValidPer1>validPer1
        minlambda1 = lambda1;
        minValidPer1 = validPer1;
        minw1 = w1;
        minM1=M1;
        minphi = phi;
        minmu1=mu1;
        minSigma1=Sigma1;
    end
end
end

M1=minM1;
phi=minphi;
w1 = minw1;
validPer1 = minValidPer1;
lambda1 = minlambda1;
mu1=minmu1;
Sigma1=minSigma1;
%% Calculating training error - trainPer1 %%
trainingError = 0.5 * (Y_training - (phi * w1)).' * (Y_training - (phi * w1));  
trainPer1 = sqrt(((2 * trainingError) / noTrainDocs));
