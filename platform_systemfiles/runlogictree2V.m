function[MRD]=runlogictree2V(handles,rho,sourcelist)

opt      = handles.opt;
model    = handles.model;
site     = handles.h.p;
Vs30     = handles.h.Vs30;

% figure out MRD size
Nsites  = size(site,1);
Nim     = size(opt.im,1);
Nbranch = length(model);
Nsource = 0;
for i=1:Nbranch
    Nsource = max(Nsource,length(model(i).source));
end
MRD  = zeros(Nsites,Nim,Nim,Nsource,Nbranch);

im = opt.im;
IM = opt.IM;
for i=1:Nsites
    site_i = site(i,:);
    Vs30i  = Vs30(i); 
    parfor k=1:Nbranch
        fprintf('V-PSHA Branch   %i of %i - Site %i\n',k,Nbranch,i)
        [~,~,MRD(i,:,:,:,k)]=runhazardV1(im,IM,site_i,Vs30i,opt,model(k),Nsource,rho,sourcelist);
    end
end




