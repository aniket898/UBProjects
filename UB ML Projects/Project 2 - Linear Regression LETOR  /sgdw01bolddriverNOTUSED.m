eta1 = zeros(1,noTrainDocs);
eta1(1,1) = 1;
dw1 = zeros(M1,noTrainDocs);
w01(1:M1,1)=3;

%lambda1=0.05;
previousw = w01;
nexteta = eta1(1,1);
errordelta =  (-1 * ( Y_training(1,:) - ( (previousw).' * phi(1,:).' ) ) * phi(1,:)).' + (lambda1*previousw);
delta = -nexteta * errordelta;
dw1(:,1) = delta(:);
previousw = previousw + delta;

error = errordelta;

for i=2:noTrainDocs
    
    if error>errordelta
        eta1(1,i) = eta1(1,i-1)*0.5;
        error = errordelta;
    else
        eta1(1,i) = eta1(1,i-1);
    end
    errordelta =  (-1 * ( Y_training(1,:) - ( (previousw).' * phi(1,:).' ) ) * phi(1,:)).' + (lambda1*previousw);
    delta = -eta1(1,i) * errordelta;
    dw1(:,i) = delta(:);
    previousw = previousw + delta;

end 
%end
%w01 = w01.';