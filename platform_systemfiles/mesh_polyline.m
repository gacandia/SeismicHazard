function[p,conn,le,hyp]=mesh_polyline(pv,lmax,nref)
% POLYLINE MESH OF A 3D LINE DEFINED BY 2 VERTICES PV(1,:) AND PV(2,:)

Nnodes = size(pv,1);
p    = zeros(0,3);

for i=1:Nnodes-1
    A=mesh_line(pv(i:i+1,:),lmax,nref);
    if i==1
        p = [p;A]; %#ok<*AGROW>
    else
        p = [p;A(2:end,:)];
    end
end
conn   = [1:size(p,1)-1;2:size(p,1)]';
le     = sum((p(1:end-1,:)-p(2:end,:)).^2,2).^0.5;
hyp    = (p(1:end-1,:)+p(2:end,:))/2;
