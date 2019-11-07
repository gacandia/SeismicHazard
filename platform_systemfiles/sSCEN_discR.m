function[handles]=sSCEN_discR(handles,Dist)

switch handles.mesh
    case 0, handles=sSCEN_discRuser(handles,Dist);
    case 1, handles=sSCEN_discRauto(handles,Dist);
end

IND = find(cell2mat(handles.t.Data(:,8))<1e-13);
handles.t.Data(IND,:)=[];
handles.tessel(IND,:)=[];

function handles=sSCEN_discRuser(handles,MeshReduction)
%MeshReduction in percentage

current = handles.current(:,1)';
if isempty(current),return;end
ellip = handles.opt.ellipsoid;
Data  = handles.t.Data;
t     = handles.t;
mlib  = t.ColumnFormat{1};
slib  = t.ColumnFormat{2};
model = handles.model;

newdata   = cell(length(current),1);
newtessel = cell(length(current),1);

for i=1:length(current)
    row      = current(i);
    DataR    = Data(row,:);
    [~,ptr1] = intersect(mlib,DataR{1});
    [~,ptr2] = intersect(slib,DataR{2});
    source   = model(ptr1).source(ptr2);
    nelem    = size(source.geom.conn,1);
    rperm    = randperm(nelem,nelem);
    NEWp     = xyz2gps(source.geom.xyzm,ellip);
    
    NsubElem = min(max(round(MeshReduction/100*nelem),1),nelem);
    rperm    = rperm(1:NsubElem);
    conn = source.geom.conn(rperm,:);
    area = source.geom.aream(rperm,:);
    hyp  = xyz2gps(source.geom.hypm(rperm,:),ellip);
    
   
    nR  = size(hyp,1);
    DataR  = repmat(DataR,nR,1);
    DataR(:,4:5) = num2cell(hyp(:,[1,2]));
    vor = cell(nR,1);
    for jj=1:nR
        vor{jj}= [NEWp(conn(jj,:),[2,1]);NEWp(conn(jj,1),[2,1]);nan(1,2)];
    end
    RateR           = area/sum(area);
    DataR(:,8)      = num2cell(RateR);
    newdata{i}      = DataR;
    newtessel{i}    = [num2cell(area),vor];
end

handles.tessel = [handles.tessel;vertcat(newtessel{:})]; handles.tessel(current,:)=[];
handles.t.Data = [handles.t.Data;vertcat(newdata{:})];   handles.t.Data(current,:)=[];

function handles=sSCEN_discRauto(handles,Dist,varargin)
current = handles.current(:,1)';
if isempty(current),return;end

if numel(Dist)==1
    Dist = repmat(Dist,1,length(current));
end

switch handles.meshtype1.Checked
    case 'on' , meshtype = 'delaunay';
    case 'off', meshtype = 'thiessen';
end

Data  = handles.t.Data;
t     = handles.t;
mlib  = t.ColumnFormat{1};
slib  = t.ColumnFormat{2};
model = handles.model;

newdata   = cell(length(current),1);
newtessel = cell(length(current),1);
Taper     = handles.TaperEnds.Checked;

for i=1:length(current)
    row      = current(i);
    DataR    = Data(row,:);
    [~,ptr1] = intersect(mlib,DataR{1});
    [~,ptr2] = intersect(slib,DataR{2});
    source   = model(ptr1).source(ptr2);
    pdef     = [];
    if strcmp(Taper,'on')
        switch source.rupt.type
            case 'circular'    , pdef = deflate_circle   (source,DataR);
            case 'rectangular' , pdef = deflate_rectangle(source,DataR);
        end
    else
        pdef = source.geom.p(:,1:2);
    end
    
    Nnodes = size(pdef,1);
    NEWp   = pdef; %#ok<NASGU>
    
    if ~isempty(source.datasource) && contains(source.datasource,'.mat')
        NEWp = source.geom.p;
        conn = source.geom.conn;
        area = source.geom.aream;
        hyp  = source.geom.hypm;
        % aca voy! esta peluo.
        
        nR  = size(hyp,1);
        DataR  = repmat(DataR,nR,1);
        DataR(:,4:5) = num2cell(hyp);
        vor = cell(nR,1);
        for jj=1:nR
            vor{jj}= [NEWp(conn(jj,:),:);NEWp(conn(jj,1),:);nan(1,2)];
        end
        RateR           = area/sum(area);
        DataR(:,8)     = num2cell(RateR);
        newdata{i}      = DataR;
        newtessel{i}    = [num2cell(area),vor];
        
    else
        switch Nnodes
            case 4
                [NEWp,conn,area,hyp]=mesh_quad2D(pdef,Dist(i),0); %#ok<*ASGLU>
            otherwise
                [NEWp,conn,area,hyp]=mesh_tria2D(pdef,Dist(i),0);
        end
        
        switch meshtype
            case 'delaunay'
                nR  = size(hyp,1);
                DataR  = repmat(DataR,nR,1);
                DataR(:,4:5) = num2cell(hyp);
                vor = cell(nR,1);
                for jj=1:nR
                    vor{jj}= [NEWp(conn(jj,:),:);NEWp(conn(jj,1),:);nan(1,2)];
                end
                RateR           = area/sum(area);
                DataR(:,8)      = num2cell(RateR);
                newdata{i}      = DataR;
                newtessel{i}    = [num2cell(area),vor];
                
            case 'thiessen'
                nR              = size(NEWp,1);
                DataR           = repmat(DataR,nR,1);
                DataR(:,4:5)    = num2cell(NEWp);
                [vor,area]      = boundedVoroni(NEWp,pdef);
                RateR           = area/sum(area);
                DataR(:,8)      = num2cell(RateR);
                newdata{i}      = DataR;
                newtessel{i}    = [num2cell(area),vor];
        end
    end
