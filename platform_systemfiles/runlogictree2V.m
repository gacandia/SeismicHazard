function[MRD]=runlogictree2V(handles,rho,sourcelist)

opt      = handles.opt;
model    = handles.model;
site     = cell2mat(handles.h.p(:,2:4));
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


for i=1:Nsites
    for k=1:Nbranch
        [~,~,MRD(i,:,:,:,k)]=runhazardV1(opt.im,opt.IM,site(i,:),Vs30(i),opt,model(k),Nsource,rho,sourcelist);
    end
end




