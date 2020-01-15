function[sys,opt,h]=loadPSHA(filename)

%% PREPROCES TEXTFILE
sys=[];
opt=[];
h  =[];
fid  = fopen(filename);
if fid==-1
    return
end
data = textscan(fid,'%s','delimiter','\n');
data = data{1};
fclose(fid);

% removes comments and trailing blank spaces
ind=strfind(data,'#');
for i=1:size(data,1)
    if ~isempty(ind{i})
        II = ind{i}(1);
        data{i}(II:end)=[];
    end
    data{i}=deblank(data{i});
end

% removes empty lines
emptylist= [];
for i=1:size(data,1)
    if isempty(data{i,1})
        emptylist=[emptylist,i]; %#ok<*AGROW>
    end
end
data(emptylist,:)=[];

% removes multiple spaces
data=regexprep(data,' +',' ');

% computes option pointers
ptrs = nan(15,2);
for i=1:size(data,1)
    if strfind(data{i,1},'Option 0 '), ptrs(1,1) =i;end
    if strfind(data{i,1},'Option 1 '), ptrs(2,1) =i;end
    if strfind(data{i,1},'Option 2 '), ptrs(3,1) =i;end
    if strfind(data{i,1},'Option 3 '), ptrs(4,1) =i;end
    if strfind(data{i,1},'Option 4 '), ptrs(5,1) =i;end
    if strfind(data{i,1},'Option 5 '), ptrs(6,1) =i;end
    if strfind(data{i,1},'Option 6 '), ptrs(7,1) =i;end
    if strfind(data{i,1},'Option 7 '), ptrs(8,1) =i;end % sites (optional)
    if strfind(data{i,1},'Option 8 '), ptrs(9,1) =i;end % validation (optional)
    if strfind(data{i,1},'Option 9 '), ptrs(10,1)=i;end % psda (optional)
    if strfind(data{i,1},'Option 10 '),ptrs(11,1)=i;end % psda (optional)
    if strfind(data{i,1},'Option 11 '),ptrs(12,1)=i;end % psda (optional)
    if strfind(data{i,1},'Option 12 '),ptrs(13,1)=i;end % psda (optional)
    if strfind(data{i,1},'Option 13 '),ptrs(14,1)=i;end % psda (optional)
    if strfind(data{i,1},'Option 14 '),ptrs(15,1)=i;end % validation (optional)
end
ptrs = FindEndPtrs(ptrs,data);

%% GLOBAL PARAMETERS
str              = data(ptrs(1,1):ptrs(1,2),:);
str              = regexp(str,'\ : ','split');
opt.Projection   = str{1}{2};
switch opt.Projection
    case 'ECEF'
        opt.ellipsoid.Code=[];
    otherwise
        opt.ellipsoid=referenceEllipsoid(opt.Projection,'km');
end

for i=1:length(str)
    if numel(str{i})==1
        str{i}{2}='';
    end
end

opt.Image        = str{2}{2};
opt.Boundary     = str{3}{2};
opt.Layer        = str{4}{2};
opt.ShearModulus = str2double(str{5}{2});
opt.IM           = str2IM(field2str(regexp(str{6}{2},'\s+','split')));
opt.im           = eval(['[',str{7}{2},']'])'; % is stored in columns

if size(opt.im,2) ~= length(opt.IM)
    opt.im = repmat(opt.im(:,1),1,length(opt.IM));
end

opt.MaxDistance  = str2double(str{8}{2});
Mag = regexp(str{9}{2},'\ ','split');
Mag{2}=str2double(Mag{2});
opt.MagDiscrete  = Mag;

cgmm = regexp(str{10}{2},'\ ','split');
opt.CGMM         = {cgmm{1},cgmm{2},str2double(cgmm{3})};
opt.IM1          = str2IM(field2str(regexp(str{11}{2},'\s+','split'),'single'));
opt.IM2          = str2IM(field2str(regexp(str{12}{2},'\s+','split')));
opt.Spatial      = str2func(strrep(str{13}{2},'@',''));
opt.Spectral     = str2func(strrep(str{14}{2},'@',''));
opt.LiteMode     = str{15}{2};
aux              = regexp(str{16}{2},'\ ','split');  
opt.Clusters     = {aux{1},str2double(aux(2:3))};

