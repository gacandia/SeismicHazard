function[haz]=haz_PSDA(handles)
handles.site_selection = 1:size(handles.h.p,1);
opt = handles.opt;

fprintf('\n');
t0 = tic;
fprintf('                               PROBABILISTIC SEISMIC HAZARD\n');
fprintf('-----------------------------------------------------------------------------------------------------------\n');

% finds what integration methods are declared in the logic tree
T3       = handles.T3(:,2:5);
[imethod,usedM]  = getmethod(handles,T3);
haz=struct('imstandard',[],'IMstandard',[],'lambda',[],'deagg',[],'imvector',[],'IMvector',[],'corrlist',[],'MRD',[]);

if any(ismember(imethod,[1 2]))
    handles.opt    = opt_update(handles,usedM,opt,1);
    haz.imstandard = handles.opt.im;
    haz.IMstandard = handles.opt.IM;
    [haz.lambda,haz.deagg]=runlogictree2(handles);
end

if any(ismember(imethod,[3 4])) % Ellen´s rigid and flexible slopes
    SMLIB=handles.sys.SMLIB;
    handles.opt = opt_update(handles,usedM,opt,3);

    corrlist =[];
    T3models = unique(T3(:));
    for i=1:length(T3models)
        [~,B]=intersect({SMLIB.id},T3models{i});
        switch SMLIB(B).str
            case 'psda_RA2011F'
                corrlist =[corrlist;SMLIB(B).param.rho]; %#ok<*AGROW>
            case 'psda_RA2011R'
                corrlist =[corrlist;SMLIB(B).param.rho];
        end
    end
    corrlist   = unique(corrlist);
    sourcelist = cell(0,1);
    [~,B1]=intersect({SMLIB.id},handles.T3(:,2)); D1=intersect({SMLIB(B1).str},{'psda_RA2011F','psda_RA2011R','psda_RS09V'});
    [~,B2]=intersect({SMLIB.id},handles.T3(:,3)); D2=intersect({SMLIB(B2).str},{'psda_RA2011F','psda_RA2011R','psda_RS09V'});
    [~,B3]=intersect({SMLIB.id},handles.T3(:,4)); D3=intersect({SMLIB(B3).str},{'psda_RA2011F','psda_RA2011R','psda_RS09V'});
    [~,B4]=intersect({SMLIB.id},handles.T3(:,5)); D4=intersect({SMLIB(B4).str},{'psda_RA2011F','psda_RA2011R','psda_RS09V'});
    if ~isempty(D1), sourcelist=[sourcelist,'interface'];end
    if ~isempty(D2), sourcelist=[sourcelist,'instraslab'];end
    if ~isempty(D3), sourcelist=[sourcelist,'crustal','shallowcrustal'];end
    if ~isempty(D4), sourcelist=[sourcelist,'grid'];end
    
    haz.imvector = handles.opt.im;
    haz.IMvector = handles.opt.IM;
    haz.corrlist = corrlist;

    Nsites  = size(handles.h.p,1);
    Nim     = size(opt.im,1);
    Nbranch = length(handles.model);
    Nsource = 0;
    for i=1:Nbranch
        Nsource = max(Nsource,length(handles.model(i).source));
    end
    Ncorr    = length(corrlist);
    haz.MRD  = zeros(Nsites,Nim,Nim,Nsource,Nbranch,Ncorr);
    for ii=1:Ncorr
        [haz.MRD(:,:,:,:,:,ii)]=runlogictree2V(handles,corrlist(ii),sourcelist);
    end
end

fprintf('-----------------------------------------------------------------------------------------------------------\n');
fprintf('%-88sTotal:     %-4.3f s\n','',toc(t0));

function[imethod,usedM]=getmethod(handles,T3)

methods  = pshatoolbox_methods(5);
s=horzcat(handles.model.source);s=s(:);
mechs = unique({s.mechanism});
mechs = strrep(mechs,'shallowcrustal','crustal');
[~,B] = intersect({'interface','intraslab','crustal','grid'},mechs);
func = {methods.str}';

Smodels = T3(:,B);
Smodels = unique(Smodels(:));
usedM   = cell(size(Smodels));

for i=1:length(usedM)
    [~,B]=intersect({handles.sys.SMLIB.id},Smodels{i});
    usedM{i}=handles.sys.SMLIB(B).str;
end

imethod = zeros(1,length(usedM));
for i=1:length(imethod)
    [~,B]=intersect(func,usedM{i});
    imethod(i)=methods(B).integrator;
end

imethod = unique(imethod);

function[opt]=opt_update(handles,usedM,opt,mtype)
T2       = handles.T2;
methods  = pshatoolbox_methods(5);

switch mtype
    case 1, B = ismember(usedM,{'psda_BMT2017M','psda_BT2007','psda_BT2007M','psda_BM2019M','psda_J07M','psda_J07Ia','psda_RS09M','psda_AM1988'}); usedM = usedM(B);
    case 3, B = ismember(usedM,{'psda_RA2011F','psda_RA2011R','psda_RS09V'}); usedM = usedM(B);
end

func = {methods.str}';
[~,b]=intersect(func,usedM);
IMfactor = zeros(0,1);
for i=1:length(b)
    IMfactor = [IMfactor;methods(b(i)).Safactor(:)];
end
IMfactor = unique(IMfactor);
Tnat     = unique(cell2mat(T2(:,2)));
IM  = [];
for i=1:length(IMfactor)
    if IMfactor(i)<=0
        IM = [IM;IMfactor(i)]; %#ok<*AGROW>
    else
        IM = [IM;IMfactor(i)*Tnat]; %#ok<*AGROW>
    end
end

NIM = length(IM);
im0 = opt.im;
im  = nan(size(im0));
Nim = size(im,1);
for i=1:NIM
    ind = find(IM(i)==opt.IM);
    if ~isempty(ind)
        im(:,i)=im0(:,ind);
    else
        if IM(i)>=0
            im(:,i)=logsp(0.001,3,Nim);
        elseif IM(i)==-1
            im(:,i)=logsp(0.001,60,Nim);
        elseif IM(i)==-5
            im(:,i)=logsp(0.001,100,Nim);
        end
    end
end

opt.IM=IM;
opt.im=im;



