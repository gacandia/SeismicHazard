function [rho] = BC_spectral_2006(T1, T2, param)

% Baker& Cornel 2006
% Created by Jack Baker, 2/2/05
% Compute the correlation of epsilons at two different periods. The
% correlation can be for epsilons in the same axis, or perpendicular axes.
%
% The function is strictly empirical, and should not be extrapolated beyond
% the range 0.05s <= T1, T2 <= 5s
%
% Documentation of this model is provided in the following:
%
% Baker J.W. and Cornell C.A. (2006). "Correlation of Response Spectral Values
% for Multi-Component Ground Motions," Bulletin of the Seismological Society of
% America, 96 (1), 215-227.
%
%
% INPUT
%
%   T1, T2      = The two periods of interest. The periods may be equal,
%                 and there is no limit on one being larger than the other.
%   opp         = 0 for correlation in the same axis (default)
%               = 1 for correlation on perpendicular axes
%
% OUTPUT
%
%   rho         = The predicted correlation coefficient

opp    = param.opp;
T_min  = min(T1, T2); 
T_max  = max(T1, T2); 
rho    = zeros(size(T_min));
for i=1:numel(T_min)
    rho(i)=corrModel(T_min(i), T_max(i),opp);
end
rho(T_min<0.05)=nan;
rho(T_max>5)  =nan;

function rho=corrModel(T_min,T_max,opp)

X = 1 - log(T_max/T_min)*(0.32 - 0.133*exp( -(log(T_max)+1.51)^2 -5*(log(T_min)+2.59)^2));
D = 9 - log(T_max/T_min^4);
rho = max([X, X-0.17*D, 0.15]);

if opp==1
    reduction = 0.78* sqrt( (1-0.05*log(T_min)) * (1-0.05*log(T_max)));
    rho = rho * reduction;
end