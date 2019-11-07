function[rhyp]=dist_rhyp(r0,rf)
% Hypocentral Distance
nrf    = size(rf,1);
ON     = ones(nrf,1);
va     = r0(ON,:)-rf;
rhyp = sqrt(sum(va.^2,2));
% Focal Distance
return

