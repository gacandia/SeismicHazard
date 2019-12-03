function[ry0]=dist_ry04(r0,rf,RW,RL,geom,~)
%------------------------------------------------------------------------
% ry0 = The horizontal distance off the end of the rupture measured 
%       parallel to strike (km)
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
x2      = rfc(:,1)+RL/2;
y2      = rfc(:,2)+RW/2;
z       = zeros(size(x1));
ry0     = zeros(size(x1));
r0c     = (r0-pmean)*rot;


% corners of Rupture Area in local cartesian coordinates
p3 = [x2,y2,z];
p4 = [x1,y2,z];

for i=1:length(z)
    if r0c(1)<x1(i)
        P1 = p4(i,:);
        P2 = p4(i,:);P2(1)=r0c(1);
        ry0(i) = sum((P1-P2).^2)^0.5;
    elseif r0c(1)>x2(i)
        P1 = p3(i,:);
        P2 = p3(i,:);P2(1)=r0c(1);
        ry0(i) = sum((P1-P2).^2)^0.5;
    end
end

