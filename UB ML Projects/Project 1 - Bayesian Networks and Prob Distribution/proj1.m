%%%%%  PROJECT 1 : PROBABILITY DISTRIBUTIONS AND BAYESIAN NETWORKS %%%%%
%%%%%  NAME : ANIKET THIGALE %%%%%
%%%%%  PERSON NO : 50168090 %%%%%

%%%%% READING DATA FROM FILE %%%%%
[num,text,raw] = xlsread('C:\Users\amthigale\Downloads\university_data.xlsx');
headers = raw(1,:);

%%%%% CALCULATING MEAN, VARIANCE AND STD DEVIATION OF VARIABLES %%%%%
csScore = raw(:,3);
csScore(1,:)=[];
mu1 = mean(cell2mat(csScore));
var1 = var(cell2mat(csScore));
sigma1 = std(cell2mat(csScore));

researchOverhead = raw(:,4);
researchOverhead(1,:)=[];
mu2 = mean(cell2mat(researchOverhead));
var2 = var(cell2mat(researchOverhead));
sigma2 = std(cell2mat(researchOverhead));

adminBasePay= raw(:,5);
adminBasePay(1,:)=[];
mu3 = mean(cell2mat(adminBasePay));
var3 = var(cell2mat(adminBasePay));
sigma3 = std(cell2mat(adminBasePay));


tuition = raw(:,6);
tuition(1,:)=[];
mu4 = mean(cell2mat(tuition));
var4 = var(cell2mat(tuition));
sigma4 = std(cell2mat(tuition));

%%%%% General Computation needed for future %%%%%

mu = [mu1 mu2 mu3 mu4];
sigma = [sigma1 sigma2 sigma3 sigma4];
totalData = raw(:,[3,4,5,6]);
totalData(1,:)=[];
finalData = cell2mat(totalData);


%%%%% Finding covariance between any 2 variables %%%%%

scoreoverhead = cov(cell2mat(csScore'),cell2mat(researchOverhead'));
scoretuition= cov(cell2mat(csScore),cell2mat(tuition));
scoreadminbasepay = cov(cell2mat(csScore),cell2mat(adminBasePay));
overheadadminbasepay = cov(cell2mat(researchOverhead),cell2mat(adminBasePay));
overheadtuition = cov(cell2mat(researchOverhead),cell2mat(tuition));
adminbasepaytuition = cov(cell2mat(adminBasePay),cell2mat(tuition));

%%%%% Finding Correlation between any 2 variables %%%%%

COadtu = corrcoef(cell2mat(adminBasePay),cell2mat(tuition));
COscoretu = corrcoef(cell2mat(csScore),cell2mat(tuition));
COscorebasepay = corrcoef(cell2mat(adminBasePay),cell2mat(csScore));
COoverheadbasepay = corrcoef(cell2mat(adminBasePay),cell2mat(researchOverhead));
COtuitionoverhead = corrcoef(cell2mat(tuition),cell2mat(researchOverhead));
COoverheadscore = corrcoef(cell2mat(csScore),cell2mat(researchOverhead));

%%%%% FINDING COVARIANCE MATRIX %%%%%

covarianceMat = [  var1 scoreoverhead(1,2) scoreadminbasepay(1,2) scoretuition(1,2); 
		         scoreoverhead(1,2) var2 overheadadminbasepay(1,2) overheadtuition(1,2); 
			 scoreadminbasepay(1,2) overheadadminbasepay(1,2) var3 adminbasepaytuition(1,2); 
			 scoretuition(1,2) overheadtuition(1,2) adminbasepaytuition(1,2) var4];

%%%%% FINDING CORRELATION MATRIX %%%%%         
         
correlationMat = [  1 COoverheadscore(1,2) COscorebasepay(1,2) COscoretu(1,2); 
		         COoverheadscore(1,2) 1 COoverheadbasepay(1,2) COtuitionoverhead(1,2); 
			 COscorebasepay(1,2) COoverheadbasepay(1,2) 1 COadtu(1,2); 
			 COscoretu(1,2) COtuitionoverhead(1,2) COadtu(1,2) 1];
         
         
