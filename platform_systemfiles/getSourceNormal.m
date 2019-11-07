function[n]=getSourceNormal(geom)

conn   = geom.conn;
nnodes = size(conn,2);

if nnodes == 1 || nnodes ==2 % point sourcs and line sources
    n = [];
    return
end

xyzm   = geom.xyzm;

if nnodes == 3 % tria elements
    p1  = xyzm(conn(:,1),:);
    p2  = xyzm(conn(:,2),:);
    p3  = xyzm(conn(:,3),:);
    n   = fastcross(p3-p1,p2-p1); % normal to each plane
elseif nnodes == 4 % quad elements
    p1  = xyzm(conn(:,1),:);
    p2  = xyzm(conn(:,2),:);
    p3  = xyzm(conn(:,3),:);
    p4  = xyzm(conn(:,4),:);
    n   = fastcross(p3-p1,p4-p2); % normal to each plane
    
elseif nnodes > 4
    n   = [nan nan nan];
end
nn  = sum(n.^2,2).^0.5;
n   = bsxfun(@rdivide,n,nn);
