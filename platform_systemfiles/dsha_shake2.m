function[shakefield]=dsha_shake2(model,scenario,opt)


%% builds list of unique mechanism-magnitude scenarios for optimum L computation
allmechs = {'interface','intraslab','grid','crustal','shallowcrustal'};
disc = zeros(size(scenario,1),5);
for i=1:size(scenario,1)
    mdl       = scenario(i,1);
    src       = scenario(i,2);
    mec       = model(mdl).source(src).mechanism; [~,mec] = intersect(allmechs,mec);
    gmm       = model(mdl).source(src).gptr;
    mag       = scenario(i,3);
    disc(i,:) = [mdl,src,mec,mag,gmm];
end
unk         = unique(disc, 'rows');
[~,unkScen] = ismember(disc,unk,'rows');

%% initializes shakefield structure
modelsource = unique(scenario(:,1:2),'rows');
Ngroup      = size(modelsource,1);
shakefield(1:Ngroup,1)=...
    struct('label',[],'datasource',[],'datasourceindx',[],'type',[],'mechanism',[],...
    'surface',[],'vertices',[],'thickness',[],'gptr',[],'geom',[],...
    'gmpe',[],'mscl',[],'rupt',[],'mulogIM',[],'tau',[],'phi',[],'gpsRA',[],'Lptr',[]);

datasource = model(1).source(1).datasource;

if ~isempty(datasource)&& contains(datasource,'.mat')
    meshtype = 0;
else
    meshtype = 1;
end

%% populates shakefield
if meshtype==0
    ellip = opt.ellipsoid;
    for i=1:Ngroup
        ptr1   = modelsource(i,1);
        ptr2   = modelsource(i,2);
        IND    = and(scenario(:,1)==ptr1,scenario(:,2)==ptr2);
        M      = scenario(IND,3);
        X      = scenario(IND,4);
        Y      = scenario(IND,5);
        Zer    = zeros(size(M));
        source = model(ptr1).source(ptr2);
        
        % updates source
        source.mscl.M   = M;
        source.mscl.dPm = Zer;
        hypmr           = [X,Y];
        hypm            = xyz2gps(source.geom.hypm,ellip);
        hypm(:,3)       = [];
        ind             = Zer;
        
        for j=1:length(Zer)
            d2     = sum(bsxfun(@minus,hypm,hypmr(j,:)).^2,2);
            [~,ind(j)] = min(d2);
        end
        
        source.geom.conn   = source.geom.conn(ind,:);  % recent
        source.geom.aream  = Zer+1;
        source.geom.hypm   = source.geom.hypm(ind,:);
        source.geom.normal = source.geom.normal(ind,:);
        source.mulogIM     = [];
        source.tau         = [];
        source.phi         = [];
        source.gpsRA       = [];
        source.Lptr        = unkScen(IND);
        shakefield(i)      = source;
        
    end
end

if meshtype==1
    for i=1:Ngroup
        ptr1   = modelsource(i,1);
        ptr2   = modelsource(i,2);
        IND    = and(scenario(:,1)==ptr1,scenario(:,2)==ptr2);
        M      = scenario(IND,3);
        X      = scenario(IND,4);
        Y      = scenario(IND,5);
        Zer    = zeros(size(M));
        source = model(ptr1).source(ptr2);
        
        % updates source
        source.mscl.M   = M;
        source.mscl.dPm = Zer;
        rot             = source.geom.rot;
        pmean           = source.geom.pmean;
        hypmr           = [X,Y,Zer];
        hypmr0          = bsxfun(@minus,source.geom.hypm,pmean)*rot;
        hypmr0(:,3)     = [];
        ind             = Zer;
        
        for j=1:length(Zer)
            d2         = sum(bsxfun(@minus,hypmr0,hypmr(j,1:2)).^2,2);
            [~,ind(j)] = min(d2);
        end
        source.geom.conn   = source.geom.conn(ind,:);  % recent
        source.geom.aream  = Zer+1;
        source.geom.hypm   = bsxfun(@plus,hypmr*rot',pmean);
        source.geom.normal = source.geom.normal(ind,:);
        source.mulogIM     = [];
        source.tau         = [];
        source.phi         = [];
        source.gpsRA       = [];
        source.Lptr        = unkScen(IND);
        shakefield(i)      = source;
    end
end


