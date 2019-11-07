function[ztor]=dist_ztor4(~,rf,RW,RL,geom,ellipsoid)
%------------------------------------------------------------------------
% ztor = Depth to top of coseismic rupture (km)
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
x       = rfc(:,1)-RL/2;
y1      = rfc(:,2)-RW/2;
y2      = rfc(:,2)+RW/2;
z       = zeros(size(x));

corner31 = [x,y1,z];
corner32 = [x,y2,z];

% corners of Rupture Area in cartesian coordinates
corner31XYZ = bsxfun(@plus,corner31*rot',pmean);
corner32XYZ = bsxfun(@plus,corner32*rot',pmean);

% corners of Rupture Area in WGS84 coordinates
corner31GPS = abs(xyz2gps(corner31XYZ,ellipsoid));
corner32GPS = abs(xyz2gps(corner32XYZ,ellipsoid));

ztor  =min(corner31GPS(:,3),corner32GPS(:,3));

% pmean   = geom.pmean;
% rot     = geom.rot;
% rfc     = bsxfun(@minus,rf,pmean)*rot;
% x2      = rfc(:,1)+RL/2;
% y2      = rfc(:,2)+RW/2;
% z       = zeros(size(x2));
% 
% % corners of Rupture Area in local cartesian coordinates
% corner3 = [x2,y2,z];
% 
% % corners of Rupture Area in cartesian coordinates
% corner3XYZ = bsxfun(@plus,corner3*rot',pmean);
% 
% % corners of Rupture Area in WGS84 coordinates
% corner3GPS = xyz2gps(corner3XYZ,ellipsoid);
% 
% ztor  =-corner3GPS(:,3);