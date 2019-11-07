function[mpdf,mcdf,meanMo]=delta(M,param)

zer  = zeros(size(M));
Mchar = param.M;
mpdf = zer;
mcdf = zer;

mpdf(M==param.M)=1;
mcdf(M>=param.M)=1;
meanMo = 10.^(1.5*Mchar+16.05);
