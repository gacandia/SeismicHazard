function[Repi]=dist_epi(r0,rf,ellipsoid)
% Rrup = Closest distance to the rupture plane
% M  = seismicity
% r0 = site location
% rf = focus location

rf0  = gps2xyz(xyz2gps(rf,ellipsoid)*diag([1 1 0]),ellipsoid);
drup = bsxfun(@minus,r0,rf0);
Repi = sqrt(sum(drup.^2,2));
