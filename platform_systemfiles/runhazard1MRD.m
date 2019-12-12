function[MRD]=runhazard1MRD(im,IM,site,Vs30,opt,model,Nsource,site_selection)
% runs a single branch of the logic tree for GMM's of type 'regular','cond','udm'

ellipsoid = opt.ellipsoid;
xyz       = gps2xyz(site,ellipsoid);
Nsite     = size(xyz,1);
NIM       = length(IM);
Nim       = size(im,1);
MRD       = nan(Nsite,Nim,NIM,Nsource);

ind  = zeros(Nsite,Nsource);
for i=site_selection
    ind(i,:)=selectsource(opt.MaxDistance,xyz(i,:),model.source,ellipsoid);
end

for k=site_selection
    ind_k      = ind(k,:);
    sptr       = find(ind_k);
    xyzk       = xyz(k,:);
    Vs30k      = Vs30(k);
    source     = model.source(ind_k==1);
    
    Nsource_k  = length(source);
    for i=1:Nsource_k
        ind_s    = sptr(i);
        source_i = mGMPEVs30(source(i),Vs30k);
        MRD(k,:,:,ind_s)=runsource(source_i,xyzk,IM,im,ellipsoid);
    end
end

return

function MRD=runsource(source,r0,IM,im,ellipsoid)

mscl = source.mscl;
gmpe = source.gmpe;

%% MAGNITUDE RATE OF EARTHQUAKES
NIM        = length(IM);
Nim        = size(im,1);
rateM      = mscl.dPm;
NMmin      = mscl.msparam.NMmin;

%% ASSEMBLE GMPE PARAMERTER
gmpefun  = gmpe.handle;
sigma    = gmpe.usp.sigma;
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
MRD = zeros(Nim,NIM);
std_exp   = 1;
sig_overw = 1;
xhatmin   = -inf;
if ~isempty(sigma)
    switch sigma{1}
        case 'overwrite', std_exp = 0; sig_overw = sigma{2};
        case 'truncate' , xhatmin =-sigma{2};
    end
end

for j=1:NIM
    [mu,sig] = gmpefun(IM(j),param{:});
    sig = sig.^std_exp*sig_overw;
    imj = im(:,j);
    
    for i=1:Nim
        x           = imj(i);
        xhat        = (log(x)-mu)./sig;
        fa          = 1./(x*sig).*normpdf(xhat); fa(xhat<xhatmin)=0; % truncation
        deagg       = fa.*rate*1/(1-PHI);
        MRD(i,j)    = NMmin*nansum(deagg);
    end
end

return


