function[vertices]=gps2xyz(vertices,ellip)

%GEODETIC2ECEF Transform geodetic to geocentric (ECEF) coordinates
if ~isempty(ellip.Code)

    lat = vertices(:,1)*pi/180;
    lon = vertices(:,2)*pi/180;
    h   = vertices(:,3);
    
    % Ellipsoid has the form: [semimajor_axis, eccentricity].
    a  = ellip.SemimajorAxis;
    f  = ellip.Flattening;
    
    % Inputs phi and lambda are in radians.
    inDegrees = false;
    [rho, z] = map.geodesy.internal.geodetic2cylindrical(lat, h, a, f, inDegrees);
    [x, y]   = pol2cart(lon,rho);
    vertices = [x,y,z];
end

