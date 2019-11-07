function[mpdf,mcdf,meanMo]=truncexp(M,param)


beta  = log(10)*param.bvalue;
Mmin  = param.Mmin;
Mmax  = param.Mmax;

%PROBALILITY DENSITY FUNCTION
mpdf = beta*exp(-beta*(M-Mmin))/(1-exp(-beta*(Mmax-Mmin)));
mcdf = (1-exp(-beta*(M-Mmin)))/(1-exp(-beta*(Mmax - Mmin)));

mpdf(M<Mmin)=0; mpdf(M>Mmax)=0;
mcdf(M<Mmin)=0; mcdf(M>Mmax)=1;

% meanMo=simplify(int(10^(1.5*m+16.05)*beta*exp(-beta*(m-Mmin))/(1-exp(-beta*(Mmax-Mmin))),m,0,Mmax));
b = beta/log(10);
meanMo = b*exp(-beta*(Mmax-Mmin))*(10^(1.5*Mmax+16.05))/((1-exp(-beta*(Mmax-Mmin)))*(1.5-b));