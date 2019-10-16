function[lny,sigma,tau,sig]=Jaimes2006(To,M,rrup)

% Jaimes, M.A., Reinoso, E. y Ordaz, M. (2006). Comparison of methods to predict response spectra
% at instrumented sites given the magnitude and distance of an earthquake, Journal of Earthquake Engineering,
% 10(6), 887-902
%
% To        = spectral period
% M         = moment magnitude
% rrup      = closest distance to fault rupture
% h         = focal depth (km)
% mechanism ='interface'
% media     = 'rock' for specifically Mexico City

if  To<0 || To> 6
    lny   = nan(size(M));
    sigma = nan(size(M));
    tau   = nan(size(M));
    sig   = nan(size(M));
    %IM    = IM2str(To);
    %h=warndlg(sprintf('GMPE %s not available for %s',mfilename,IM{1}));
    %uiwait(h);
    return
end

To      = max(To,0.01); %PGA is associated to To=0.01; 
period  = [0.01 0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8 2.0 2.2 2.4 2.6 2.8 3.0 3.2 3.4 3.6 3.8 4.0 4.2 4.4 4.6 4.8 5.0 5.2 5.4 5.6 5.8 6.0];
T_lo    = max(period(period<=To));
T_hi    = min(period(period>=To));
index   = find(abs((period - T_lo)) < 1e-6); % Identify the period

if T_lo==T_hi
    [lny,sigma] = gmpe(index,M,rrup);
else
    [lny_lo,sigma_lo] = gmpe(index,  M,rrup);
    [lny_hi,sigma_hi] = gmpe(index+1,M,rrup);
    x          = log([T_lo;T_hi]);
    Y_sa       = [lny_lo,lny_hi]';
    Y_sigma    = [sigma_lo,sigma_hi]';
    lny        = interp1(x,Y_sa,log(To))';
    sigma      = interp1(x,Y_sigma,log(To))';
end

tau=0*sigma;
sig=sigma;

function [lny,sigma]=gmpe(index,M,rrup)
DATA = [5.6897 1.1178 -0.50 -0.0060
6.5911 0.8874 -0.50 -0.0067
6.3144 1.0139 -0.50 -0.0059
6.6483 1.1018 -0.50 -0.0065
6.8495 1.3343 -0.50 -0.0076
6.4316 1.3155 -0.50 -0.0064
6.7093 1.3152 -0.50 -0.0072
6.0035 1.2168 -0.50 -0.0050
6.0507 1.2437 -0.50 -0.0051
5.6822 1.3034 -0.50 -0.0046
5.7883 1.3993 -0.50 -0.0056
5.5195 1.6160 -0.50 -0.0058
5.1604 1.4749 -0.50 -0.0048
5.4283 1.6010 -0.50 -0.0061
5.0573 1.4965 -0.50 -0.0049
4.5972 1.4695 -0.50 -0.0039
4.4303 1.5104 -0.50 -0.0038
4.0981 1.5027 -0.50 -0.0031
3.7992 1.6018 -0.50 -0.0029
3.5164 1.7014 -0.50 -0.0029
3.2601 1.7098 -0.50 -0.0024
3.0349 1.6404 -0.50 -0.0020
2.9353 1.6219 -0.50 -0.0019
2.7737 1.5579 -0.50 -0.0016
2.6416 1.5223 -0.50 -0.0015
2.6246 1.5194 -0.50 -0.0018
2.4099 1.4851 -0.50 -0.0014
2.1372 1.4635 -0.50 -0.0008
2.0505 1.5243 -0.50 -0.0010
2.2973 1.6494 -0.50 -0.0022
2.6207 1.7533 -0.50 -0.0035];
C     = DATA(index,:);
lny   = C(1)+ C(2)*(M-6) + C(3)*log(rrup) + C(4)*rrup;
sigma = 0.17*ones(size(M));  % check with Miguel

% convert cm/s2 to g's
lny    = lny-log(980.66);

