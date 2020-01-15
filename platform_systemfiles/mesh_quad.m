function[p,conn,area,hyp]=mesh_quad(pv,lmax,nref)
% GENERATES QUAD MESH OF THE 3D SOURCE GIVEN BY p

r1 = pv(1,:);
r2 = pv(2,:);
r3 = pv(3,:);
r4 = pv(4,:);

BX = max(norm(r2-r1),norm(r3-r4));
BY = max(norm(r2-r3),norm(r4-r1));

LMAX  = lmax/(nref+1);
nx    = max(ceil(BX/LMAX)+1,2);
ny    = max(ceil(BY/LMAX)+1,2);
p     = zeros(nx*ny,3);

edge1=[linspace(r1(1),r2(1),nx)',...
       linspace(r1(2),r2(2),nx)',...
       linspace(r1(3),r2(3),nx)'];
edge3=[linspace(r4(1),r3(1),nx)',...
       linspace(r4(2),r3(2),nx)',...
       linspace(r4(3),r3(3),nx)'];

edge2=[linspace(r2(1),r3(1),ny)',...
       linspace(r2(2),r3(2),ny)',...
       linspace(r2(3),r3(3),ny)'];
   
edge4=[linspace(r1(1),r4(1),ny)',...
       linspace(r1(2),r4(2),ny)',...
       linspace(r1(3),r4(3),ny)'];

ind=1:nx;
p(ind,:)=edge1;
p(end-nx+1:end,:)=edge3;
for j=2:ny-1
    rI = edge4(j,:);
    rJ = edge2(j,:);
    edgej = zeros(nx,3);
    for i=1:nx
        edgej(i,:) = rI+(rJ-rI)*(i-1)/(nx-1);
    end
    ind = (1:nx)+nx*(j-1);
    p(ind,:)=edgej;
end

nsource = reshape(1:nx*ny,nx,ny);
p1 = nsource(1:end-1,1:end-1);p1=p1';p1=p1(:);
p2 = nsource(2:end,1:end-1);p2=p2';p2=p2(:);
p3 = nsource(2:end,2:end);p3=p3';p3=p3(:);
p4 = nsource(1:end-1,2:end);p4=p4';p4=p4(:);
conn = [p1,p2,p3,p4];

% computes area
V1 = p(conn(:,1),:);
V2 = p(conn(:,2),:);
V3 = p(conn(:,3),:);
V4 = p(conn(:,4),:);

A1   = 1/2*fastcross(V2-V1,V3-V1);A1=sum(A1.^2,2).^0.5;
A2   = 1/2*fastcross(V3-V1,V4-V1);A2=sum(A2.^2,2).^0.5;
area = A1+A2;

% computes hypocenter
hyp = zeros(size(conn,1),3);
for i=1:4
    hyp=hyp+1/4*p(conn(:,i),:);
end

function[c]=fastcross(a,b)
c = [ a(:,2).*b(:,3)-a(:,3).*b(:,2), a(:,3).*b(:,1)-a(:,1).*b(:,3), a(:,1).*b(:,2)-a(:,2).*b(:,1)];

