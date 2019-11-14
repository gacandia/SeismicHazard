function [rho] = BJ_spectral_2008(T1, T2,~)

% Baker & Jayaram 2008
% Created by Jack Baker, 6/25/2007
% Compute the correlation of epsilons for the NGA ground motion models
%
% The function is strictly empirical, fitted over the range the range 0.01s <= T1, T2 <= 10s
%
% Documentation is provided in the following document:
% Baker, J.W. and Jayaram, N. (2008), "Correlation of spectral acceleration values from NGA ground
% motion models," Earthquake Spectra, 24 (1), 299-317.
%

T1(and(T1>=0,T1<0.01))=0.01;
T2(and(T2>=0,T2<0.01))=0.01;

T_min = min(T1, T2); 
T_max = max(T1, T2); 
rho    = zeros(size(T_min));
for i=1:numel(T_min)
    rho(i)=corrModel(T_min(i), T_max(i));
end
rho(T_min<0.01) = nan;
rho(T_max>10)   = nan;

function rho=corrModel(T_min,T_max)

C1 = (1-cos(pi/2 - log(T_max/max(T_min, 0.109)) * 0.366 ));
if T_max < 0.2
    C2 = 1 - 0.105*(1 - 1./(1+exp(100*T_max-5)))*(T_max-T_min)/(T_max-0.0099);
end
if T_max < 0.109
    C3 = C2;
else
    C3 = C1;
end
C4 = C1 + 0.5 * (sqrt(C3) - C3) * (1 + cos(pi*(T_min)/(0.109)));

if T_max <= 0.109
    rho = C2;
elseif T_min > 0.109
    rho = C1;
elseif T_max < 0.2
    rho = min(C2, C4);
else
    rho = C4;
end

