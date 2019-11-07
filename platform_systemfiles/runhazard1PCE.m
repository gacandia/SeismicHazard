function[MRE]=runhazard1PCE(im,IM,site,Vs30,opt,model,Nsource,site_selection)
% runs a single branch of the logic tree for GMM's of type 'pce'

RandType  = opt.CGMM{1};
pce       = strcmp(opt.CGMM{2},'PC');
mcs       = ~pce;
Nreal     = opt.CGMM{3};
ellipsoid = opt.ellipsoid;
xyz       = gps2xyz(site,ellipsoid);
Nsite     = size(xyz,1);
NIM       = length(IM);
Nim       = size(im,1);
MRE       = nan(Nsite,Nim,NIM,Nsource,Nreal);

ind  = zeros(Nsite,Nsource);
for i=site_selection
    ind(i,:)=selectsource(opt.MaxDistance,xyz(i,:),model.source,ellipsoid);
end

% set random numer generator (rng)
s=rng;
rng(RandType);

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
        if pce, [MRE(k,:,:,ind_s,:)]=runPCE(source_i,xyzk,IM,im,Nreal,ellipsoid);end
        if mcs, [MRE(k,:,:,ind_s,:)]=runMCS(source_i,xyzk,IM,im,Nreal,ellipsoid);end
    end
end

% restores rng
rng(s);

return