end

handles.tessel = [handles.tessel;vertcat(newtessel{:})]; handles.tessel(current,:)=[];
handles.t.Data = [handles.t.Data;vertcat(newdata{:})];   handles.t.Data(current,:)=[];


function[vorvx,area]=boundedVoroni(X,p)
Npts = size(X,1);
[~,vorvx] = polybnd_voronoi(X,p);
vorvx     = vorvx(:);
area      = zeros(Npts,1);
XY1       = [p(1:end,:) , p([2:end,1],:)];

for i=1:Npts
    pv = vorvx{i};
    in = inpolygon2(pv(1:end-1,1),pv(1:end-1,2),p(:,1),p(:,2));
    special = 0;
    if ~all(in)
        XY2 = [pv(1:end-1,:),pv(2:end,:)];
        out = lineSegmentIntersect(XY1,XY2);
        newX = out.intMatrixX(:);
        newY = out.intMatrixY(:);
        newX = newX(newX~=0);
        newY = newY(newY~=0);
        xyi  = [newX,newY];
        pv   = [pv(in,:);xyi];
        
        % patch 10-04-2019
        pv(isnan(sum(pv,2)),:)=[];
        
        K    = convhull(pv);
        pv   = pv(K,:);
        
        % checks if a p-point is inside vor (trick to handle concave
        % shapes correctly)
        %%
        %         figure(1)
        %         clf,
        %         axis equal
        %         hold on
        %         plot(p([1:end,1],1),p([1:end,1],2),'b.-')
        %         plot(pv([1:end,1],1),pv([1:end,1],2),'b.-')
        %         plot(p(IN,1),p(IN,2),'ko')
        %         patch('vertices',NEWp,'faces',conn,'facecolor','w')
        %         NP=[NEWp(conn(6,[1,2,3,1]),:)];
        %         plot(NP(:,1),NP(:,2),'m.-')
        %%
        IN = inpolygon(p(:,1),p(:,2),pv(:,1),pv(:,2));
        d=0;
        if any(IN)
            [~,d]=inpolygon2(p(IN,1),p(IN,2), pv(:,1),pv(:,2));
            d = max(d);
        end
        if any(IN) && abs(d)>1e-4
            NEWp   = [pv(1:end-1,:);p(IN,:)];
            conn   = delaunay(NEWp(:,1),NEWp(:,2));
            hyp    = zeros(size(conn,1),2);
            for j=1:3
                hyp=hyp+1/3*NEWp(conn(:,j),:);
            end
            OUT=~inpolygon(hyp(:,1),hyp(:,2),p(:,1),p(:,2));
            conn(OUT,:)=[];
            [NEWp,conn]=fixmesh(NEWp,conn);
            NEWpv  = zeros(0,2);
            Ntria = size(conn,1);
            for j=1:Ntria
                NEWpv = [NEWpv;NEWp(conn(j,[1,2,3,1]),:)]; %#ok<AGROW>
            end
            
            z   = zeros(Ntria,1);
            V1  = [NEWp(conn(:,1),:),z];
            V2  = [NEWp(conn(:,2),:),z];
            V3  = [NEWp(conn(:,3),:),z];
            areapv = 1/2*fastcross(V2-V1,V3-V1);
            areapv = sum(areapv.^2,2).^0.5;
            special=1;
        end
        
    end
    if special==0
        area(i)  = polyarea(pv(:,1),pv(:,2));
        vorvx{i} =[pv;nan nan];
    else
        area(i)  = sum(areapv);
        vorvx{i} =[NEWpv;nan nan];
    end
    
end

function[in,d]=inpolygon2(x,y,xv,yv)

in = false(size(x));
d  = x*0;
for i=1:length(x)
    d(i)=p_poly_dist(x(i), y(i), xv, yv);
end
tol = 1e-5;
in(d<tol)=true;


