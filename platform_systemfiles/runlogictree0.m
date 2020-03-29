function[MRE,MREPCE]=runlogictree0(sys,model,opt,h,idx)

isREGULAR = find(horzcat(model.isregular)==1);
isPCE     = find(horzcat(model.isregular)==0);

%% variable initialization
sites     = h.p;
weights   = sys.WEIGHT(:,4);
IM        = opt.IM;
im        = opt.im;
Vs30      = h.Vs30;
%%
Nsites    = size(sites,1);
Nim       = size(im,1);
NIM       = length(IM);
Nbranch   = length(model);
Nsource   = 0;
for i=1:Nbranch
    Nsource = max(Nsource,length(model(i).source));
end

%% run logic tree
home
fprintf('\n');
spat  = '%-20s   |   %-30s   |   %-20s     Runtime:  %-4.3f s\n';
t0 = tic;
fprintf('                           SEISMIC HAZARD ANALYSIS (Lite Mode)\n');
fprintf('-----------------------------------------------------------------------------------------------------------\n');

MRE     = ones (Nsites,Nim,NIM);
MREPCE  = ones (Nsites,Nim,NIM);

for i=isREGULAR
    ti=tic;
    ID1=model(i).id1; if length(ID1)>27,ID1=[ID1(1:27),'...'];end
    ID2=model(i).id2; if length(ID2)>27,ID2=[ID2(1:27),'...'];end
    ID3=model(i).id3; if length(ID3)>27,ID3=[ID3(1:27),'...'];end
    if weights(i)~=0
        MRE_i = runhazard1_lite(im,IM,sites,Vs30,opt,model(i),Nsource);
        MRE   = MRE.*(MRE_i.^weights(i));
        fprintf(spat,ID1,ID2,ID3,toc(ti));
    end
end

for i=isPCE
    ti=tic;
    ID1=model(i).id1; if length(ID1)>27,ID1=[ID1(1:27),'...'];end
    ID2=model(i).id2; if length(ID2)>27,ID2=[ID2(1:27),'...'];end
    ID3=model(i).id3; if length(ID3)>27,ID3=[ID3(1:27),'...'];end
    if weights(i)~=0
        MREPCE_i = runhazard1PCE(im,IM,sites,Vs30,opt,model(i),Nsource,1:Nsites);
        MREPCE_i = sum(MREPCE_i,4);
        MREPCE_i = prctile(MREPCE_i,50,5);
        MREPCE   = MREPCE.*(MREPCE_i.^weights(i));
        fprintf(spat,ID1,ID2,ID3,toc(ti));
    end
end


fprintf('-----------------------------------------------------------------------------------------------------------\n');
fprintf('%-88sTotal:     %-4.3f s\n','',toc(t0));

MRE    = MRE(idx,:,:);
MREPCE = MREPCE(idx,:,:);



