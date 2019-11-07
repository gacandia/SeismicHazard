function[pdf,cdf,meanMo]=youngscoppersmith(M,param)

beta   = log(10)*param.bvalue;
Mmin   = param.Mmin;
Mchar  = param.Mchar;
MmaxGR = Mchar-0.25;
Mmax   = Mchar+0.25;
%PROBALILITY DENSITY
f   = M*0;
c2  = 0.5*beta*exp(-beta*(MmaxGR-Mmin-1))/(1-exp(-beta*(MmaxGR-Mmin)));

ind1 = (Mmin<=M) .*(M<=MmaxGR);
ind2 = (MmaxGR<M).*(M<=Mmax);
ind3 = (M>Mmax);

f(ind1==1) = 1/(1+c2)*beta*exp(-beta*(M(ind1==1)-Mmin))/(1-exp(-beta*(MmaxGR-Mmin)));
f(ind2==1) = 2*c2/(1+c2);

pdf=f;

% CUMMULATIVE DENSITY FUNCTOION
f   = M*0;
c2  = 0.5*beta*exp(-beta*(MmaxGR-Mmin-1))/(1-exp(-beta*(MmaxGR-Mmin)));
f(ind1==1) = 1/(c2 + 1)*(exp(-beta*(M(ind1==1) - Mmin)) - 1)/((exp(-beta*(MmaxGR-Mmin)) - 1));

f(ind2==1) = 1/(1+c2)+(1-1/(1+c2))/0.5*(M(ind2==1)-MmaxGR);
f(ind3==1) =1;
cdf=f;

% syms Mmin Mmax MmaxGR m c1 c2 beta b
% I1 = simplify(int(10^(1.5*m+16.05)*(1/(1+c2)*beta*exp(-beta*(m-Mmin))/(1-exp(-beta*(MmaxGR-Mmin)))),m,0,MmaxGR));
% I2 = simplify(int(10^(1.5*m+16.05)*(1/(1+c2)*beta*exp(-beta*(MmaxGR-Mmin-1))/(1-exp(-beta*(MmaxGR-Mmin)))),m,MmaxGR,Mmax));
I1 = -(2*10^16.05*beta*exp(-beta*(MmaxGR - Mmin))*(exp(MmaxGR*beta) - 10^((3*MmaxGR)/2)))/((c2 + 1)*(exp(-beta*(MmaxGR - Mmin)) - 1)*(2*beta - log(1000)));
I2 = -(2*10^16.05*beta*exp(beta*(Mmin - MmaxGR + 1))*(10^((3*Mmax)/2) - 10^((3*MmaxGR)/2)))/(3*log(10)*(c2 + 1)*(exp(-beta*(MmaxGR - Mmin)) - 1));

meanMo = I1+I2;