%% ASSEMBLES LOGIC TREE
str = data(ptrs(2,1):ptrs(2,2),:);
str = regexp(str,'\:','split');

geom_weight = eval(['[',str{1}{2},']'])'; Ngeom = length(geom_weight);
gmpe_weight = eval(['[',str{2}{2},']'])'; Ngmpe = length(gmpe_weight);
mscl_weight = eval(['[',str{3}{2},']'])'; Nmscl = length(mscl_weight);

Ntot   = Ngeom*Ngmpe*Nmscl;
branch = zeros(Ntot,3);
k=0;
for d1=1:Ngeom
    for d2=1:Ngmpe
        for d3=1:Nmscl
            k=k+1;
            branch(k,:)=[d1,d2,d3];
        end
    end
end

weight = [
    geom_weight(branch(:,1)),...
    gmpe_weight(branch(:,2)),...
    mscl_weight(branch(:,3))];
weight = [weight,prod(weight,2)];

%% READS SURCE GEOMETRY
tt=cputime;
fprintf('%-20s','Reading GEOM:')
str = data(ptrs(3,1):ptrs(3,2),:);
pt  = zeros(Ngeom,2); j=1;
pt(end)=size(str,1);
GEOM(1:Ngeom) = struct('id',[],'source',[]);
for i=1:size(str,1)
    if ~isempty(strfind(str{i},'geometry'))
        s=regexp(str{i},'\ ','split');
        GEOM(j).id     = horzcat2(s{3:end});
        pt(j,1)=i+1;
        if j>1
            pt(j-1,2)=i-1;
        end
        j=j+1;
    end
end
for i=1:Ngeom
    GEOM(i).source=readGeometry(str(pt(i,1):pt(i,2)));
end
% load saraGEOM GEOM
fprintf('%4.3f s\n',cputime-tt)

%% READS GMPE LIBRRY
str = data(ptrs(4,1):ptrs(4,2),:);
Ngmpe = size(str,1);
GMPELIB(1:Ngmpe) = struct('label',[],'type',[],'handle',[],'T',[],'usp',[],'Rmetric',[],'Residuals',[],'cond',[],'var',[]);

methods = pshatoolbox_methods(1);
strs    = {methods.str};

for i=1:size(str,1)
    linea = regexp(str{i},'\s+','split');
    GMPELIB(i).label=linea{1};
    linea = linea(2:end);
    [~,B]  = intersect(linea,{'handle'});
    model  = linea{B+1};
    [~,C]  = intersect(strs,model);
    GMPELIB(i).type  = methods(C).type;
    GMPELIB(i).handle=str2func(model);
    [GMPELIB(i).T,GMPELIB(i).Rmetric,GMPELIB(i).Residuals]=mGMPE_info(model);
    linea(B:B+1)=[];
    
    clearvars usp
    np = length(linea);
    for ii=1:np/2
        if any(strcmp(linea{2*ii-1},{'method'}))
            usp.(linea{2*ii-1})=linea{2*ii};
        else
            usp.(linea{2*ii-1})=lower(linea{2*ii});
        end
    end
    usp = uspconvert(usp);
    
    [~,B6]  = intersect(linea,{'sigma'});
    if ~isempty(B6)
        B6=B6+1;
        usp.sigma={linea{B6},str2double(linea{B6+1})};
    else
        usp.sigma=[];
    end
    
    GMPELIB(i).usp=usp;
end

meth  = pshatoolbox_methods(1);
str   = {meth.str};
typ   = {meth.type};

