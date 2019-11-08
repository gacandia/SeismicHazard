function[MRE,Cz]=runPCE(source,r0,IM,im,Nreal,ellipsoid)

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
sqpi  = sqrt(pi); % squared root of pi
Nscen = length(param{1});
Psi   = [H(0,zrnd);H(1,zrnd);H(2,zrnd);H(3,zrnd);H(4,zrnd)];
Cz    = zeros(Nscen, Nim, 5);
MRE   = zeros(Nim,NIM,Nreal);

for j=1:NIM
    [lnY,sigma] = gmpefun(IM(j),param{:});
    mu          = mean(lnY,1);
    smu         = std (lnY,0,1);
    for k = 1:Nscen
        muk   = mu(k);
        smuk  = smu(k);   % Assume a standard deviation for the median
        sk    = sigma(k); % Actual Standard Deviation from GMPE
        stot  = sqrt(sk^2+smuk^2);
        
        for  i = 1:Nim
            lnz = log(im(i,j));
            a   = -smuk^2/(2*sk^2) - 1/2;
            b   = (lnz - muk) * smuk/(sk^2);
            c   = - (lnz - muk).^2/(2*sk^2);
            ee  = exp(c - b^2/(4*a));
            Cz(k, i, 1) = 1/1  * NMmin * (1-normcdf((lnz - muk)/stot));
            Cz(k, i, 2) = 1/1  * NMmin * smuk/(2*sk*sqpi)* ee * 1/((-a)^0.5);
            Cz(k, i, 3) = 1/2  * NMmin * smuk/(2*sk*sqpi)* ee * b/(2*(-a)^1.5);
            Cz(k, i, 4) = 1/6  * NMmin * smuk/(2*sk*sqpi)* ee * ((-2*a*(1 + 2*a) + b^2)/(4*(-a)^2.5));
            Cz(k, i, 5) = 1/24 * NMmin * smuk/(2*sk*sqpi)* ee * (-b*(6*a*(1 + 2*a)-b^2)/(8*(-a)^3.5));
        end
    end
    Cz         = permute(nansum(bsxfun(@times,rate,Cz),1),[2 3 1]);
    
    mre = Cz*Psi;
    ind = sum(mre<0,1)>0;
    mre(:,ind)=nan;
    MRE(:,j,:) = mre;
end

return


