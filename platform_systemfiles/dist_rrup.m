function[Rrup]=dist_rrup(r0,rf,rupArea,n)
% Rrup = Closest distance to the rupture plane
% M  = seismicity
% r0 = site location
% rf = focus location

%% no rupture plane
if isempty(n)
    drup = bsxfun(@minus,r0,rf);
    Rrup = sqrt(sum(drup.^2,2));
    return
end

Nt = size(rf,1);
%% distance from site perpendicular to the plane
va      = bsxfun(@minus,r0,rf);
proj    = dot(va,n,2); % distance perpendicular
vb      = bsxfun(@times,n,proj);
vc      = va-vb;
dnormal = abs(proj);
dplano  = sqrt(sum(vc.^2,2));
vcn     = bsxfun(@rdivide,vc,dplano);
%% rupture radius
rupRadius = sqrt(rupArea/pi);
Rrup      = zeros(Nt,1);

%% CASE 1
IND1 = (dplano<rupRadius);
Rrup(IND1)=dnormal(IND1);

%% CASE 2
rf2  = rf(~IND1,:);
if ~isempty(rf2)
    rR2  = rupRadius(~IND1);
    vcn2 = vcn(~IND1,:);
    x    = rf2 + bsxfun(@times,rR2,vcn2);
    drup = bsxfun(@minus,x,r0);
    drup = sqrt(sum(drup.^2,2));
    Rrup(~IND1)= drup;
end

return

