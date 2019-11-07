function [rho] = Cimellaro_2013(T1, T2, param)

% Cimellaro, G. P., 2013. Correlation in spectral accelerations
% for earthquakes in Europe. Earthquake Engineering & Structural
% Dynamics, 42(4), 623-633.
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

T_min  = min(T1, T2);
T_max  = max(T1, T2);
rho    = zeros(size(T_min));

switch param.direction
    case 'horizontal'
        A0=-0.0798;
        A1=0.1147;
        A2=0.0431;
        A3=-0.3502;
        A4=0.0153;
    case 'vertical'
        A0=-0.0815;
        A1=0.1422;
        A2=0.0677;
        A3=-0.2447;
        A4=0.0063;
end

for i=1:numel(T_min)
    rho(i)=corrModel(T_min(i), T_max(i),A0,A1,A2,A3,A4);
end
rho(T_min<0.05) = nan;
rho(T_max>2.5)  = nan;

function rho=corrModel(T_min,T_max,A0,A1,A2,A3,A4)

N   = A0+A2*log10(T_min)+A4*log10(T_max)^2;
D   = 1+A1*log10(T_max)+A3*log10(T_min)^2;
rho = 1-(N/D)*log(T_min/T_max);


