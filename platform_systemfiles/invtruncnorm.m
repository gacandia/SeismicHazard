function[m]=invtruncnorm(P,param)

Mmin    = param.Mmin;
Mmax    = param.Mmax;
Mchar   = param.Mchar;
sigmaM  = param.sigmaM;

pd = makedist('normal','mu',Mchar,'sigma',sigmaM);
tr = truncate(pd,Mmin,Mmax);
m  = icdf(tr,P);