function[MRE]=runMCS(source,r0,IM,im,Nreal,ellipsoid)

pd   = makedist('Normal');
t    = truncate(pd,-2,2);
zrnd = random(t,1,Nreal);

mscl     = source.mscl;
gmpe     = source.gmpe;
NIM      = length(IM);
Nim      = size(im,1);
rateM    = mscl.dPm;
NMmin    = mscl.msparam.NMmin;
gmpefun  = gmpe.handle;
Rmetric  = gmpe.Rmetric;

switch source.type
    case 'point'
        [param,rate] = mGMPEassemblePoint(r0,source,Rmetric,ellipsoid);
    case 'line'
        [param,rate] = mGMPEassembleLine(r0,source,Rmetric,ellipsoid);
    case 'area'
        switch source.mechanism
            case 'shallowcrustal'
                [param,rate] = mGMPEassembleCrustal(r0,source,rateM,Rmetric,ellipsoid);
            otherwise % 'interface','intraslab','grid','crustal'
                [param,rate] = mGMPEassembleArea(r0,source,Rmetric,ellipsoid);
        end
end

%% HAZARD INTEGRAL
MRE   = zeros(Nim,NIM,Nreal);

for j=1:NIM
    [lnY,sigma] = gmpefun(IM(j),param{:});
    mu          = mean(lnY,1);
    smu         = std (lnY,0,1);
    lnzi        = log(im(:,j));
    
    MCS = zeros(Nim, Nreal);
    MU  = bsxfun(@plus,mu,zrnd'*smu)';
    for i = 1:Nim
        xhat = bsxfun(@times,lnzi(i)-MU,1./sigma);
        ccdf = 0.5*(1-erf(xhat/sqrt(2)));
        MCS(i,:) = NMmin* rate'*ccdf;
    end
    MRE(:,j,:)=MCS;
    
end

return







