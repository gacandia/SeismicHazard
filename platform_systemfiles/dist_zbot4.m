function[zbot]=dist_zbot4(~,~,~,~,geom,ellipsoid)
%------------------------------------------------------------------------
% zbot = The depth to the bottom of the seismogenic crust (km)
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

vert = xyz2gps(geom.xyzm,ellipsoid);
zbot =-min(vert(:,3));