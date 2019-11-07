function[shakefield]=dsha_shake2(model,scenario,opt)


%% builds list of unique mechanism-magnitude scenarios for optimum L computation
method     = pshatoolbox_methods(4);
fun1       = func2str(opt.Spectral);
[~,B]      = intersect({method.str},fun1);
dependency = [method(B).dependency(1),1];

allmechs = {'interface','intraslab','grid','crustal','shallowcrustal'};
disc = zeros(size(scenario,1),2);
for i=1:size(scenario,1)
    mec_i   = model(scenario(i,1)).source(scenario(i,2)).mechanism;
    [~,mec] = intersect(allmechs,mec_i);
    mag = scenario(i,3);
    disc(i,:)=[mec,mag];
end

unk = unique(disc*diag(dependency), 'rows');
[~,unkScen] = ismember(disc*diag(dependency),unk,'rows');

%% initializes shakefield structure
modelsource = unique(scenario(:,1:2),'rows');
Ngroup      = size(modelsource,1);
shakefield(1:Ngroup,1)=...
    struct('label',[],'datasource',[],'type',[],'mechanism',[],...
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


