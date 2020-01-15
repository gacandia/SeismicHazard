function [model] =process_model(sys,opt)

% use msampling = 0 for magnitude sampling at gauss intgration points
% use msampling = 1 for unfirm magnitude sampling between Mmin and Mmax

ellipsoid = opt.ellipsoid;
branch    = sys.BRANCH;
GEOM      = sys.GEOM;
GMPE      = sys.GMPE;
MSCL      = sys.MSCL;
RUPT      = sys.RUPT;
GMPELIB   = sys.GMPELIB;
msampling = opt.MagDiscrete;

isordered  = isequal({sys.GEOM.source.label},{sys.MSCL.seismicity.source},{sys.RUPT.id});


%% PROCESS GEOMETRY
tt=cputime;
fprintf('%-20s','Process GEOM:')
Ngeom = length(GEOM);
geom0=struct('strike',nan,'dip',nan,'rake',nan,'W',nan,'L',nan,'Area',[],'p',[],'pmean',[],'rot',[],'spacing',[],'nref',[],'slices',[],'xyzm',[],'conn',[],'aream',[],'hypm',[],'normal',[]);
for i=1:Ngeom
    Ns = length(GEOM(i).source);
    for j=1:Ns
        source=GEOM(i).source(j);
        geom = geom0;
        
        if ~contains(source.mechanism,'shallowcrustal')
            switch source.type
                case 'point'
                    geom.p     = source.vertices;
                    geom.pmean = source.vertices;
                    geom.Area  = 0;
                    GEOM(i).source(j).geom = geom;
                    
                case 'line'
                    geom.p     = source.vertices;
                    geom.pmean = source.vertices;
                    geom.Area  = 0;
                    [~,B]=intersect({sys.RUPT.id},source.label);
                    geom.spacing = sys.RUPT(B).spacing;
                    geom.nref    = sys.RUPT(B).nref;
                    GEOM(i).source(j).geom = geom;
                    
                case 'area'
                    if isempty(source.datasource)
                        [geom.p,geom.pmean,geom.rot]  = rotateplane(source.vertices,ellipsoid);
                        
                        if ~isnan(source.geom.dip)
                            geom.dip=source.geom.dip;
                        else
                            geom.dip = createFit2Dplane(source.vertices,ellipsoid); % average dip angle
                        end
                        
                        if ~isnan(source.geom.rake)
                            geom.rake=source.geom.rake;
                        end
                        
                        if isordered
                            B=j;
                        else
                            [~,B]=intersect({sys.RUPT.id},source.label);
                        end
                        
                        geom.spacing = sys.RUPT(B).spacing;
                        geom.nref    = sys.RUPT(B).nref;
                        geom.slices  = sys.RUPT(B).slices;
                        GEOM(i).source(j).geom = geom;
                    else
                        z=load(source.datasource);
                        z=z.geom(j);
                        [p,pmean,rot] = rotateplane(z.vertices,ellipsoid);
                        geom.p       = p;
                        geom.pmean   = pmean;
                        geom.rot     = rot;
                        geom.xyzm    = z.xyzm;
                        geom.aream   = z.aream;
                        geom.hypm    = z.hypm;
                        geom.conn    = z.conn;
                        geom.normal  = z.normal;
                        GEOM(i).source(j).geom = geom;
                    end
            end
        else % contains(source.mechanism,'shallowcrustal')
            [geom.strike,geom.dip] = geomStrikeDip(source.vertices,ellipsoid);
            dipvec    = [-1 1]*gps2xyz(source.vertices([1,2],:),ellipsoid);
            geom.W    = norm(dipvec);
            strikevec = [-1 1]*gps2xyz(source.vertices([1,4],:),ellipsoid);
            geom.L    = norm(strikevec);
            geom.Area = geom.L*geom.W;
            
            [geom.p,geom.pmean,geom.rot,geom.vertices]  = rotateplane(source.vertices,ellipsoid);
            if isordered
                B=j;
            else
                [~,B]=intersect({sys.RUPT.id},source.label);
            end
            geom.spacing = sys.RUPT(B).spacing;
            geom.nref    = sys.RUPT(B).nref;
            geom.slices  = sys.RUPT(B).slices;
            GEOM(i).source(j).geom = geom;
        end
    end
end
fprintf('%4.3f s\n',cputime-tt)

