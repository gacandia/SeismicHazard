function[MRE]=runhazard1(im,IM,site,Vs30,opt,model,Nsource,site_selection)
% runs a single branch of the logic tree for GMM's of type 'regular','cond','udm'

ellipsoid = opt.ellipsoid;
xyz       = gps2xyz(site,ellipsoid);
Nsite     = size(xyz,1);
NIM       = length(IM);
Nim       = size(im,1);
MRE       = nan(Nsite,Nim,NIM,Nsource);

ind    = zeros(Nsite,Nsource);
slocal = 1:length(model.source);
for i=site_selection
    ind(i,slocal)=selectsource(opt.MaxDistance,xyz(i,:),model.source,ellipsoid);
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
        MRE(k,:,:,ind_s)=runsource(source_i,xyzk,IM,im,ellipsoid);
        if mod(i,100)==0
            fprintf('%g de %g\n',i,Nsource_k)
        end
    end
end

return

function MRE=runsource(source,r0,IM,im,ellipsoid)

mscl  = source.mscl;
gmpe  = source.gmpe;

%% MAGNITUDE RATE OF EARTHQUAKES
NIM        = length(IM);
Nim        = size(im,1);
rateM      = mscl.dPm;
NMmin      = mscl.msparam.NMmin;

%% ASSEMBLE GMPE PARAMERTER
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
            case {'interface','intraslab','grid','crustal'}
                [param,rate] = mGMPEassembleArea(r0,source,Rmetric,ellipsoid);
        end
end

%% HAZARD INTEGRAL NON FRANKY GMMs
gmpefun   = gmpe.handle;
sigma     = gmpe.usp.sigma;
MRE       = zeros(Nim,NIM);
std_exp   = 1;
sig_overw = 1;
PHI       = 0;
if ~isempty(sigma)
    switch sigma{1}
        case 'overwrite', std_exp = 0; sig_overw = sigma{2};
        case 'truncate' , PHI = 0.5*(1-erf(sigma{2}/sqrt(2)));
    end
end

for j=1:NIM
    [mu,sig] = gmpefun(IM(j),param{:});
    sig = sig.^std_exp*sig_overw;
    imj = im(:,j);
    
    for i=1:Nim
        x           = imj(i);
        xhat        = (log(x)-mu)./sig;
        ccdf        = (0.5*(1-erf(xhat/sqrt(2)))-PHI)*1/(1-PHI);
        deagg       = ccdf.*rate.*(ccdf>0);
        MRE(i,j)    = NMmin*nansum(deagg);
    end
end

