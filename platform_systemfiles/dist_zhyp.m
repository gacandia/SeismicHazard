function[H]=dist_zhyp(r0,rf,ellipsoid)
% Hypocentral Depth
if isempty(ellipsoid.Code)
    H     = r0(:,3)-rf(:,3);
else
    gps0  = xyz2gps(r0,ellipsoid);
    gpsf  = xyz2gps(rf,ellipsoid);
    H     = gps0(:,3)-gpsf(:,3);
end



