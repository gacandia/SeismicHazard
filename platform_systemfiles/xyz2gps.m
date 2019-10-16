function[vertices]=xyz2gps(xyz,ellip)

if isempty(ellip.Code)
    vertices=xyz;
else
    x  = xyz(:,1);
    y  = xyz(:,2);
    z  = xyz(:,3);
    a  = ellip.SemimajorAxis;
    f  = ellip.Flattening;
    
    % Return phi and lambda in radians.
    inDegrees = false;
    [lon, rho] = cart2pol(x,y);
    [lat, h] = map.geodesy.internal.cylindrical2geodetic(rho, z, a, f, inDegrees);
    vertices = [lat*180/pi lon*180/pi h];
end