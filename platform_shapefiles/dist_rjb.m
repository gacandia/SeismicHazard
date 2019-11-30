function[Rjb]=dist_rjb(r0,rf,rupArea,n,ellipsoid)
% Rrup = Closest distance to the rupture plane
% M  = seismicity
% r0 = site location
% rf = focus location

%% no rupture plane

if isempty(n)
    rf0  = gps2xyz(xyz2gps(rf,ellipsoid)*diag([1 1 0]),ellipsoid);
    drup = bsxfun(@minus,r0,rf0);
    Rjb  = sqrt(sum(drup.^2,2));
    return
end

Nt = size(rf,1);
%% distance from site perpendicular to the plane
va        = bsxfun(@minus,r0,rf);
proj      = dot(va,n,2); % distance perpendicular
vb        = bsxfun(@times,n,proj);
vc        = va-vb;
dnormal   = abs(proj);
dplano    = sqrt(sum(vc.^2,2));
rupRadius = sqrt(rupArea/pi);

k       = bsxfun(@rdivide,vb,dnormal);
v       = bsxfun(@rdivide,vc,dplano).*rupRadius;
kxv     = fastcross(k,v);
Rjb     = zeros(Nt,1);

%% Search for rjb using a foorloop :(
th = (0:2:358)'*pi/180;
% rodriguez rofumla for the special case dot(k,v)=0
% see: https://en.wikipedia.org/wiki/Rodrigues%27_rotation_formula
gps0 = xyz2gps(r0,ellipsoid);
for i=1:Nt
    vrot  = cos(th)*v(i,:)+sin(th)*kxv(i,:);
    RA    = rf(i,:)+vrot;
    RA0   = xyz2gps(RA,ellipsoid)*diag([1 1 0]);
    
    if ~inpolygon(gps0(1),gps0(2),RA0(:,1),RA0(:,2))
        RA0    = gps2xyz(RA0,ellipsoid);
        drj    = sum((r0-RA0).^2,2).^0.5;
        Rjb(i) = min(drj);
    end
end

