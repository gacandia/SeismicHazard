function[p,conn,varargout]=mesh_quad2D(pv,lmax,nref)
% GENERATES QUAD MESH OF THE 3D SOURCE GIVEN BY p

r1 = pv(1,:);
r2 = pv(2,:);
r3 = pv(3,:);
r4 = pv(4,:);

BX = max(norm(r2-r1),norm(r3-r4));
BY = max(norm(r2-r3),norm(r4-r1));

LMAX  = lmax/(nref+1);
nx    = ceil(BX/LMAX)+1;
ny    = ceil(BY/LMAX)+1;
p     = zeros(nx*ny,2);
edge1 = zeros(nx,2);
edge3 = zeros(nx,2);
edge2 = zeros(ny,2);
edge4 = zeros(ny,2);

for i =1:nx
    edge1(i,:)=r1+(r2-r1)*(i-1)/(nx-1);
    edge3(i,:)=r4+(r3-r4)*(i-1)/(nx-1);
end

for i =1:ny
    edge2(i,:)=r2+(r3-r2)*(i-1)/(ny-1);
    edge4(i,:)=r1+(r4-r1)*(i-1)/(ny-1);
end

ind=1:nx;
p(ind,:)=edge1;
p(end-nx+1:end,:)=edge3;
for j=2:ny-1
    rI = edge4(j,:);
    rJ = edge2(j,:);
    edgej = zeros(nx,2);
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

if nargout==4
    % computes area
    zer = zeros(size(conn,1),3-size(p,2));
    V1 = [p(conn(:,1),:),zer];
    V2 = [p(conn(:,2),:),zer];
    V3 = [p(conn(:,3),:),zer];
    V4 = [p(conn(:,4),:),zer];
    
    A1   = 1/2*fastcross(V2-V1,V3-V1);A1=sum(A1.^2,2).^0.5;
    A2   = 1/2*fastcross(V3-V1,V4-V1);A2=sum(A2.^2,2).^0.5;
    varargout{1}= A1+A2;
    
    % computes hypocenter
    hyp = zeros(size(conn,1),size(p,2));
    for i=1:4
        hyp=hyp+1/4*p(conn(:,i),:);
    end
    varargout{2} = hyp;
end

% function[c]=fastcross(a,b)
% c = [ a(:,2).*b(:,3)-a(:,3).*b(:,2), a(:,3).*b(:,1)-a(:,1).*b(:,3), a(:,1).*b(:,2)-a(:,2).*b(:,1)];

