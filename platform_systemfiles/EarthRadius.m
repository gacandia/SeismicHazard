function[R]=EarthRadius(lat,ellip)

a  = ellip.SemimajorAxis/1000;
b  = ellip.SemiminorAxis/1000;
R  = ((a^4*cosd(lat).^2 + b^4*sind(lat).^2)./(a^2*cosd(lat).^2 + b^2*sind(lat).^2)).^(1/2)*1000;
