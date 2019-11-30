function [dip] = createFit2Dplane(vertices,ellip)

x = vertices(:,1);
y = vertices(:,2);
z = vertices(:,3);

[xData, yData, zData] = prepareSurfaceData( x, y, z );
ft = fittype( 'poly11' );

x2 = [xData(1) xData(1)+0.1 xData(1)+0.1 xData(1)]';
y2 = [yData(1) yData(1) yData(1)+0.1 yData(1)+0.1]';


% test for verticality
p1 = [x,y,z];
p2 = p1([end,1:end-1],:);
p3 = p2([end,1:end-1],:);
DISC = fastcross(p3-p1,p2-p1);
if any(abs(DISC(:,3))<1e-6)
    dip=90;
    return
end

fitresult = fit( [xData, yData], zData, ft );
xyz = [x2,y2,fitresult(x2,y2)];
xyz0 = xyz*diag([1 1 0]);

xyz  = gps2xyz(xyz ,ellip);
xyz0 = gps2xyz(xyz0,ellip);

v1   = fastcross(xyz(3,:)-xyz(1,:),xyz(4,:)-xyz(2,:));
v0   = fastcross(xyz0(3,:)-xyz0(1,:),xyz0(4,:)-xyz0(2,:));
dip  = acosd(v1*v0'/(norm(v1)*norm(v0)));

% round to 4 decimal degrees
dip = abs(round(dip*10000)/10000);

