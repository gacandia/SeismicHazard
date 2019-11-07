function [rho] = GodaAtkinson_spectral_2009(T1, T2, ~)

% Goda, K. and Atkinson, G. M., 2009. Probabilistic characterization 
% of spatially correlated response spectra for earthquakes in Japan. 
% Bulletin of the Seismological Society of America, 99(5), 3003-3020.
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
for i=1:numel(T_min)
    rho(i)=corrModel(T_min(i), T_max(i));
end
rho(T_min<0.05)=nan;
rho(T_max>5)  =nan;

function rho=corrModel(Tmin,Tmax)
ITmin = (Tmin<0.25);
th1=1.374;
th2=5.586;
th3=0.728;
rho = 1/3*(1-cos(pi/2-(th1+th2*ITmin*(Tmin/Tmax)^th3*log10(Tmin/0.25))*log10(Tmax/Tmin)))+1/3*(1+cos(-1.5*log10(Tmax/Tmin)));

