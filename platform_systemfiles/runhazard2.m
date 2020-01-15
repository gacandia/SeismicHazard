function[deagg]=runhazard2(im,IM,site,Vs30,opt,model,Nsource,site_selection)

ellipsoid = opt.ellipsoid;
xyz       = gps2xyz(site,ellipsoid);
Nsite     = size(xyz,1);
NIM       = length(IM);
Nim       = size(im,1);
deagg     = cell(Nsite,Nim,NIM,Nsource);

ind  = zeros(Nsite,length(model.source));
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
        deagg(k,:,:,ind_s)=runsourceDeagg(source_i,xyzk,IM,im,ellipsoid);
    end
end

return

function[deagg]=runsourceDeagg(source,r0,T,im,ellipsoid)

mscl = source.mscl;
gmpe = source.gmpe;

%% MAGNITUDE RATE OF EARTHQUAKES
Nper        = length(T);
Nim         = size(im,1);
rateM       = mscl.dPm;
NMmin       = mscl.msparam.NMmin;

%% ASSEMBLE GMPE PARAMERSER
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
deagg     = cell(Nim,Nper);
std_exp   = 1;
sig_overw = 1;
PHI       = 0;
if ~isempty(sigma)
    switch sigma{1}
        case 'overwrite', std_exp = 0; sig_overw = sigma{2};
        case 'truncate' , PHI = 0.5*(1-erf(sigma{2}/sqrt(2)));
    end
end


switch gmpe.type
    case 'regular'
        Mag  = param{1};
        Rrup = param{2};
    case 'udm'
        Mag  = param{5};
        Rrup = param{6};
    case 'cond'
        Mag  = param{5};
        Rrup = param{6};
    case 'pce'
        Mag  = param{1};
        Rrup = param{2};        
    case 'frn'
        Mag  = param{6}{1};
        Rrup = param{6}{2};             
end

switch gmpe.type
    case 'pce'
        for j=1:Nper
            [mu,sig] = gmpefun(T(j),param{:});
            mu  = mean(mu,1)';
            sig = sig(:);
            sig = sig.^std_exp*sig_overw;
            imj = im(:,j);
            for i=1:Nim
                xhat        = (log(imj(i))-mu)./sig;
                ccdf        = 0.5*(PHI-erf(xhat/sqrt(2)));
                deagg{i,j}  = [Mag,Rrup,NMmin*ccdf.*rate];
            end
            
        end
        
    otherwise
     % all other GMM types 
        for j=1:Nper
            [mu,sig] = gmpefun(T(j),param{:});
            sig = sig.^std_exp*sig_overw;
            imj = im(:,j);
            for i=1:Nim
                xhat        = (log(imj(i))-mu)./sig;
                ccdf        = (0.5*(1-erf(xhat/sqrt(2)))-PHI)*1/(1-PHI);
                ccdf        = ccdf.*(ccdf>0);
                deagg{i,j}  = [Mag,Rrup,NMmin*ccdf.*rate];
            end
        end        
end

return