% PROCESS USER DEFINED MODELS
Rm = zeros(0,11);
for i=1:length(GMPELIB)
    hnd = func2str(GMPELIB(i).handle);
    [~,b]=intersect(str,hnd);
    if strcmp(typ{b},'udm')
        var = feval(GMPELIB(i).usp.method);
        GMPELIB(i).T  = var.IM.value;
        GMPELIB(i).Residuals=var.residuals;
        flds = fields(var);
        for jj=1:length(flds)
            if isfield(var.(flds{jj}),'tag')
                f = var.(flds{jj});
                if strcmp(f.tag,'Distance')
                    Rm=[Rm;f.value];
                end
            end
        end
        GMPELIB(i).Rmetric = sum(Rm,1)>0;
        GMPELIB(i).var     = var;
    end
end

% PROCESS CONDITIONAL MODELS
for i=1:length(GMPELIB)
    hnd = func2str(GMPELIB(i).handle);
    [~,b]=intersect(str,hnd);
    if strcmp(typ{b},'cond')
        usp = GMPELIB(i).usp;
        [~,Rmetric]        = mGMPE_info(usp.conditioning);
        [~,b] = intersect(lower(str),usp.conditioning);
        cond.conditioning   = meth(b).func;
        GMPELIB(i).usp      = rmfield(usp,'conditioning');
        GMPELIB(i).cond     = cond;
        GMPELIB(i).Rmetric  = Rmetric;
    end
end

% PROCESS FRANKY MODELS
for i=1:length(GMPELIB)
    hnd = func2str(GMPELIB(i).handle);
    [~,b]=intersect(str,hnd);
    if strcmp(typ{b},'frn')
        usp = GMPELIB(i).usp;
        fld  = fields(usp);
        Ndepend              = length(fld)-1;
        GMPELIB(i).Residuals = 'lognormal';
        for j=1:Ndepend
            val  = GMPELIB(i).usp.(fld{j});
            GMMJ = upper(fld{j});
            GMPELIB(i).usp.(GMMJ) = GMPELIB(val);
            GMPELIB(i).T          = [GMPELIB(i).T,GMPELIB(val).T];
            GMPELIB(i).Rmetric    = [GMPELIB(i).Rmetric;GMPELIB(val).Rmetric];
        end
        GMPELIB(i).usp.Ndepend = Ndepend;
        GMPELIB(i).T           = unique(GMPELIB(i).T);
        GMPELIB(i).Rmetric     = any(GMPELIB(i).Rmetric);
        
    end
end

% READS GMPE GROUP DATA
str = data(ptrs(5,1):ptrs(5,2),:);
clear GMPEGROUP
GMPE(1:size(str,1)) = struct('id',[],'ptrs',[]);
for i=1:size(str,1)
    linea = regexp(str{i},'\ pointers ','split');
    GMPE(i).id=linea{1};
    linea = regexp(linea{2},'\s+','split');
    GMPE(i).ptrs=str2double(linea);
end

%% READS MAGNITUDE SCALING
tt=cputime;
fprintf('%-20s','Reading MSCL:')
str = data(ptrs(6,1):ptrs(6,2),:);
pt  = zeros(Nmscl,2); j=1;
pt(end)=size(str,1);
MSCL(1:Nmscl) = struct('id',[],'seismicity',[]);
for i=1:size(str,1)
    if ~isempty(strfind(str{i},'seismicity'))
        s=regexp(str{i},'\ ','split');
        MSCL(j).id     = horzcat2(s{3:end});
        pt(j,1)=i+1;
        if j>1
            pt(j-1,2)=i-1;
        end
        j=j+1;
    end
end

for i=1:Nmscl
    MSCL(i).seismicity = readSeismicity(str(pt(i,1):pt(i,2)));
end
% load saraMSCL MSCL
fprintf('%4.3f s\n',cputime-tt)

%% READS RUPTURE AREA DATA
tt=cputime;
fprintf('%-20s','Reading RUPT:')
str = data(ptrs(7,1):ptrs(7,2),:);
RUPT(1:size(str,1)) = struct('id',[],'type',[],'spacing',[],'nref',0,'slices',[],'taper',[],'RA',[],'aratio',[]);

