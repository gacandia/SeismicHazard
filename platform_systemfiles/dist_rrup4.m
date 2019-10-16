function[rrup,x]=dist_rrup4(r0,rf,RW,RL,geom,ellipsoid)
%------------------------------------------------------------------------
% Rrup = Closest distance to the rupture plane
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
pmean = geom.pmean;
n     = geom.normal(1,:);
rot   = geom.rot;
r0c    = (r0-pmean)*rot;
rfc    = bsxfun(@minus,rf,pmean)*rot;

Nt    = size(rf,1);
rrup  = zeros(Nt,1);
%% distance from site perpendicular to the plane
va      = bsxfun(@minus,r0,rf);
proj    = sum(bsxfun(@times,va,n),2);
vb      = bsxfun(@times,n,proj);
vc      = va-vb;
dnormal = abs(proj);
dplano  = sqrt(sum(vc.^2,2));

%% rupture radius
a = RL/2;
b = RW/2;
vcrot   = vc*rot;
vcabs   = abs(vcrot);
theta   = atan2(vcabs(:,2),vcabs(:,1));
thetac  = atan(b./a);
IND     = (theta<thetac);
rupRadius = 0*theta;
Ra      = a./cos(theta); rupRadius(IND)  = Ra(IND);
Rb      = b./sin(theta); rupRadius(~IND) = Rb(~IND);

%% CASE 1
IND1 = (dplano<rupRadius);
rrup(IND1)=dnormal(IND1);

%% CASE 2
x1    = rfc(:,1)-RL/2;
x2    = rfc(:,1)+RL/2;
y1    = rfc(:,2)-RW/2;
y2    = rfc(:,2)+RW/2;
z     = zeros(size(x1));

rA     = [x1,y1,z];
lambda = r0c(1)-rA(:,1);
lambda = max(lambda,0);
lambda = min(lambda,RL);
O1 = rA+[lambda,z,z];

rA = [x2,y1,z];
lambda = r0c(2)-rA(:,2);
lambda = max(lambda,0);
lambda = min(lambda,RW);
O2 = rA+[z,lambda,z];

rA = [x2,y2,z];
lambda =-r0c(1)+rA(:,1);
lambda = max(lambda,0);
lambda = min(lambda,RL);
O3 = rA-[lambda,z,z];

rA = [x1,y2,z];
lambda =-r0c(2)+rA(:,2);
lambda = max(lambda,0);
lambda = min(lambda,RW);
O4 = rA-[z,lambda,z];

pO1 = bsxfun(@minus,O1,r0c).^2*[1;1;1];
pO2 = bsxfun(@minus,O2,r0c).^2*[1;1;1];
pO3 = bsxfun(@minus,O3,r0c).^2*[1;1;1];
pO4 = bsxfun(@minus,O4,r0c).^2*[1;1;1];
[~,ind]=min([pO1,pO2,pO3,pO4],[],2);
ind = [ind,ind,ind];
x = O1.*(ind==1)+O2.*(ind==2)+O3.*(ind==3)+O4.*(ind==4);
drup = bsxfun(@minus,x,r0c);
drup = sqrt(sum(drup.^2,2));
rrup(~IND1)= drup(~IND1);

% GPS location of closes point to site in the RA proyection 
x = xyz2gps(bsxfun(@plus,pmean,x*rot'),ellipsoid);


