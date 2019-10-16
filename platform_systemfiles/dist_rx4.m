function[rx]=dist_rx4(r0,rf,RW,RL,geom,ellipsoid)
%------------------------------------------------------------------------
% rx    = Horizontal distance from top of rupture measured perpendicular
%         to fault strike
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
y1      = rfc(:,2)-RW/2;
y2      = rfc(:,2)+RW/2;
z       = zeros(size(x1));
rx      = zeros(size(x1));
% corners of Rupture Area in local cartesian coordinates
corner1 = [x1,y1,z];
corner2 = [x2,y1,z];
corner3 = [x2,y2,z];
corner4 = [x1,y2,z];

% corners of Rupture Area in cartesian coordinates
corner1XYZ = bsxfun(@plus,corner1*rot',pmean);
corner2XYZ = bsxfun(@plus,corner2*rot',pmean);
corner3XYZ = bsxfun(@plus,corner3*rot',pmean);
corner4XYZ = bsxfun(@plus,corner4*rot',pmean);

% corners of Rupture Area in WGS84 coordinates
cornerGPS(:,:,1) = xyz2gps(corner1XYZ,ellipsoid);
cornerGPS(:,:,2) = xyz2gps(corner2XYZ,ellipsoid);
cornerGPS(:,:,3) = xyz2gps(corner3XYZ,ellipsoid);
cornerGPS(:,:,4) = xyz2gps(corner4XYZ,ellipsoid);

for i=1:length(x1)
   zcord =permute(cornerGPS(i,1:3,:),[3 2 1]);
   cornerGPSi = sortrows(zcord,-3);
   cornersurf = cornerGPSi*diag([1,1,0]);
   x  = gps2xyz(cornersurf,ellipsoid);
   dx = x(2,:)-x(1,:);
   num = fastcross(dx,bsxfun(@minus,x(1,:),r0));
   d1  = sum(num.^2,2).^0.5./sum(dx.^2,2).^0.5;
   rx(i)   = d1;
   
   if abs(abs(geom.dip)-90)>1e-2
       dx = x(3,:)-x(4,:);
       num = fastcross(dx,bsxfun(@minus,x(3,:),r0));
       d2  = sum(num.^2,2).^0.5./sum(dx.^2,2).^0.5;
       
       dx = x(1,:)-x(3,:);
       num = fastcross(dx,bsxfun(@minus,x(3,:),x(2,:)));
       L1  = sum(num.^2,2).^0.5./sum(dx.^2,2).^0.5;
       
       dx = x(1,:)-x(4,:);
       num = fastcross(dx,bsxfun(@minus,x(4,:),x(2,:)));
       L2  = sum(num.^2,2).^0.5./sum(dx.^2,2).^0.5;
       L   = min(L1,L2);

       DISC = [and(d1>d2,d1>L),and(d1<=L,d2<=L),and(d2>d1,d2>L)]*[1;2;3];
       if DISC>2
           rx(i)=-rx(i);
       end
   end
end


