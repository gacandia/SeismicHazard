function[lny,sigma,tau,phi]=ContrerasBoroschek2012(To,M,rrup,h,media)

% Boroschek, R., & Contreras, V. (2012). Strong ground motion from the 
% 2010 Mw 8.8 Maule Chile earthquake and attenuation relations for Chilean
% subduction zone interface earthquakes. In International Symposium on 
% Engineering Lessons Learned from the 2011 Great East Japan Earthquake 
% (Vol. 1, pp. 1722-1733).
%
% To        = spectral period
% M         = moment magnitude
% rrup      = closest distance to fault rupture
% h         = focal depth (km)
% media     = 'rock','soil'

lny   = nan(size(M));
sigma = nan(size(M));
tau   = nan(size(M));
phi   = nan(size(M));

if  To<0 || To> 2
    return
end

To      = max(To,0.01); %PGA is associated to To=0.01;
period  = [0.01 0.04 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 1.1 1.2 1.3 1.4 1.5 2];
T_lo    = max(period(period<=To));
T_hi    = min(period(period>=To));
index   = find(abs((period - T_lo)) < 1e-6); % Identify the period

if T_lo==T_hi
    [log10y,sigma] = gmpe(index,M,rrup,h,media);
else
    [log10y_lo,sigma_lo] = gmpe(index,  M,rrup,h,media);
    [log10y_hi,sigma_hi] = gmpe(index+1,M,rrup,h,media);
    x          = log([T_lo;T_hi]);
    Y_sa       = [log10y_lo,log10y_hi]';
    Y_sigma    = [sigma_lo,sigma_hi]';
    log10y        = interp1(x,Y_sa,log(To))';
    sigma      = interp1(x,Y_sigma,log(To))';
end

% log base conversion
lny   = log10y * log(10);
sigma = sigma  * log(10);


function[log10y,sigma]=gmpe(index,M,rrup,h,media)

switch media
    case 'rock', Z=0;
    case 'soil', Z=1;
end

DATA = [-1.8559 0.2549 0.0111 -0.0013 0.3061 0.0734 0.3552 1.5149 -0.103 0.2137
    -1.7342 0.2567 0.0111 -0.0016 0.2865 0.0734 0.3552 1.5149 -0.103 0.2311
    -1.4240 0.2597 0.0081 -0.0019 0.2766 0.0734 0.3552 1.5149 -0.103 0.2557
    -1.0028 0.2375 0.0023 -0.0014 0.2699 0.0734 0.3552 1.5149 -0.103 0.2469
    -1.2836 0.2519 0.0044 -0.0009 0.2977 0.0734 0.3552 1.5149 -0.103 0.2434
    -1.4161 0.2568 0.0049 -0.0008 0.3150 0.0734 0.3552 1.5149 -0.103 0.2414
    -2.1228 0.3208 0.0094 -0.0008 0.2834 0.0734 0.3552 1.5149 -0.103 0.2272
    -2.7134 0.3668 0.0141 -0.0008 0.2824 0.0734 0.3552 1.5149 -0.103 0.2174
    -2.9001 0.3795 0.0152 -0.0009 0.2969 0.0734 0.3552 1.5149 -0.103 0.2221
    -3.0909 0.4005 0.0147 -0.0009 0.2834 0.0734 0.3552 1.5149 -0.103 0.2279
    -3.1439 0.3952 0.0163 -0.0010 0.2730 0.0734 0.3552 1.5149 -0.103 0.2260
    -3.3352 0.4013 0.0186 -0.0010 0.2839 0.0734 0.3552 1.5149 -0.103 0.2351
    -3.5092 0.4093 0.0202 -0.0011 0.2849 0.0734 0.3552 1.5149 -0.103 0.2379
    -3.5599 0.4079 0.0211 -0.0011 0.2700 0.0734 0.3552 1.5149 -0.103 0.2374
    -3.6365 0.4090 0.0218 -0.0010 0.2631 0.0734 0.3552 1.5149 -0.103 0.2429
    -3.7061 0.4096 0.0225 -0.0010 0.2555 0.0734 0.3552 1.5149 -0.103 0.2425
    -3.7750 0.4089 0.0228 -0.0010 0.2528 0.0734 0.3552 1.5149 -0.103 0.2459
    -3.9051 0.4079 0.0215 -0.0008 0.2057 0.0734 0.3552 1.5149 -0.103 0.2592];
    
C       = DATA(index,:);
delta   = C(6)*10.^(C(7)*M);
g       = C(8)+C(9)*M;
R       = sqrt(rrup.^2+delta.^2);
log10y  = C(1)+C(2)*M+C(3)*h+C(4)*R-g.*log10(R)+C(5)*Z;
sigma   = C(10);