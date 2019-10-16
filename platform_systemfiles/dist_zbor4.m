function[zbor]=dist_zbor4(~,rf,RW,RL,geom,ellipsoid)
%------------------------------------------------------------------------
% Zbor = Depth to the bottom of the rupture plane (km)
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

pmean   = geom.pmean;
rot     = geom.rot;
rfc     = bsxfun(@minus,rf,pmean)*rot;
x1      = rfc(:,1)-RL/2;
y1      = rfc(:,2)-RW/2;
z       = zeros(size(x1));

% corners of Rupture Area in local cartesian coordinates
corner1 = [x1,y1,z];

% corners of Rupture Area in cartesian coordinates
corner1XYZ = bsxfun(@plus,corner1*rot',pmean);

% corners of Rupture Area in WGS84 coordinates
corner1GPS = xyz2gps(corner1XYZ,ellipsoid);

zbor  =-corner1GPS(:,3);