%% PROCESS MAGNITUDE SCALING
tt=cputime;
fprintf('%-20s','Process MSCL:')
Nmscl = length(MSCL);
if strcmpi(msampling{1},'gauss') %gaussian Magnitude sampling
    for i=1:Nmscl
        Nsource = length(MSCL(i).seismicity);
        for j=1:Nsource
            seis  = MSCL(i).seismicity(j);
            param = seis.msparam;
            label = MSCL(i).seismicity(j).source;
            [I,J] = getgeomptr(GEOM,label,j,isordered);
            source  = GEOM(I).source(J);
            if isfield(param,'catalog')
                [~,~,ext]= fileparts(param.catalog);
                if i==1
                    switch ext
                        case '.mat', load(param.catalog);
                        case '.xlsx', cat = importdata(param.catalog);
                    end
                end
                param = runWeichert(param,source,cat);
                MSCL(i).seismicity(j).msparam = param;
            end
            
            switch func2str(seis.handle)
                case 'delta'
                    M       = param.M;
                    mweight = 1;
                    [mpdf,~,meanMo]              = seis.handle(M,param);
                    MSCL(i).seismicity(j).M      = M;
                    MSCL(i).seismicity(j).dPm    = mweight.*mpdf/(mweight'*mpdf);
                    MSCL(i).seismicity(j).meanMo = meanMo;
                    
                case 'magtable'
                    minMag   = param.minmag;
                    binWidth = param.binwidth;
                    lambdaM  = param.lambdaM;
                    Nm       = length(param.lambdaM);
                    Mmin     = minMag-binWidth/2;
                    Mmax     = (Mmin+binWidth*(Nm-1));
                    M        = (Mmin:binWidth:Mmax);
                    MSCL(i).seismicity(j).M      = M(:);
                    MSCL(i).seismicity(j).dPm    = lambdaM/sum(lambdaM);
                    MSCL(i).seismicity(j).meanMo = nan;
                    
                case 'truncexp'
                    if isfield(param,'sigmab')
                        nM          = msampling{2};
                        minterval   = [param.Mmin,param.Mmax];
                        [M,mweight] = gaussquad(nM,minterval);
                        [mpdf,~,meanMo]              = seis.handle(M,param);
                        MSCL(i).seismicity(j).M      = M;
                        MSCL(i).seismicity(j).dPm    = mweight.*mpdf/(mweight'*mpdf);
                        MSCL(i).seismicity(j).meanMo = meanMo;
                    else
                        nM          = msampling{2};
                        minterval   = [param.Mmin,param.Mmax];
                        [M,mweight] = gaussquad(nM,minterval);
                        [mpdf,~,meanMo]              = seis.handle(M,param);
                        MSCL(i).seismicity(j).M      = M;
                        MSCL(i).seismicity(j).dPm    = mweight.*mpdf/(mweight'*mpdf);
                        MSCL(i).seismicity(j).meanMo = meanMo;
                    end
                    
                case 'truncnorm'
                    nM          = msampling{2};
                    minterval   = [param.Mmin, param.Mmax];
                    [M,mweight] = gaussquad(nM,minterval);
                    [mpdf,~,meanMo]              = seis.handle(M,param);
                    MSCL(i).seismicity(j).M      = M;
                    MSCL(i).seismicity(j).dPm    = mweight.*mpdf/(mweight'*mpdf);
                    MSCL(i).seismicity(j).meanMo = meanMo;
                    
                case 'youngscoppersmith'
                    nM      = msampling{2};
                    nM1     = max(round(nM*4/5),5);
                    nM2     = max(nM-nM1,4);
                    mint1   = [param.Mmin,param.Mchar-0.25];
                    mint2   = [param.Mchar-0.25,param.Mchar+0.25];
                    [M1,mweight1] = gaussquad(nM1,mint1);
                    [M2,mweight2] = gaussquad(nM2,mint2);
                    M       = [M1;M2];
                    mweight = [mweight1;mweight2];
                    [mpdf,~,meanMo]              = seis.handle(M,param);
                    MSCL(i).seismicity(j).M      = M;
                    MSCL(i).seismicity(j).dPm    = mweight.*mpdf/(mweight'*mpdf);
                    MSCL(i).seismicity(j).meanMo = meanMo;
                    
            end
        end
    end
end

if strcmpi(msampling{1},'uniform') % uniform magnitude bins (brute force)
    for i=1:Nmscl
        Nsource = length(MSCL(i).seismicity);
        for j=1:Nsource
            seis    = MSCL(i).seismicity(j);
            param   = seis.msparam;
            % runs Catalog Declustering
            label = MSCL(i).seismicity(j).source;
            [I,J] = getgeomptr(GEOM,label,j,isordered);
            source  = GEOM(I).source(J);
            if isfield(param,'catalog')
                [~,~,ext]= fileparts(param.catalog);
                if i==1
                    switch ext
                        case '.mat', load(param.catalog);
                        case '.xlsx', cat = importdata(param.catalog);
                    end
                end
                param = getsourceparameters(param,source,cat);
                MSCL(i).seismicity(j).msparam = param;
            end
            switch func2str(seis.handle)
                case 'delta'
                    M       = param.M;
                    mweight = 1;
                    
                case 'magtable'
                    minMag   = param.minmag;
                    binWidth = param.binwidth;
                    lambdaM  = param.lambdaM;
                    Nm       = length(param.lambdaM);
                    Mmin     = minMag-binWidth/2;
                    Mmax     = (Mmin+binWidth*(Nm-1));
                    M        = Mmin:binWidth:Mmax;
                    MSCL(i).seismicity(j).M      = M(:);
                    MSCL(i).seismicity(j).dPm    = lambdaM/sum(lambdaM);
                    MSCL(i).seismicity(j).meanMo = nan;
                    
                case 'truncexp'
                    dM = msampling{2};
                    M = (param.Mmin+dM/2:dM:param.Mmax-dM/2)';
                    mweight = dM*ones(size(M));
                    
                case 'truncnorm'
                    dM = msampling{2};
                    M = (param.Mmin+dM/2:dM:param.Mmax-dM/2)';
                    mweight = dM*ones(size(M));
                    
                case 'youngscoppersmith'
                    dM = msampling{2};
                    M = (param.Mmin+dM/2:dM:param.Mmax-dM/2)';
                    mweight = dM*ones(size(M));
            end
            [mpdf,~,meanMo]              = seis.handle(M,param);
            MSCL(i).seismicity(j).M      = M;
            MSCL(i).seismicity(j).dPm    = mweight.*mpdf/(mweight'*mpdf);
            MSCL(i).seismicity(j).meanMo = meanMo;
        end
    end
end
fprintf('%4.3f s\n',cputime-tt)

%% MESH SOURCES
tt=cputime;
fprintf('%-20s','Process RUPT:')
for i=1:Ngeom
    
    GEOM(i).source=mesh_source(GEOM(i).source,opt);
    Ns = length(GEOM(i).source);
    for j=1:Ns
        GEOM(i).source(j).geom.Area = sum(GEOM(i).source(j).geom.aream);
    end
end
fprintf('%4.3f s\n',cputime-tt)

%% BUILDS MODEL STRUCTURE
tt=cputime;
fprintf('%-20s','Process MODEL:')
Ntot          = size(branch,1);
model(1:Ntot) = struct('id',[],'id1',[],'id2',[],'id3',[],'isregular',[],'source',[]);

for cont=1:Ntot
    i = branch(cont,1);
    j = branch(cont,2);
    k = branch(cont,3);
    source = GEOM(i).source;
    msc    = MSCL(k);
    sourcenames = {msc.seismicity.source};
    for p=1:length(source)
        sgmpe  = source(p).gptr;
        gptr  = GMPE(j).ptrs(sgmpe);
        source(p).gmpe= GMPELIB(gptr);
        
        if isordered
            B=p;
        else
            [~,B] = intersect(sourcenames,source(p).label,'stable');
        end
        msclB    = msc.seismicity(B);
        source(p).mscl = msclB;
    end
    sourcenames = {RUPT.id};
    
    for p=1:length(source)
        if isordered
            B=p;
        else
            [~,B] = intersect(sourcenames,source(p).label,'stable');
        end
        source(p).rupt = RUPT(B);
    end
    
    model(cont).id1 = GEOM(i).id;
    model(cont).id2 = GMPE(j).id;
    model(cont).id3 = MSCL(k).id;
    model(cont).source = source;
end
fprintf('%4.3f s\n',cputime-tt)

%% COMPUTES ACTIVITY RATES
tt=cputime;
fprintf('%-20s','Process RATE:')
for i=1:Ntot
    Nsource = length(model(i).source);
    for j=1:Nsource
        mscl    = model(i).source(j).mscl;
        msparam = mscl.msparam;
        meanMo  = mscl.meanMo;
        
        % Computes NMmin from Slip Rate
        if isfield(msparam,'sliprate')
            mu         = opt.ShearModulus;        % dyne/cm2
            A          = model(i).source(j).geom.Area* 1e10;     % cm2
            S          = msparam.sliprate* 0.100; % cm/year
            NMmin      = mu*A*S/meanMo;
            model(i).source(j).mscl.msparam.NMmin = NMmin;
        end
        
        if isfield(msparam,'lambdaM')
            model(i).source(j).mscl.msparam.NMmin=model(i).source(j).mscl.msparam.lambdaM(1);
        end
        
        % Saves SlipRate to model.source.mscl
        mu    = opt.ShearModulus;                       % dyne/cm2
        A     = model(i).source(j).geom.Area* 1e10;     % cm2
        NMmin = model(i).source(j).mscl.msparam.NMmin;  % events/year
        model(i).source(j).mscl.SlipRate = NMmin*meanMo/(mu*A) * 10; % mm/year
    end
end
fprintf('%4.3f s\n',cputime-tt)

%% DEFINES IF IS A REGULAR- OR PCE- MODEL
isREGULAR = runhazcheck(model);
for i=1:Ntot
    if isREGULAR(i)
        model(i).id        = sprintf('Branch%g',i);
        model(i).isregular = isREGULAR(i);
    else
        model(i).id        = sprintf('Branch%g (CGMM)',i);
        model(i).isregular = isREGULAR(i);
    end
end

function [I,J] = getgeomptr(GEOM,label,j,isordered)

for i=1:length(GEOM)
    if isordered
        J=j;
        I=i;
        break
    else
        [~,J]=intersect({GEOM(i).source.label},label);
        if ~isempty(J)
            I=i;
            break
        end
    end
end


