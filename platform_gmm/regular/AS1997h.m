function[lny,sigma,tau,phi] = AS1997h(To,M, rrup, media, mechanism, location, sigmatype)

% Abrahamson, N. A., & Silva, W. J. (1997). Empirical response 
% spectral attenuation relations for shallow crustal earthquakes. 
% Seismological research letters, 68(1), 94-127.

lny   = nan(size(M));
sigma = nan(size(M));
tau   = nan(size(M));
phi   = nan(size(M));

if To<0 || To> 5
    return
end

if To>=0
    To      = max(To,0.01); %PGA is associated to To=0.01;
end
period  = [0.01, 0.02, 0.03, 0.04, 0.05, 0.06, 0.075, 0.09, 0.1, 0.12, 0.15, 0.17, 0.2, 0.24, 0.3, 0.36, 0.4, 0.46, 0.5, 0.6, 0.75, 0.85, 1, 1.5, 2, 3, 4, 5]';
T_lo    = max(period(period<=To));
T_hi    = min(period(period>=To));
index   = find(abs((period - T_lo)) < 1e-6); % Identify the period

if T_lo==T_hi
    [lny,sigma] = gmpe(index,M, rrup, media, mechanism, location, sigmatype);
else
    [lny_lo,sigma_lo] = gmpe(index,  M, rrup, media, mechanism, location, sigmatype);
    [lny_hi,sigma_hi] = gmpe(index+1,M, rrup, media, mechanism, location, sigmatype);
    x          = log([T_lo;T_hi]);
    Y_sa       = [lny_lo,lny_hi]';
    Y_sigma    = [sigma_lo,sigma_hi]';
    lny        = interp1(x,Y_sa,log(To))';
    sigma      = interp1(x,Y_sigma,log(To))';
end

function[lny,sigma]=gmpe(index,M, rrup, media, mechanism, location, sig)

switch media
    case 'deepsoil', S=1;
    case 'rock',     S=0;
end

switch mechanism
    case 'reverse'         , F=1;
    case 'reverse/oblique' , F=0.5;
    otherwise
        F=0;
end

switch location
    case 'hangingwall', HW=1;
    case 'footwall'   , HW=0;
    otherwise         , HW=0;
end

switch sig
    case 'arbitrary', arb =1;
    case 'average'  , arb =0;
end


V = get_abrahamson_silva_constants(index);
R = sqrt(rrup.^2 + V.c4^2);

% compute the PGA term, if we need it
if S
    Vpga = get_abrahamson_silva_constants(1);
    lnPGA = f1(M, R, Vpga) + F*f3(M, Vpga) + HW*f4(M, R, Vpga);
    pga_rock = exp(lnPGA);
else
    pga_rock = 0;
end

lny   = f1(M, R, V) + F*f3(M, V) + HW*f4(M, R, V) + S*f5(pga_rock, V);
sigma = abrahamson_silva_sigma(index,M,V,arb);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    local functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [f_1] = f1(M, R, V)

f_m = V.a1 + V.a2 * (M - V.c1) + V.a12 * (8.5 - M).^ V.n + (V.a3 + V.a13 * (M - V.c1)).* log(R);
f_1 = V.a1 + V.a4 * (M - V.c1) + V.a12 * (8.5 - M).^ V.n + (V.a3 + V.a13 * (M - V.c1)).* log(R);
ind = (M <= V.c1);
f_1(ind)=f_m(ind);

function [f_3] = f3(M, V)

M   = min(max(M,5.8),V.c1);
f_3 = V.a5 + (V.a6 - V.a5) / (V.c1 - 5.8) * (M-5.8); % includes correction of error in the paper


function [f4] = f4(M, R, V)
% value of f_4
M = min(max(M,5.5),6.5);
f_HW_M = M - 5.5;

f_HW_R = R*0;
ind2 = and(R > 4,R<=8);
ind3 = and(R > 8,R<=18);
ind4 = and(R >18,R<=24);

f_HW_R(ind2) = V.a9 * (R(ind2)-4)/4;
f_HW_R(ind3) = V.a9;
f_HW_R(ind4) = V.a9 * (1- (R(ind4)-18)/7);
f4 = f_HW_M.*f_HW_R;

function [f5] = f5(pga_rock, V)
% value of f_5
f5 = V.a10 + V.a11 * log(pga_rock + V.c5);

function [contants] = get_abrahamson_silva_constants(index)