%%%%% PLOTTING GRAPHS OF DATA POINTS %%%%%

scatter(cell2mat(csScore),cell2mat(researchOverhead))
xlabel('CS Score');
ylabel('Research Overhead');

figure

scatter(cell2mat(csScore),cell2mat(tuition))
xlabel('CS Score');
ylabel('Tuition');

figure

scatter(cell2mat(csScore),cell2mat(adminBasePay))
xlabel('CS Score');
ylabel('Administrator Base Pay');

figure

scatter(cell2mat(tuition),cell2mat(researchOverhead))
xlabel('Tuition');
ylabel('Research Overhead');

figure

scatter(cell2mat(csScore),cell2mat(researchOverhead))
xlabel('Administrator Base Pay');
ylabel('Research Overhead');

figure

scatter(cell2mat(tuition),cell2mat(adminBasePay))
xlabel('Tuition');
ylabel('Administrator Base Pay');

 
%%%%% FINDING LOG LIKELIHOOD %%%%%
logOne = sum(log(normpdf(cell2mat(csScore),mu1,sigma1)));
logTwo = sum(log(normpdf(cell2mat(researchOverhead),mu2,sigma2)));
logThree = sum(log(normpdf(cell2mat(adminBasePay),mu3,sigma3)));
logFour = sum(log(normpdf(cell2mat(tuition),mu4,sigma4)));
logLikelihood = logOne + logTwo +logThree + logFour;

%%%%% CONSTRUCTING BAYESIAN NETWORKS - EXHAUSTIVE SEARCH AND FINDING %%%%%
                %%%%% OPTIMUM BNLOGLIKELIHOOD %%%%%
BNgraph = [];
BNlogLikelihood = logLikelihood;

M = decimalToBinaryVector(0:2^16-1, 16); %Total possibilities
cnt = 2;
cyclicGraphsCount = 0;
while cnt <= 65536
   vec1 = M(cnt,:);
   mat1 = reshape(vec1,[4,4]);
   sparsemat1 = sparse(mat1);
   if graphisdag(sparsemat1)
        columnLog = 0;
        emptyParents = [];
        
        %%%%% ITERATE THROUGH EACH COLUMN %%%%%
        for column = 1:4
            matSubset = mat1(:,column);
            parents = find(matSubset);
            if isempty(parents)
               emptyParents = [emptyParents column]; 
            else
                parents = reshape(parents,[1,length(parents)]);
                matrixwithparents = [column parents];
                columnLog = columnLog + sum(log(mvnpdf(finalData(:,matrixwithparents),mu(matrixwithparents),covarianceMat(matrixwithparents,matrixwithparents))));
                if length(parents)==1
                    columnLog = columnLog - sum(log(normpdf(finalData(:,parents),mu(parents),sigma(parents))));
                else
                    columnLog = columnLog - sum(log(mvnpdf(finalData(:,parents),mu(parents),covarianceMat(parents,parents))));
                end    
            end    
        end
        
        %%%%%%  FIND ALL REMAINING COLUMNS' NORMPDF  %%%%%
        for i = emptyParents
            columnLog = columnLog + sum(log(normpdf(finalData(:,i),mu(i),sigma(i))));
        end    
        
        %%%%% CHECK IF CALCULATED LOGLIKEHOOD IS GREATER %%%%%
        if columnLog > BNlogLikelihood
            BNlogLikelihood = columnLog;
            BNgraph = mat1;
        end
   else
       cyclicGraphsCount = cyclicGraphsCount + 1;
   end    
   cnt = cnt + 1;
end

%%%%% DISPLAYING BNGRAPH %%%%%
bg = biograph(BNgraph);
view(bg)


%%%%% GENERATE PROJ1.MAT %%%%%
savefile2 = 'C:\Users\amthigale\Downloads\proj1.mat';
UBitName = 'athigale';
personNumber = '50168090';
save(savefile2,'UBitName','personNumber','mu1','mu2','mu3','mu4','var1','var2','var3','var4','sigma1','sigma2','sigma3','sigma4','covarianceMat','correlationMat','logLikelihood','BNgraph','BNlogLikelihood')
