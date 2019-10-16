function[repi]=dist_repi4(r0,rf,~,~,~,ellipsoid)
%------------------------------------------------------------------------
% repi = epicentral distance
% r0   = O(xyz) cordiantes of the site (km)
% rf   = O(xyz) cordiantes of the hypocenters (km)
% RW   = rupture width (km)
% RL   = rupture length (km)
% geom = structure with the followinf fields
%        geom.xyzm   = O(xyz) coordinates of source
%        geom.p      = s(xyz) coordinates of source
%        geom.pmean  = O(xyz) coordinates of source centroide
%        geom.normal = O(xyz) vector normal to rupture area
%        geom.rot    = projection matrix from O(xyz) to s(XYZ)
% ellipsoid = referenceEllipsoid (units=km)
%
% where O(xyz) = absolute coordinate system, (i.e., ECEF)
%       s(xyz) = coordinate system relative to fault plane. 
%
% programmed by G.Candia, CDM 2018
% gacandia@gmail.com
%------------------------------------------------------------------------

re     = xyz2gps(rf,ellipsoid)*diag([1,1,0]);
re     = gps2xyz(re,ellipsoid);
repi   = sum(bsxfun(@minus,r0,re).^2,2).^0.5;
