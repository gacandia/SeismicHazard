function[Zbor]=dist_zbor(r0,rf,rupArea,n,ellipsoid)
% Rrup = Closest distance to the rupture plane
% M  = seismicity
% r0 = site location
% rf = focus location

%% no rupture plane (rupture area == 0)
if isempty(n)
    rf0   = xyz2gps(rf,ellipsoid);
    Zbor  = abs(rf0(:,3));
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
Zbor    = zeros(Nt,1);

%% Search for rjb using a foorloop :(
th = (0:2:358)'*pi/180;
% rodriguez rofumla for the special case dot(k,v)=0
% see: https://en.wikipedia.org/wiki/Rodrigues%27_rotation_formula
for i=1:Nt
    vrot  = cos(th)*v(i,:)+sin(th)*kxv(i,:);
    RA    = rf(i,:)+vrot;
    RAgps = xyz2gps(RA,ellipsoid);
    ztor  = min(RAgps(:,3));
    Zbor(i)  = abs(ztor);
end