for i=1:size(str,1)
    linea = regexp(str{i},'\s+','split');
    RUPT(i).id   = linea{1};
    
    [~,B] = intersect(linea,'type');  RUPT(i).type = linea{B+1};
    [~,B] = intersect(linea,'spacing');   if ~isempty(B), RUPT(i).spacing  = str2double(linea{B+1});end
    [~,B] = intersect(linea,'nref');      if ~isempty(B), RUPT(i).nref     = str2double(linea{B+1});end
    [~,B] = intersect(linea,'taper');     if ~isempty(B), RUPT(i).taper    = eval(linea{B+1});end
    [~,B] = intersect(linea,'aratio');    if ~isempty(B), RUPT(i).aratio   = str2double(linea{B+1});end
    [~,Bth] = intersect(linea,'slices');  if ~isempty(Bth), RUPT(i).slices = str2double(linea{Bth+1}); end
    
    [~,B]  = intersect(linea,{'RA'});
    if ~isempty(B)
        B=B+1;
        switch linea{B}
            case 'custom'
                param = cellfun(@str2double, linea(:,B+1:B+3));
            otherwise
                param =[];
        end
        RUPT(i).RA={linea{B},param};
    end
end
% load saraRUPT RUPT
fprintf('%4.3f s\n',cputime-tt)

%% READS SITES
tt=cputime;
fprintf('%-20s','Reading SITES:')
h.id        = cell(0,1);
h.p         = zeros(0,3);
h.Vs30      = zeros(0,1);
h.t         = cell(0,2);
h.shape     = [];

