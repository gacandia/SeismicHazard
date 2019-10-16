function[shakefield]=dsha_shake(model,scenario,opt)


%% builds list of unique M scenarios for fast L computation
charArr = cellfun(@num2str, scenario(:,[1,2,6]), 'Un', 0 );
charArr = cell2table(charArr);
unk     = unique(charArr, 'rows');
[~,unkScen]   = ismember(charArr,unk,'rows');

%% initializes shakefield structure
Nscenarios = size(scenario,1);
shakefield(1:Nscenarios,1)=...
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
    meanRadius = ellip.MeanRadius;
    parfor i=1:Nscenarios
        ptr1 = str2double(scenario{i,1}); % model pointer
        slib = {model(ptr1).source.label};
        [~,ptr2] = intersect(slib,scenario{i,2});
        source = model(ptr1).source(ptr2);
        
        % updates source
        source.mscl.M   = scenario{i,6};
        source.mscl.dPm = 1;
        
        hypmr  = [scenario{i,7},scenario{i,8}];
        hypm   = xyz2gps(source.geom.hypm,ellip);
        hypm(:,3)=[];
        d2     = sum(bsxfun(@minus,hypm,hypmr).^2,2);
        [~,ind]=min(d2);
        
        conn   = source.geom.conn(ind,:);  % recent
        source.geom.xyzm   = source.geom.xyzm(conn,:);
        source.geom.conn   = 1:length(conn);
        source.geom.aream  = 0;
        source.geom.hypm   = source.geom.hypm(ind,:);
        source.geom.normal = source.geom.normal(ind,:);
        
        % Computes Rupture Area coordinates (for graphical Purpose Only)
        M = scenario{i,6};
        X = scenario{i,7};
        Y = scenario{i,8};
        rupt = source.rupt;
        Amax  = rupRelation(M,0,Inf,rupt.RA{1},rupt.RA{2});
        r     = sqrt(Amax/pi);
        t     = (0:pi/15:2*pi)';
        dth   =r/meanRadius*180/pi;
        gpsRA = [X+dth*cos(t),Y+dth*sin(t),t*0];
        source.mulogIM =[];
        source.tau     =[];
        source.phi     =[];
        
        source.gpsRA  = gpsRA;
        source.Lptr   = unkScen(i);
        shakefield(i) = source;
        
    end
end

if meshtype==1
    parfor i=1:Nscenarios
        
        ptr1 = str2double(scenario{i,1}); % model pointer
        slib = {model(ptr1).source.label};
        [~,ptr2] = intersect(slib,scenario{i,2});
        source = model(ptr1).source(ptr2);
        
        % updates source
        source.mscl.M   = scenario{i,6};
        source.mscl.dPm = 1;
        
        rot   = source.geom.rot;
        pmean = source.geom.pmean;
        hypmr = [scenario{i,7},scenario{i,8},0];
        hypmr0 = bsxfun(@minus,source.geom.hypm,pmean)*rot;
        hypmr0(:,3)=[];
        d2     = sum(bsxfun(@minus,hypmr0,hypmr(1:2)).^2,2);
        [~,ind]=min(d2);
        hypm  = bsxfun(@plus,hypmr*rot',pmean);
        
        conn               = source.geom.conn(ind,:);  % recent
        source.geom.xyzm   = source.geom.xyzm(conn,:);
        source.geom.conn   = 1:length(conn);
        source.geom.aream  = 0;
        source.geom.hypm   = hypm;
        source.geom.normal = source.geom.normal(ind,:);
        
        % Computes Rupture Area coordinates (for graphical Purpose Only)
        M = scenario{i,6};
        X = scenario{i,7};
        Y = scenario{i,8};
        RAtype = scenario{i,5};
        rupt = source.rupt;
        switch RAtype
            case 'circular'
                Amax  = rupRelation(M,0,Inf,rupt.RA{1},rupt.RA{2});
                r     = sqrt(Amax/pi);
                t     = (0:pi/15:2*pi)';
                xyz   = [X+r*cos(t),Y+r*sin(t),t*0];
                xyzRA =  bsxfun(@plus,xyz*rot',pmean);
                gpsRA = xyz2gps(xyzRA,opt.ellipsoid);
                source.gpsRA  = gpsRA;
                source.mulogIM =[];
                source.tau     =[];
                source.phi     =[];
                source.Lptr   = unkScen(i);
                shakefield(i) = source;
            case 'rectangular'
                Amax = rupRelation(M,0,Inf,rupt.RA{1},rupt.RA{2});
                aratio = rupt.aratio;
                L     = sqrt(Amax*aratio);
                W     = sqrt(Amax/aratio);
                dX    = [-1 1 1 -1]'*L/2;
                dY    = [-1 -1 1 1]'*W/2;
                xyz   = [X+dX,Y+dY,dX*0];
                xyzRA =  bsxfun(@plus,xyz*rot',pmean);
                gpsRA = xyz2gps(xyzRA,opt.ellipsoid);
                source.gpsRA  = gpsRA;
                source.mulogIM =[];
                source.tau     =[];
                source.phi     =[];
                source.Lptr   = unkScen(i);
                shakefield(i) = source;
        end
        
        
        
    end
end