C = [5.6000  1.6400 -1.1450 0.6100  0.2600 0.3700 -0.4170 -0.2300  0.0000  0.700 0.135
5.6000  1.6400 -1.1450 0.6100  0.2600 0.3700 -0.4170 -0.2300  0.0000  0.700 0.135
5.6000  1.6900 -1.1450 0.6100  0.2600 0.3700 -0.4700 -0.2300  0.0143  0.700 0.135
5.6000  1.7800 -1.1450 0.6100  0.2600 0.3700 -0.5550 -0.2510  0.0245  0.705 0.135
5.6000  1.8700 -1.1450 0.6100  0.2600 0.3700 -0.6200 -0.2670  0.0280  0.713 0.135
5.6000  1.9400 -1.1450 0.6100  0.2600 0.3700 -0.6650 -0.2800  0.0300  0.720 0.135
5.5800  2.0370 -1.1450 0.6100  0.2600 0.3700 -0.6280 -0.2800  0.0300  0.728 0.135
5.5400  2.1000 -1.1450 0.6100  0.2600 0.3700 -0.6090 -0.2800  0.0300  0.735 0.135
5.5000  2.1600 -1.1450 0.6100  0.2600 0.3700 -0.5980 -0.2800  0.0280  0.739 0.135
5.3900  2.2720 -1.1450 0.6100  0.2600 0.3700 -0.5910 -0.2800  0.0180  0.746 0.135
5.2700  2.4070 -1.1450 0.6100  0.2600 0.3700 -0.5770 -0.2800  0.0050  0.754 0.135
5.2000  2.4300 -1.1350 0.6100  0.2600 0.3700 -0.5220 -0.2650 -0.0040  0.759 0.135
5.1000  2.4060 -1.1150 0.6100  0.2600 0.3700 -0.4450 -0.2450 -0.0138  0.765 0.135
4.9700  2.2930 -1.0790 0.6100  0.2320 0.3700 -0.3500 -0.2230 -0.0238  0.772 0.135
4.8000  2.1140 -1.0350 0.6100  0.1980 0.3700 -0.2190 -0.1950 -0.0360  0.780 0.135
4.6200  1.9550 -1.0050 0.6100  0.1700 0.3700 -0.1230 -0.1730 -0.0460  0.787 0.135
4.5200  1.8600 -0.9880 0.6100  0.1540 0.3700 -0.0650 -0.1600 -0.0518  0.791 0.135
4.3800  1.7170 -0.9650 0.5920  0.1320 0.3700  0.0200 -0.1360 -0.0594  0.796 0.132
4.3000  1.6150 -0.9520 0.5810  0.1190 0.3700  0.0850 -0.1210 -0.0635  0.799 0.130
4.1200  1.4280 -0.9220 0.5570  0.0910 0.3700  0.1940 -0.0890 -0.0740  0.806 0.127
3.9000  1.1600 -0.8850 0.5280  0.0570 0.3310  0.3200 -0.0500 -0.0862  0.814 0.123
3.8100  1.0200 -0.8650 0.5120  0.0380 0.3090  0.3700 -0.0280 -0.0927  0.819 0.121
3.7000  0.8280 -0.8380 0.4900  0.0130 0.2810  0.4230  0.0000 -0.1020  0.825 0.118
3.5500  0.2600 -0.7720 0.4380 -0.0490 0.2100  0.6000  0.0400 -0.1200  0.840 0.110
3.5000 -0.1500 -0.7250 0.4000 -0.0940 0.1600  0.6100  0.0400 -0.1400  0.851 0.105
3.5000 -0.6900 -0.7250 0.4000 -0.1560 0.0890  0.6300  0.0400 -0.1726  0.866 0.097
3.5000 -1.1300 -0.7250 0.4000 -0.2000 0.0390  0.6400  0.0400 -0.1956  0.877 0.092
3.5000 -1.4600 -0.7250 0.4000 -0.2000 0.0000  0.6640  0.0400 -0.2150  0.885 0.087];

Coef = C(index,:);

contants.c4 = Coef(1);
contants.a1 = Coef(2);
contants.a3 = Coef(3);
contants.a5 = Coef(4);
contants.a6 = Coef(5);
contants.a9 = Coef(6);
contants.a10 = Coef(7);
contants.a11 = Coef(8);
contants.a12 = Coef(9);
contants.b5 = Coef(10);
contants.b6 = Coef(11);
contants.a2 = 0.512;
contants.a4 = -0.144;
contants.a13 = 0.17;
contants.c1 = 6.4;
contants.c5 = 0.03;

contants.n = 2;


function [sigma] = abrahamson_silva_sigma(index,M,V,arb)
% calculate the sigma

M = min(max(M,5),7);
sigma = V.b5 - V.b6 * (M - 5);
period  = [0.01, 0.02, 0.03, 0.04, 0.05, 0.06, 0.075, 0.09, 0.1, 0.12, 0.15, 0.17, 0.2, 0.24, 0.3, 0.36, 0.4, 0.46, 0.5, 0.6, 0.75, 0.85, 1, 1.5, 2, 3, 4, 5]';
T = period(index);
if arb
    % inflate the sigma using a functional fit developed by Baker and Cornell (2006)
    sigma = sigma * sqrt(2/(1.78-0.039*log(T)));
end


