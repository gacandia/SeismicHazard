function param = getsourceparameters(param,source,cat)

FX=source.vertices([1:end,1],2)';
FY=source.vertices([1:end,1],1)';
FDsup = param.FDsup;
FDinf = param.FDinf;
Fuente = polygon(FDsup,FDinf,{FX},{FY},cat.data.db);

Mag    = Fuente(:,6);
fmag   = cat.data.periods(:,1)';
dm     = fmag(2)-fmag(1);
bins   = (fmag(1)-dm/2):dm:(fmag(end)+dm/2);
bins   = round(bins*1000)/1000;
mcount = histc(Mag,bins)'; mcount(end)=[];

tper   = cat.data.periods(:,2)';
nobs   = mcount;
mmin   = bins(1);
mmax   = bins(end);
[b_value,sigma_b,a_value,sigma_a]=Weichert(tper,fmag,nobs,mmin,mmax);

param.Mmin      = mmin;
param.Mmax      = mmax;
param.NMmin     = a_value;
param.bvalue    = b_value;
param.sigma     = [sigma_a,sigma_b];
