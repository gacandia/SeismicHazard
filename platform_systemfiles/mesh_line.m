function[p,conn,le,hyp]=mesh_line(pv,lmax,nref)
% LINEAR MESH OF A 3D LINE DEFINED BY 2 VERTICES PV(1,:) AND PV(2,:)

r1   = pv(1,:);
r2   = pv(2,:);
L    = norm(r2-r1);
LMAX = lmax/(nref+1);
nx   = ceil(L/LMAX)+1;
p    = zeros(nx,2);
p(:,1)=linspace(pv(1),pv(2),nx);
p(:,2)=linspace(pv(3),pv(4),nx);
p(:,3)=linspace(pv(5),pv(6),nx);

conn = [1:nx-1;2:nx]';

% computes Lengts
le = ones(nx,1)*L/(nx-1);

% computes hypocenter
hyp = zeros(nx-1,3);
for i=1:2
    hyp=hyp+1/2*p(conn(:,i),:);
end


