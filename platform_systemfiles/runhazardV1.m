function[lambda,MRE,MRD]=runhazardV1(im,IM,site,Vs30,opt,model,Nsource,rho,varargin)

ellipsoid  = opt.ellipsoid;
xyz        = gps2xyz(site,ellipsoid);
Nim        = size(im,1);
rho        = min(rho,0.99999);
ind        = selectsource(opt.MaxDistance,xyz,model.source,ellipsoid);
sptr       = find(ind);
source     = model.source(ind==1);
Nsource_k  = length(source);
lambda     = zeros(Nim,2,Nsource);
MRE        = nan(Nim,Nim,Nsource);
MRD        = nan(Nim,Nim,Nsource);


if nargin==8
    for i=1:Nsource_k
        ind_s    = sptr(i);
        source_i = mGMPEVs30(source(i),Vs30);
        [lambda(:,:,i),MRE(:,:,ind_s),MRD(:,:,ind_s)]=runsource(source_i,xyz,IM,im,ellipsoid,rho);
    end
    lambda = nansum(lambda,3);
    MRE    = nansum(MRE   ,3);
    MRD    = nansum(MRD   ,3);
end

if nargin==9 % this option runs only the sources listed in varargin{1}, this is used in the PSDA GUI to pre-compute vector-valued hazard 
    sourcelist=varargin{1};
    for i=1:Nsource_k
        ind_s    = sptr(i);
        if ismember(source(i).mechanism,sourcelist)
            source_i = mGMPEVs30(source(i),Vs30);
            [lambda(:,:,i),MRE(:,:,ind_s),MRD(:,:,ind_s)]=runsource(source_i,xyz,IM,im,ellipsoid,rho);
        end
    end
end




return

function[lambda,MRE,MRD]=runsource(source,r0,IM,im,ellipsoid,rho)

mscl        = source.mscl;
gmpe        = source.gmpe;
[Nim0,ncols]= size(im);
Nim         = 20;
rateM       = mscl.dPm;
NMmin       = mscl.msparam.NMmin;
gmpefun     = gmpe.handle;
Rmetric     = gmpe.Rmetric;

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
[mu1,sig1] = gmpefun(IM(1),param{:});
[mu2,sig2] = gmpefun(IM(2),param{:});

if ncols==1
    im1 = im(:,1);
    im2 = im(:,1);
else
    im1 = im(:,1);
    im2 = im(:,2);
end

% this trick is to compute MRE accurately using the 2D Simpson's rule
% The goal is to evaluate MRE = int(int(MRD(x,y),x,im1,inf),y,im2,inf)
% ------------------------------------------------------------------------
tol    = 1e-5;
minIM1 = exp(max(norminv(tol,mu1,sig1)));   minIM1 = min(minIM1,min(0.9*im1));
minIM2 = exp(max(norminv(tol,mu2,sig2)));   minIM2 = min(minIM2,min(0.9*im2));
maxIM1 = exp(max(norminv(1-tol,mu1,sig1))); maxIM1 = max(maxIM1,max(1.1*im1));
maxIM2 = exp(max(norminv(1-tol,mu2,sig2))); maxIM2 = max(maxIM2,max(1.1*im2));
im1    = unique([logsp(minIM1,maxIM1,Nim)';im(:,1)]);
im2    = unique([logsp(minIM2,maxIM2,Nim)';im(:,2)]);
Nim    = length(im1);
% ------------------------------------------------------------------------

MRD = zeros(Nim,Nim);
MRE = zeros(Nim,Nim);
[X1,X2] =meshgrid(im1,im2);
for i=1:Nim
    for j=1:Nim
        x1          = X1(i,j);
        xhat        = (log(x1)-mu1)./sig1;
        fSa1        = 1./(x1*sig1).*normpdf(xhat);
        
        x2          = X2(i,j);
        mu21        = mu2 + rho*sig2.*xhat;          % eq 6
        sig21       = sig2.*sqrt(1-rho^2);           % eq 7
        xhat2       = (log(x2)-mu21)./sig21;         % eq 5
        fSa2        = 1./(x2*sig21).*normpdf(xhat2); % eq 5
        
        MRD(i,j)    = NMmin*nansum(fSa1.*fSa2.*rate);  % eq 3
    end
end

for i=1:Nim-1
    for j=1:Nim-1
        x1 = X1(i:end,j:end);
        x2 = X2(i:end,j:end);
        F = (x1.*x2).*MRD(i:end,j:end);
        MRE(i,j) = trapz(log(x1(1,:)),trapz(log(x2(:,1)),F,1));
    end
end

[Xo1,Xo2] =meshgrid(im(:,1),im(:,2));
MRD = interp2(log(X1),log(X2),MRD,log(Xo1),log(Xo2),'spline',nan);
MRE = interp2(log(X1),log(X2),MRE,log(Xo1),log(Xo2),'spline',nan);

% scalar seismic hazard curves
lambda = zeros(Nim0,2);
for i=1:Nim0
    x       = im(i,1);
    xhat    = (log(x)-mu1)./sig1;
    ccdf1   = 0.5*(1-erf(xhat/sqrt(2)));
    deagg1  = ccdf1.*rate;
    
    x       = im(i,2);
    xhat    = (log(x)-mu2)./sig2;
    ccdf2   = 0.5*(1-erf(xhat/sqrt(2)));
    deagg2  = ccdf2.*rate;
    lambda(i,:) = NMmin*nansum([deagg1,deagg2],1);
end

return


