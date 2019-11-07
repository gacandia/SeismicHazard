function[MRD]=runlogictree1_MRD(sys,model,opt,h,sitelist)

%% variable initialization
site      = cell2mat(h.p(:,2:4));
Vs30      = h.Vs30;
weights   = sys.WEIGHT(:,4);
IM        = opt.IM;
im        = opt.im;
Nsites    = size(site,1);
Nim       = size(im,1);
NIM       = length(IM);
Nbranch   = length(model);
Nsource   = 0;
for i=1:Nbranch
    Nsource = max(Nsource,length(model(i).source));
end

%% run logic tree
MRD       = nan (Nsites,Nim,NIM,Nsource,Nbranch);
isREGULAR = find(horzcat(model.isregular)==1);
for i=isREGULAR
    if weights(i)~=0
        MRD(:,:,:,:,i) = runhazard1MRD(im,IM,site,Vs30,opt,model(i),Nsource,sitelist);
    end
end

