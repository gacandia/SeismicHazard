function [lny, sigma,tau,phi] = Campbell1997h(T,M, R, media, mechanism, D, sig)

% Campbell, K. W. (1997). Empirical near-source attenuation relationships
% for horizontal and vertical components of peak ground acceleration, peak
% ground velocity, and pseudo-absolute acceleration response spectra. 
% Seismological research letters, 68(1), 154-179.

lny   = nan(size(M));
sigma = nan(size(M));
tau   = nan(size(M));
phi   = nan(size(M));

if T<0.05 || T> 4
    return
end

switch media
    case 'hardrock', Soil=2;
    case 'softrock', Soil=1;
    case 'soil',     Soil=0;
end

switch mechanism
    case 'strike-slip'
        Fault_Type=0;
    otherwise %'reverse', 'thrust', 'reverse-oblique', and 'thrust-oblique'
        Fault_Type=1;
end

switch sig
    case 'arbitrary', arb =1;
    case 'average'  , arb =0;
end

% convert soil parameter
S_SR = 0;
S_HR = 0;
if(Soil == 1)
    S_SR = 1;
elseif(Soil == 2)
    S_HR = 1;
end

% Compute PGA
[Ah, sigma_lnAH] = get_PGA(M, R, Fault_Type, S_SR, S_HR);

% get coefficients
[c1, c2, c3, c4, c5, c6, c7, c8] = get_coefs(T);

% compute Sa (Equation 8)
[depth_term] = f_SA(D, c6, S_HR, S_SR);
lny = log(Ah) + c1 + c2*tanh(c3*(M-4.7)) + (c4+c5*M).*R + 0.5*c6*S_SR + c6*S_HR + c7*tanh(c8*D)*(1-S_HR) + depth_term;

% dispersion for geometric mean (Equation 10)
sigma = sqrt(sigma_lnAH.^2 + 0.27^2);
if (arb) % inflate sigma to reflect arbitrary component standard deviation
    sigma = sigma * sqrt(2/(1.78-0.039*log(T))); % using Baker's emperical ratio
end


function [Ah, sigma_lnAH] = get_PGA(M, R, F, S_SR, S_HR)

ln_Ah = -3.512 + 0.904*M - 1.328*log( sqrt(R.^2 + (.149*exp(0.647*M)).^2)) + (1.125-0.112*log(R)-0.0957*M)*F + (.44-.171*log(R))*S_SR + (.405-.222*log(R))*S_HR;
Ah = exp(ln_Ah);

sigma_lnAH = zeros(size(Ah));
ind1 =(Ah < 0.068);
ind2 =and(0.068<=Ah,Ah <= 0.21);
ind3 = Ah>0.21;

sigma_lnAH(ind1) = 0.55;
sigma_lnAH(ind2) = 0.173 - 0.14 * ln_Ah(ind2);
sigma_lnAH(ind3) = 0.39;

function [c1, c2, c3, c4, c5, c6, c7, c8] = get_coefs(To)

To = max(To,0.05);
T = [0.05, 0.075, 0.10, 0.15, 0.20, 0.30, 0.50, 0.75, 1.00, 1.50, 2.00, 3.00, 4.00]';
C = [0.05 0 0 -0.0011 0.000055 0.2 0 0
    0.27 0 0 -0.0024 0.000095 0.22 0 0
    0.48 0 0 -0.0024 0.000007 0.14 0 0
    0.72 0 0 -0.001 -0.00027 -0.02 0 0
    0.79 0 0 0.0011 -0.00053 -0.18 0 0
    0.77 0 0 0.0035 -0.00072 -0.4 0 0
    -0.28 0.74 0.66 0.0068 -0.001 -0.42 0.25 0.62
    -1.08 1.23 0.66 0.0077 -0.001 -0.44 0.37 0.62
    -1.79 1.59 0.66 0.0085 -0.001 -0.38 0.57 0.62
    -2.65 1.98 0.66 0.0094 -0.001 -0.32 0.72 0.62
    -3.28 2.23 0.66 0.01 -0.001 -0.36 0.83 0.62
    -4.07 2.39 0.66 0.0108 -0.001 -0.22 0.86 0.62
    -4.26 2.03 0.66 0.0112 -0.001 -0.3 1.05 0.62];

Coef = interp1(log(T),C,log(To),'pchip');
c1 = Coef(1);
c2 = Coef(2);
c3 = Coef(3);
c4 = Coef(4);
c5 = Coef(5);
c6 = Coef(6);
c7 = Coef(7);
c8 = Coef(8);

function [depth_term] = f_SA(D, c6, ~, S_SR)

depth_term = c6*(1-S_SR)*(1-D) + 0.5*c6*(1-D)*S_SR;
depth_term(D>=1)=0;
