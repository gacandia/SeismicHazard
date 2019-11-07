function[m]=invtruncexp(P,param)


beta  = log(10)*param.bvalue;
Mmin  = param.Mmin;
Mmax  = param.Mmax;

%INVERSE PROBALILITY DENSITY FUNCTION
m = Mmin - log(P*(exp(-beta*(Mmax - Mmin)) - 1) + 1)/beta;
