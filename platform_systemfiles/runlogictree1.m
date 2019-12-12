function[MRE,MREPCE]=runlogictree1(sys,model,opt,h,sitelist,idx)

isREGULAR = find(horzcat(model.isregular)==1);
isPCE     = find(horzcat(model.isregular)==0);

%% variable initialization
site      = h.p;
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
home
fprintf('\n');
spat  = '%-20s   |   %-30s   |   %-20s     Runtime:  %-4.3f s\n';
t0 = tic;
fprintf('                               SEISMIC HAZARD ANALYSIS \n');
fprintf('-----------------------------------------------------------------------------------------------------------\n');

MRE     = nan (Nsites,Nim,NIM,Nsource,Nbranch);
MREPCE  = cell(1,Nbranch);

if license('test','Distrib_Computing_Toolbox')
    for i=isREGULAR
        ti=tic;
        ID1=model(i).id1; if length(ID1)>27,ID1=[ID1(1:27),'...'];end
        ID2=model(i).id2; if length(ID2)>27,ID2=[ID2(1:27),'...'];end
        ID3=model(i).id3; if length(ID3)>27,ID3=[ID3(1:27),'...'];end
        if weights(i)~=0
            MRE(:,:,:,:,i) = runhazard1(im,IM,site,Vs30,opt,model(i),Nsource,sitelist);
            fprintf(spat,ID1,ID2,ID3,toc(ti));
        end
    end
    
    parfor i=isPCE
        ti=tic;
        ID1=model(i).id1; if length(ID1)>27,ID1=[ID1(1:27),'...'];end
        ID2=model(i).id2; if length(ID2)>27,ID2=[ID2(1:27),'...'];end
        ID3=model(i).id3; if length(ID3)>27,ID3=[ID3(1:27),'...'];end
        if weights(i)~=0
            MREPCE{i}=runhazard1PCE(im,IM,site,Vs30,opt,model(i),Nsource,sitelist);
            fprintf(spat,ID1,ID2,ID3,toc(ti));
        end
    end
else
    for i=isREGULAR
        ti=tic;
        ID1=model(i).id1; if length(ID1)>27,ID1=[ID1(1:27),'...'];end
        ID2=model(i).id2; if length(ID2)>27,ID2=[ID2(1:27),'...'];end
        ID3=model(i).id3; if length(ID3)>27,ID3=[ID3(1:27),'...'];end
        if weights(i)~=0
            MRE(:,:,:,:,i) = runhazard1(im,IM,site,Vs30,opt,model(i),Nsource,sitelist);
            fprintf(spat,ID1,ID2,ID3,toc(ti));
        end
    end
    
    for i=isPCE
        ti=tic;
        ID1=model(i).id1; if length(ID1)>27,ID1=[ID1(1:27),'...'];end
        ID2=model(i).id2; if length(ID2)>27,ID2=[ID2(1:27),'...'];end
        ID3=model(i).id3; if length(ID3)>27,ID3=[ID3(1:27),'...'];end
        if weights(i)~=0
            MREPCE{i}=runhazard1PCE(im,IM,site,Vs30,opt,model(i),Nsource,sitelist);
            fprintf(spat,ID1,ID2,ID3,toc(ti));
        end
    end
    
end

fprintf('-----------------------------------------------------------------------------------------------------------\n');
fprintf('%-88sTotal:     %-4.3f s\n','',toc(t0));

%% back to all sites
if nargin==6
    MRE = MRE(idx,:,:,:,:);
    for i=isPCE
        MREPCE{i}=MREPCE{i}(idx,:,:,:,:);
    end
end



