function[zhyp]=dist_zhyp4(r0,rf,~,~,~,ellipsoid)
%------------------------------------------------------------------------
% zhyp =  Hypocentral depth from the earthquake
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

if isempty(ellipsoid.Code)
    zhyp     = r0(:,3)-rf(:,3);
else
    gps0  = xyz2gps(r0,ellipsoid);
    gpsf  = xyz2gps(rf,ellipsoid);
    zhyp     = gps0(:,3)-gpsf(:,3);
end



