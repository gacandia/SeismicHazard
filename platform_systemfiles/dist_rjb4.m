function[rjb,x]=dist_rjb4(r0,rf,RW,RL,geom,ellipsoid)
%------------------------------------------------------------------------
% rjb   = Joyner-Boore distance, i.e., closest distance from site to
%         surface projection of rupture area
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
Nx      = size(x1,1);
z       = zeros(Nx,1);
x       = zeros(Nx,3);
rjb     = zeros(Nx,1);

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
corner1GPS = xyz2gps(corner1XYZ,ellipsoid);
corner2GPS = xyz2gps(corner2XYZ,ellipsoid);
corner3GPS = xyz2gps(corner3XYZ,ellipsoid);
corner4GPS = xyz2gps(corner4XYZ,ellipsoid);

% corners of Rupture Area Projection in WGS84 coordinates
project1GPS = corner1GPS(:,1:2);
project2GPS = corner2GPS(:,1:2);
project3GPS = corner3GPS(:,1:2);
project4GPS = corner4GPS(:,1:2);

r0xyz = xyz2gps(r0,ellipsoid);
r0xyz = r0xyz(1:2);

for i=1:Nx
    pv = [project1GPS(i,:)
        project2GPS(i,:)
        project3GPS(i,:)
        project4GPS(i,:)];
    [d,x_poly,y_poly] = p_turbo_dist(r0xyz(1),r0xyz(2), pv(:,1),pv(:,2));
    if d>0
        r1 = gps2xyz([x_poly,y_poly,0],ellipsoid);
        rjb(i)=sum((r0-r1).^2).^0.5;
    end
    x(i,1)=x_poly;
    x(i,2)=y_poly;
end


%%
% CornerGPS  = [corner1GPS(1,:);corner2GPS(1,:);corner3GPS(1,:);corner4GPS(1,:);corner1GPS(1,:)];
% ProjectGPS = [project1GPS(1,:);project2GPS(1,:);project3GPS(1,:);project4GPS(1,:);project1GPS(1,:)];
% r0GPS      = xyz2gps(r0,ellipsoid);
%
% figure,hold on
% vert = geom.vertices;
% plot3(vert([1:4,1],1),vert([1:4,1],2),vert([1:4,1],3),'b.-')
% plot3(CornerGPS(:,1),CornerGPS(:,2),CornerGPS(:,3),'r.-')
% plot3(ProjectGPS(:,1),ProjectGPS(:,2),ProjectGPS(:,3),'m.-')
% plot3(r0GPS(:,1),r0GPS(:,2),r0GPS(:,3),'ko','markerfacecolor','k')
% rfGPS = xyz2gps(rf,ellipsoid);
% plot3(rfGPS(1,1),rfGPS(1,2),rfGPS(1,3),'ko')
% %
% text(vert([1:4,1],1),vert([1:4,1],2),vert([1:4,1],3),{'1','2','3','4',''})
% text(CornerGPS(:,1),CornerGPS(:,2),CornerGPS(:,3),{'1','2','3','4',''})
% text(ProjectGPS(:,1),ProjectGPS(:,2),ProjectGPS(:,3),{'1','2','3','4',''})

%%
% CornerXYZ  = [corner1XYZ(1,:);corner2XYZ(1,:);corner3XYZ(1,:);corner4XYZ(1,:);corner1XYZ(1,:)];
% ProjectXYZ = [project1XYZ(1,:);project2XYZ(1,:);project3XYZ(1,:);project4XYZ(1,:);project1XYZ(1,:)];
% r0XYZ      = r0;
% vert = geom.vertices;
% vertXYZ    = gps2xyz(vert,ellipsoid);
% close all
% figure,hold on
% plot3(vertXYZ([1:4,1],1),vertXYZ([1:4,1],2),vertXYZ([1:4,1],3),'b.-')
% plot3(CornerXYZ(:,1),CornerXYZ(:,2),CornerXYZ(:,3),'r.-')
% plot3(ProjectXYZ(:,1),ProjectXYZ(:,2),ProjectXYZ(:,3),'m.-')
% plot3(r0XYZ(:,1),r0XYZ(:,2),r0XYZ(:,3),'ko','markerfacecolor','k')
%
% plot3(rfproj(1,1),rfproj(1,2),rfproj(1,3),'ko')
% text(vertXYZ([1:4,1],1),vertXYZ([1:4,1],2),vertXYZ([1:4,1],3),{'1','2','3','4',''})
% text(CornerXYZ(:,1),CornerXYZ(:,2),CornerXYZ(:,3),{'1','2','3','4',''})
% text(ProjectXYZ(:,1),ProjectXYZ(:,2),ProjectXYZ(:,3),{'1','2','3','4',''})
% axis equal tight
