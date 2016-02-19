%% STOCHASTIC GRADIENT DESCENT - REAL DATA %%
eta1 = zeros(1,noTrainDocs);
eta1(1,:) = 0.5;
dw1 = zeros(M1,noTrainDocs);
w01 = 100*rand(1,M1);
nextw = w01;
for i=1:noTrainDocs
       nexteta = eta1(1,i);
       errordelta =  -1 * ( Y_training(i,:) - ( (nextw) * phi(i,:).' ) ) * phi(i,:) + lambda1*nextw;
       delta = -nexteta * errordelta;
       dw1(:,i) = delta(:);
       nextw = nextw + delta;
end
w01 = w01.';