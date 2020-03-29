function[lambda,deagg]=runlogictree2(handles)

opt            = handles.opt;
model          = handles.model;
site           = handles.h.p;
Vs30           = handles.h.Vs30;
weights        = handles.sys.WEIGHT(:,4);
sitelist       = handles.site_selection;

%% variable initialization
IM        = opt.IM;
im        = opt.im;
Nsites    = size(site,1);
Nim       = size(im,1);
NIM       = length(IM);
Nbranch   = length(model);
Nsource   = getNsource(model);

%% do not run analysis if ind is empty
lambda  = nan(Nsites,Nim,NIM,Nsource,Nbranch);
deagg   = cell(size(lambda));

%% run logic tree
for i=1:Nbranch
    fprintf('  PSHA Branch   %i of %i - All sites\n',i,Nbranch)
    if weights(i)~=0
        deagg(:,:,:,:,i)= runhazard2(im,IM,site,Vs30,opt,model(i),Nsource,sitelist);
    end
end

for i=1:numel(deagg)
    if ~isempty(deagg{i})
        lambda(i)=sum(deagg{i}(:,3));
    end
end