if ~isnan(ptrs(8,1))
    str = data(ptrs(8,1):ptrs(8,2),:);
    
    newline = regexp(str{1},'\ ','split');
    newline(1)=[];
    Nline   = length(newline);
    VS30.baseline = str2double(newline{Nline});
    if Nline>1
        VS30.source   = strrep(newline(1:Nline-1),'''','');
    else
        VS30.source  = {' '};
    end
    str(1)=[];
    
    if contains(str,'.txt')
        str=regexp(str{1},'\ ','split');
        h = ss_readtxtPSHA(str{1});
    else
        
        for i=1:size(str,1)
            if contains(str{i},'Vs30')
                linea = regexp(str{i},'\s+','split');
                id          = strjoin(linea(1:end-5),' ');
                Lat         = str2double(linea{end-4});
                Lon         = str2double(linea{end-3});
                Elev        = str2double(linea{end-2})/1000;
                Vs30        = str2double(linea{end});
                h.id{i}  = id;
                h.p(i,:)    = [Lat,Lon,Elev];
                h.Vs30(i,1) = Vs30;
            end
        end
        
        for i=1:size(str,1)
            if ~contains(str{i},'Vs30')
                linea = regexp(str{i},'\s+','split');
                id       = strjoin(linea(1:end-3),' ');
                Lat      = str2double(linea{end-2});
                Lon      = str2double(linea{end-1});
                Elev     = str2double(linea{end})/1000;
                h.id{i}  = id;
                h.p(i,:) = [Lat,Lon,Elev];
                h.Vs30(i,1) = nan;
            end
        end
    end
    IND = find(isnan(h.Vs30));
    if ~isempty(IND)
        h.Vs30(IND)=getVs30(h.p(IND,1:2),VS30);
    end
else
    VS30.baseline=760;
    VS30.source  ={' '};
end
fprintf('%4.3f s\n',cputime-tt)

%% READS VALIDATION HAZARD CURVES (optional)
do_validation=0;
if ~isnan(ptrs(9,1))
    do_validation=1;
    str = data(ptrs(9,1):ptrs(9,2),:);
    linea = regexp(str{1},'\s+','split');
    IM    = str2double(linea(2:end));
    Nsites = size(str,1)-1;
    lambdaTest = zeros(Nsites,length(IM));
    for i=2:Nsites+1
        linea = regexp(str{i},'\s+','split');
        lambdaTest(i-1,:)= str2double(linea(2:end));
    end
end

%% COMPUTES SYSTEM VARIABLE
sys.filename = filename;
sys.DATA     = data;
sys.PTRS     = ptrs;
sys.BRANCH   = branch;
sys.WEIGHT   = weight;
sys.GEOM     = GEOM;
sys.GMPE     = GMPE;
sys.MSCL     = MSCL;
sys.RUPT     = RUPT;
sys.GMPELIB  = GMPELIB;
sys.VS30     = VS30;
if do_validation
    sys.IM = IM;
    sys.lambdaTest = lambdaTest;
end

function[y]=readGeometry(str)

Ns    = size(str,1);
y(1:Ns)=struct(...
    'label',[],...
    'datasource',[],...
    'type',[],...
    'mechanism',[],...
    'surface' ,[],...
    'vertices',[],...
    'thickness',[],...
    'gptr',[],...
    'geom',[]);
for i=1:Ns
    line = regexp(str{i},'\s+','split');
    y(i).label      = line{1};
    
    % mandatory parameters
    [~,B]=intersect(line,{'type','gmpe','vertices'},'stable'); B=B+1;
    y(i).type       = line{B(1)};
    y(i).gptr       = str2double(line{B(2)});
    
    % optional parameter
    [~,Bst]=intersect(line,'mechanism');
    if ~isempty(Bst)
        y(i).mechanism   = line{Bst+1};
    end
    
    [~,Bsf]=intersect(line,'surface');
    if ~isempty(Bsf)
        y(i).surface   = str2double(line{Bsf+1});
    end
    
    [~,Bth]=intersect(line,'thickness');
    if ~isempty(Bth)
        y(i).thickness = str2double(line{Bth+1});
    end
    
    [~,C]=intersect(line,'strike');
    if ~isempty(C)
        y(i).geom.strike = str2double(line{C+1});
    end
    
    [~,C]=intersect(line,'dip');
    y(i).geom.dip=nan;
    if ~isempty(C)
        y(i).geom.dip = str2double(line{C+1});
    end
    
    [~,C]=intersect(line,'rake');
    y(i).geom.rake=nan;
    if ~isempty(C)
        y(i).geom.rake = str2double(line{C+1});
    end
    
    % This is to support geometries from a matfile, e.g. Poulos
    if isempty(strfind(line{B(3)},'.mat'))
        vertices = cellfun(@str2double, line(:,B(3):end));
        vertices = reshape(vertices,3,length(vertices)/3)';
        y(i).vertices = vertices;
        y(i).datasource = [];
    else
        z=load(line{B(3)});
        z=z.geom(i);
        y(i).vertices = z.vertices;
        y(i).datasource = line{B(3)};
    end
end

function[y]=readSeismicity(str)

Ns = size(str,1);
y(1:Ns)=struct(...
    'source',[],...
    'handle',[],...
    'msparam',[]);

for i=1:Ns
    linea = regexp(str{i},'\s+','split');
    y(i).source = linea{1};
    linea(1)=[];
    [~,B]  = intersect(linea,{'handle'});
    y(i).handle=str2func(linea{B+1});
    
    usp=struct;
    if strcmp(linea{B+1},'magtable')
        linea(B:B+1)=[];
        
        [~,C]=intersect(linea,'minmag');
        if ~isempty(C)
            usp.minmag= str2double(linea{C+1});
        end
        
        [~,C]=intersect(linea,'binwidth');
        if ~isempty(C)
            usp.binwidth= str2double(linea{C+1});
        end
        
        [~,C]=intersect(linea,'occurrates');
        if ~isempty(C)
            usp.lambdaM= str2double(linea(C+1:end))';
        end

    else
        linea(B:B+1)=[];
        
        np = length(linea);
        for ii=1:np/2
            fldname = linea{2*ii-1};
            if strcmp(fldname,'catalog')
                value   = lower(linea{2*ii});
            else
                value   = str2double(lower(linea{2*ii}));
            end
            usp.(fldname) = value;
        end
    end
    y(i).msparam = usp;
end