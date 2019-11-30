function [Strike,Dip]=geomStrikeDip(Vertices,ellipsoid)

Strike = [];
Dip    = [];
Code   = ellipsoid.Code;

% Ellipsoidal Earth
if size(Vertices,1) == 4 && ~isempty(Code)
    lat1   = Vertices(1,1);
    lat2   = Vertices(4,1);
    dL     = Vertices(4,2)-Vertices(1,2);
    Strike = atan2d((sind(dL)*cosd(lat2)),(cosd(lat1)*sind(lat2)-sind(lat1)*cosd(lat2)*cosd(dL)));
    
    lat1   = Vertices(1,1); z1 = Vertices(1,3);
    lat2   = Vertices(2,1); z2 = Vertices(2,3);
    R      = EarthRadius([lat1,lat2],ellipsoid)*[0.5;0.5];
    dL     = Vertices(2,2)-Vertices(1,2);
    Dip    = atan2d((z1-z2),R*dL*pi()/180);
    if Dip>90
        Dip = Dip-180;
    end
end


% Flat Earth
if size(Vertices,1) == 4 && isempty(Code)
    StrikeVec = Vertices(4,:)-Vertices(1,:);
    %dot(StrikeVec,n) = StrikeVec(1);
    cosS   = StrikeVec(1)/norm(StrikeVec);
    Strike = acosd(cosS);
    
    DipVec = Vertices(2,:)-Vertices(1,:);
    SDip   = [DipVec(1:2),0];
    if norm(SDip)==0
        Dip    = 90;
    else
        cosD   = dot(DipVec,SDip)/(norm(DipVec)*norm(SDip));
        Dip    = acosd(cosD);
    end
end


Dip=abs(Dip);
