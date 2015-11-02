eta2 = zeros(1,noTrainDocsSyn);
eta2(1,1) = 1;
dw2 = zeros(M2,noTrainDocsSyn);
w02(1:M2,1)=5;

%lambda2=0.5;
previousw2 = w02;
nexteta2 = eta2(1,1);
errordelta2 =  (-1 * ( Y_trainingSyn(1,:) - ( (previousw).' * phi3(1,:).' ) ) * phi3(1,:)).' + (lambda2*previousw);
delta2 = -nexteta2 * errordelta2;
dw2(:,1) = delta2(:);
previousw2 = previousw2 + delta2;

error2 = errordelta2;
for i=2:noTrainDocsSyn
    
    if error2>errordelta2
        eta2(1,i) = eta2(1,i-1)*0.5;
        error2 = errordelta2;
    else
        eta2(1,i) = eta2(1,i-1);
    end
    
    errordelta2 =  (-1 * ( Y_trainingSyn(1,:) - ( (previousw2).' * phi3(1,:).' ) ) * phi3(1,:)).' + (lambda2*previousw2);
    delta2 = -eta2(1,i) * errordelta2;
    dw2(:,i) = delta2(:);
    previousw2 = previousw2 + delta2;

end 

%w02 = w02.';