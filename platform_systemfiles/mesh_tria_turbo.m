function[p,conn,area,hyp]=mesh_tria_turbo(xyz0,lmax,nref,ellipsoid)
% MESH_TRIA_TURBO correctly handles odd source geometries (non-coplanar points 
% in 3D space, most listiric faults). 
% Firt it creates a Mesh proyected on the 'best fititng plane' to identify
% the initial triangulation. Then creates a mesh using only tringles from
% the first triangulation. Known bugs: for listiric faults that make 90°
% turns does not work properly.

gps    = xyz2gps(xyz0,ellipsoid);
Np     = size(gps,1);
isEVEN = ~mod(Np,2);

if isEVEN
    isUSD   = std(gps(1:Np/2,3))<1e6;
    isLSD   = std(gps(Np/2+1:Np,3))<1e6;
    isFAULT = max(abs(gps(1:Np/2,3)-gps(Np/2+1:Np,3)))>1e-3;
    
    % detects simplefaultgeometries (e.g., as defined in GEM sources)
    if isUSD && isLSD && isFAULT
        xyz=xyz0;
        conn0=[(1:Np/2-1)',(2:Np/2)',(Np-1:-1:Np/2+1)',(Np:-1:Np/2+2)'];
        conn0=[conn0(:,[1 2 4]);conn0(:,[2 3 4])];
    else
        [xyz,conn0]=mesh_triaT(xyz0,1e10,0);
    end
else
    % detects complexfaultgeometries
    [xyz,conn0]=mesh_triaT(xyz0,1e10,0);
end

Np = size(xyz,1);
d  = zeros(Np);
ind = zeros(1,Np);
for i=1:Np
    for j=1:Np
        d(i,j)=sqrt(sum((xyz0(i,:)-xyz(j,:)).^2,2));
    end
end
for j=1:Np
    [~,ind(j)]=min(d(:,j));
end
xyz  = xyz0(ind,:);
p    = zeros(0,3);
conn = zeros(0,3);
for i=1:size(conn0)
    [x,c]=mesh_triaT(xyz(conn0(i,:),:),lmax,nref);
    dc = size(p,1);
    p=[p;x]; %#ok<*AGROW>
    conn=[conn;c+dc];
end


% computes area
V1       = p(conn(:,1),:);
V2       = p(conn(:,2),:);
V3       = p(conn(:,3),:);
area     = 1/2*fastcross(V2-V1,V3-V1);
area     = sum(area.^2,2).^0.5;

% computes hypocenter
hyp = zeros(size(conn,1),3);
for i=1:3
    hyp=hyp+1/3*p(conn(:,i),:);
end

Area_T = sum(area);
I      =(area<1e-6*Area_T);
conn(I,:) = [];
l_tol    = 1e-6*sqrt(Area_T);
[p,conn] = fixmesh(p,conn,l_tol);

function[p,conn]=mesh_triaT(pv,lmax,nref)

% GENERATES TRIANGULAR MESH OF THE 3D SOURCE GIVEN BY p
m       = mean(pv);
N       = size(pv, 1);
pv_mov  = pv-repmat(m,N,1);
covar   = pv_mov'*pv_mov/N;
[~,~,V] = svd(covar);
pv_rot  = pv_mov*V;
[p,conn]=pmesh2T(pv_rot(:,1:2),lmax,nref);

%% Computes areas
p  = bsxfun(@plus,m,[p,p(:,1)*0]*V');
V1 = p(conn(:,1),:);
V2 = p(conn(:,2),:);
V3 = p(conn(:,3),:);
area = 1/2*fastcross(V2-V1,V3-V1);
area= sum(area.^2,2).^0.5;

% % Deletes ill triangles
Area_T    = sum(area);
I=(area<1e-6*Area_T);
conn(I,:) = [];

% remove repeated nodes within l_tol
l_tol    = 1e-6*sqrt(Area_T);
[p,conn] = fixmesh(p,conn,l_tol);

function [p,t]=pmesh2T(pv,hmax,nref)
pv = [pv;pv(1,:)];

p=[];
for i=1:size(pv,1)-1
    pp=pv(i:i+1,:);
    L=sqrt(sum(diff(pp,[],1).^2,2));
    if L>hmax
        n=ceil(L/hmax);
        pp=interp1([0,1],pp,(0:n)/n);
    end
    p=[p;pp(1:end-1,:)];
end

while 1
    t=delaunay(p);
    t=removeoutsidetris(p,t,pv);
    
    area=triarea(p,t);
    [maxarea,ix]=max(area);
    if maxarea<hmax^2/2, break; end
    pc=circumcenter(p(t(ix,:),:));
    p(end+1,:)=pc;
end

for iref=1:nref
    p = [p;edgemidpoints(p,t)];
    p = unique(p,'rows');
    t=delaunayn(p);
    t=removeoutsidetris(p,t,pv);
end

function pmid=edgemidpoints(p,t)

pmid=[(p(t(:,1),:)+p(t(:,2),:))/2;
    (p(t(:,2),:)+p(t(:,3),:))/2;
    (p(t(:,3),:)+p(t(:,1),:))/2];
pmid=unique(pmid,'rows');

function a=triarea(p,t)

d12=p(t(:,2),:)-p(t(:,1),:);
d13=p(t(:,3),:)-p(t(:,1),:);
a=abs(d12(:,1).*d13(:,2)-d12(:,2).*d13(:,1))/2;

function t=removeoutsidetris(p,t,pv)

pmid=(p(t(:,1),:)+p(t(:,2),:)+p(t(:,3),:))/3;
isinside=inpolygon(pmid(:,1),pmid(:,2),pv(:,1),pv(:,2));
t=t(isinside,:);

function pc=circumcenter(p)

dp1=p(2,:)-p(1,:);
dp2=p(3,:)-p(1,:);

mid1=(p(1,:)+p(2,:))/2;
mid2=(p(1,:)+p(3,:))/2;

s=[-dp1(2),dp2(2);dp1(1),-dp2(1)]\(-mid1+mid2)';
pc=mid1+s(1)*[-dp1(2),dp1(1)];

function [p,t,pix]=fixmesh(p,t,ptol)
%FIXMESH  Remove duplicated/unused nodes and fix element orientation.
%   [P,T]=FIXMESH(P,T)

%   Copyright (C) 2004-2012 Per-Olof Persson. See COPYRIGHT.TXT for details.

if nargin<3, ptol=1024*eps; end
if nargin>=2 && (isempty(p) || isempty(t)), pix=1:size(p,1); return; end

snap=max(max(p,[],1)-min(p,[],1),[],2)*ptol;
[~,ix,jx]=unique(round(p/snap)*snap,'rows');
p=p(ix,:);

if nargin>=2
    t=reshape(jx(t),size(t));
    
    [pix,~,jx1]=unique(t);
    t=reshape(jx1,size(t));
    p=p(pix,:);
    pix=ix(pix);
    
    if size(t,2)==size(p,2)+1
        flip=simpvol(p,t)<0;
        t(flip,[1,2])=t(flip,[2,1]);
    end
end
