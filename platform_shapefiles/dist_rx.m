function[Rx]=dist_rx(r0,rf,rupArea,n,ellipsoid)
% Rrup = Closest distance to the rupture plane
% M  = seismicity
% r0 = site location
% rf = focus location

%% no rupture plane

if isempty(n)
    rf0  = gps2xyz(xyz2gps(rf,ellipsoid)*diag([1 1 0]),ellipsoid);
    drup = bsxfun(@minus,r0,rf0);
    Rx   = sqrt(sum(drup.^2,2));
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
Rx     = zeros(Nt,1);

%% Search for rjb using a foorloop :(
th = (0:2:358)'*pi/180;
% rodriguez rofumla for the special case dot(k,v)=0
% see: https://en.wikipedia.org/wiki/Rodrigues%27_rotation_formula
for i=1:Nt
    vrot    = cos(th)*v(i,:)+sin(th)*kxv(i,:);
    RA      = rf(i,:)+vrot;
    RAgps   = xyz2gps(RA,ellipsoid);
    [~,ind] = max(RAgps(:,3));
    rtop    = RAgps(ind,:);
    rtop(3) = 0;
    rtop    = gps2xyz(rtop,ellipsoid);
    Rx(i)  = sum((r0-rtop).^2)^0.5; % falta el signo ??
end

