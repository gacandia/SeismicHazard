function [rho] = JC_spectral_2018(T1, T2,~)

% Created by M. Jaimes & G Candia, 19/07/2018
% Compute the correlation of epsilons for the NGA ground motion models
%
% The function is strictly empirical, fitted over the range the range 0.01s <= T1, T2 <= 10s
%
% Documentation is provided in the following document:
% INPUT
%
%   T1, T2      = The two periods of interest. The periods may be equal,
%                 and there is no restriction on which one is larger.
%   M           = Moment Magnitude
%
% OUTPUT
%
%   rho         = The predicted correlation coefficient

T1(and(T1>=0,T1<0.01))=0.01;
T2(and(T2>=0,T2<0.01))=0.01;

T_min = min(T1, T2); 
T_max = max(T1, T2); 
rho    = zeros(size(T_min));
for i=1:numel(T_min)
    rho(i)=corrModel(T_min(i), T_max(i));
end

rho(T_min<0.01)  = nan;
rho(T_max>5)    = nan;

function rho=corrModel(T_min,T_max)

a=0.084;
b=0.214;
c=0.108;
d=0.418;

C1 = (1-cos(pi/2 - log(T_max/max(T_min, a)) * b ));

if T_max < 0.2
    C2 = 1 - c*(1 - 1./(1+exp(100*T_max-5)))*(T_max-T_min)/(T_max-0.0099);
end

if T_max < a
    C3 = C2;
else
    C3 = C1;
end
C4 = C1 + d * (sqrt(C3) - C3) * (1 + cos(pi*(T_min)/a));

if T_max <= a
    rho = C2;
elseif T_min > a
    rho = C1;
elseif T_max < 0.2
    rho = min(C2, C4);
else
    rho = C4;
end
