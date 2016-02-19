%% STOCHASTIC GRADIENT DESCENT - SYNTHETIC DATA %%
eta2 = zeros(1,noTrainDocsSyn);
eta2(1,:) = 1;
dw2 = zeros(M2,noTrainDocsSyn);
w02 = 100*rand(1,M2);
nextw = w02;
for i=1:noTrainDocsSyn
       nexteta = eta2(1,i);
       errordelta =  -1 * ( t(i,:) - ( (nextw) * phi3(i,:).' ) ) * phi3(i,:) + lambda2*nextw;
       delta = -nexteta * errordelta;
       dw2(:,i) = delta(:);
       nextw = nextw + delta;
end
w02 = w02.';