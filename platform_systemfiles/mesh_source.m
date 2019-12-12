%% 
function[y]=mesh_source(y,opt)

Nsource  = length(y);
ellip    = opt.ellipsoid;
% mesh

for i=1:Nsource
    if isempty(y(i).datasource)
        xyz   = gps2xyz(y(i).vertices,ellip);
        MaxSize = y(i).geom.spacing;
        nref    = y(i).geom.nref;
        switch y(i).type
            case 'point'  ,[y(i).geom.xyzm,y(i).geom.conn,y(i).geom.aream,y(i).geom.hypm]=mesh_point(xyz,MaxSize,nref);
            case 'line'   ,[y(i).geom.xyzm,y(i).geom.conn,y(i).geom.aream,y(i).geom.hypm]=mesh_polyline(xyz,MaxSize,nref);
            case 'area'
                switch y(i).mechanism
                    case {'interface','intraslab','grid','crustal'}
                        if size(xyz,1)==4
                            [y(i).geom.xyzm,y(i).geom.conn,y(i).geom.aream,y(i).geom.hypm] = mesh_quad(xyz,MaxSize,nref);
                        else
                            [y(i).geom.xyzm,y(i).geom.conn,y(i).geom.aream,y(i).geom.hypm] = mesh_tria(xyz,MaxSize,nref,ellip);
                        end
                    case 'shallowcrustal'
                        y(i).geom.xyzm  = xyz;
                        y(i).geom.conn  = 1:size(xyz,1);
                        y(i).geom.aream = y(i).geom.W*y(i).geom.L;
                        y(i).geom.hypm  = mean(xyz,1);
                end
        end
    end
end


% computes normal to each patch
for i=1:Nsource
    if isempty(y(i).datasource)
        y(i).geom.normal = getSourceNormal(y(i).geom);
    end
end

for i=1:Nsource
    if ~isempty(y(i).thickness) && isempty(y(i).datasource)
        switch size(y(i).geom.conn,2)
            case 3, y(i).geom=extrudeq3(y(i));
            case 4, y(i).geom=extrudeq4(y(i));
        end
    end
end

function geom = extrudeq3(y)

geom   = y.geom;
th     = y.thickness;
slices = geom.slices+1;
n_rot  = mean(geom.normal*geom.rot,1); n_rot(abs(n_rot)<10*eps)=0;
th_vec = linspace(-th/2,th/2,slices);
dth    = diff(th_vec);
xyzc0  = bsxfun(@minus,geom.xyzm,geom.pmean)*geom.rot;
xyzc   = zeros(0,3);
for i=1:slices
    xyzci = bsxfun(@plus,xyzc0,th_vec(i)*n_rot);
    xyzc = [xyzc;xyzci];
end

xyzm = bsxfun(@plus,geom.pmean,xyzc*geom.rot');
conn  = zeros(0,6);
aream = zeros(0,1);
normal = zeros(0,3);
Nelem = size(geom.xyzm,1);
for i=1:slices-1
    conn_i = [geom.conn+(i-1)*Nelem,geom.conn+(i-0)*Nelem];
    conn = [conn;conn_i]; %#ok<*AGROW>
    aream  = [aream;geom.aream*dth(i)];
    normal = [normal;geom.normal];
end

% true centroid of volumne
hypm = (xyzm(conn(:,1),:)+xyzm(conn(:,2),:)+xyzm(conn(:,3),:)+xyzm(conn(:,4),:)+xyzm(conn(:,5),:)+xyzm(conn(:,6),:))/6;
geom.xyzm=xyzm;
geom.aream=aream;
geom.hypm=hypm;
geom.normal=normal;
geom.conn =[conn(:,[1,2,3,3]);...
    conn(:,[4,5,6,6]);...
    conn(:,[1,2,5,4]);...
    conn(:,[2,3,6,5]);...
    conn(:,[1,3,6,4])];

function geom = extrudeq4(y)

geom   = y.geom;
th     = y.thickness;
slices = geom.slices;
n_rot  = mean(geom.normal*geom.rot,1); n_rot(abs(n_rot)<10*eps)=0;
th_vec = linspace(-th/2,th/2,slices);
dth    = diff(th_vec);
xyzc0  = bsxfun(@minus,geom.xyzm,geom.pmean)*geom.rot;
xyzc   = zeros(0,3);
for i=1:slices
    xyzci = bsxfun(@plus,xyzc0,th_vec(i)*n_rot);
    xyzc = [xyzc;xyzci];
end

xyzm = bsxfun(@plus,geom.pmean,xyzc*geom.rot');
conn  = zeros(0,8);
aream = zeros(0,1);
normal = zeros(0,3);
Nelem = size(geom.xyzm,1);
for i=1:slices-1
    conn_i = [geom.conn+(i-1)*Nelem,geom.conn+(i-0)*Nelem];
    conn = [conn;conn_i]; %#ok<*AGROW>
    aream  = [aream;geom.aream*dth(i)];
    normal = [normal;geom.normal];
end

hypm = (xyzm(conn(:,1),:)+xyzm(conn(:,2),:)+xyzm(conn(:,3),:)+xyzm(conn(:,4),:)+xyzm(conn(:,5),:)+xyzm(conn(:,6),:)+xyzm(conn(:,7),:)+xyzm(conn(:,8),:))/8;

geom.xyzm=xyzm;
geom.aream=aream;
geom.hypm=hypm;
geom.normal=normal;
geom.conn =[conn(:,[1,2,3,4]);...
    conn(:,[5,6,7,8]);...
    conn(:,[1,2,6,5]);...
    conn(:,[4,3,7,8]);...
    conn(:,[2,3,7,6]);...
    conn(:,[1,4,8,5])];





