function[p,conn,area,hyp]=mesh_tria(pv,lmax,nref,ellip)

% GENERATES TRIANGULAR MESH OF THE 3D SOURCE GIVEN BY p
m       = mean(pv);
N       = size(pv, 1);
pv_mov  = pv-m;
covar   = pv_mov'*pv_mov/N;
[~,~,V] = svd(covar);
pv_rot  = pv_mov*V;

if max(abs(pv_rot(:,3)))>0.01*max(mean(abs(pv_rot(:,1:2))))
    % this code handles highly warped sources
   [p,conn,area,hyp]=mesh_tria_turbo(pv,lmax,nref,ellip);
    return
end

[p,conn]=pmesh2(pv_rot(:,1:2),lmax,nref);

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


function [p,t,area]=pmesh2(pv,hmax,nref)
pv = [pv;pv(1,:)];

p=[];
for i=1:size(pv,1)-1
    pp=pv(i:i+1,:);
    L=sqrt(sum(diff(pp,[],1).^2,2));
    if L>hmax
        n=ceil(L/hmax);
        pp=interp1([0,1],pp,(0:n)/n);
    end
    p=[p;pp(1:end-1,:)];  %#ok<*AGROW>
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


