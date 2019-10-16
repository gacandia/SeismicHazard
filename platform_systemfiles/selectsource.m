function[ind]=selectsource(MaxDistance,xyz,source,ellipsoid)
% SELECT SOURCES THAT ARE CLOSER TO sys.MaxDistance KM FROM THE SITE with
% coordinates xyz

% Analysis Parameters
Nsources = length(source);
ind     = true(1,Nsources);
for i=1:Nsources
    vert = gps2xyz(source(i).vertices,ellipsoid);
    delta = bsxfun(@minus,vert,xyz);
    dist = min(sqrt(delta.^2*[1;1;1]));
    ind(i)=(dist<MaxDistance);
end


