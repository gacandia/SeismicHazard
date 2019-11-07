function[haz]=haz_PSDA_cdmM(handles)
handles.site_selection = 1:size(handles.h.p,1);
opt = handles.opt;

% finds what integration methods are declared in the logic tree
Tcdm      = handles.tableCDM.Data(:,4:7);
[imethod,usedM]=getmethod(handles,Tcdm);
haz=struct('imstandard',[],'IMstandard',[],'lambda',[],'deagg',[],'imvector',[],'IMvector',[],'corrlist',[],'MRD',[]);

if any(ismember(imethod,6))
    handles.opt   = opt_update(handles,usedM,opt);
    handles.model = handles.modelcdm;
    Ncdms         = length(handles.model);
    handles.sys.WEIGHT = ones(Ncdms,4);
    haz.imstandard = handles.opt.im;
    haz.IMstandard = handles.opt.IM;
    [haz.lambda,haz.deagg]=runlogictree2(handles);
end


function[imethod,usedM]=getmethod(handles,T3)

methods  = pshatoolbox_methods(5);
s=vertcat(handles.modelcdm.source);s=s(:);
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

function[opt]=opt_update(handles,usedM,opt)
Nrow = size(handles.tableCDM.Data,1);
T2=zeros(Nrow,1);
for i=1:Nrow
    aux = regexp(handles.tableCDM.Data{i,2},'\,','split');
   T2(i)= str2double(aux{1});
end
methods  = pshatoolbox_methods(5);


func = {methods.str}';
[~,b]=intersect(func,usedM);
IMfactor = zeros(0,1);
for i=1:length(b)
    IMfactor = [IMfactor;methods(b(i)).Safactor(:)];
end
IMfactor = unique(IMfactor);
Tnat     = unique(T2);
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



