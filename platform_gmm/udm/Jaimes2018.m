function[lny,sigma,tau,sig]=Jaimes2018(To,M,rrup)

%Jaimes, M.A. 2018 - Ground-Motion Prediction Model from Inslab Mexican Earthquakes
% at rock sites
%
% To        = spectral period
% M         = moment magnitude
% rrup      = closest distance to fault rupture

if  To<0 || To> 10
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
period  = [0.01 0.02 0.06 0.08 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 2 3 4 5 10];
T_lo    = max(period(period<=To));
T_hi    = min(period(period>=To));
index   = find(abs((period - T_lo)) < 1e-6); % Identify the period

if T_lo==T_hi
    [lny,sigma,tau,sig] = gmpe(index,M,rrup);
else
    [lny_lo,sigma_lo,tau_lo] = gmpe(index,  M,rrup);
    [lny_hi,sigma_hi,tau_hi] = gmpe(index+1,M,rrup);
    x          = log([T_lo;T_hi]);
    Y_sa       = [lny_lo,lny_hi]';
    Y_sigma    = [sigma_lo,sigma_hi]';
    Y_tau      = [tau_lo,tau_hi]';
    lny        = interp1(x,Y_sa,log(To))';
    sigma      = interp1(x,Y_sigma,log(To))';
    tau        = interp1(x,Y_tau,log(To))';
    sig        = sqrt(sigma.^2-tau.^2);
end


function [lny,sigma,tau,sig]=gmpe(index,M,rrup)
DATA = [1.0702	  1.2658	-1.00	-0.0086	0.42	0.61	0.74
    1.2210	  1.2594	-1.00	-0.0087	0.41	0.62	0.74
    2.1452	  1.1845	-1.00	-0.0089	0.45	0.69	0.83
    2.3644	  1.1812	-1.00	-0.0089	0.45	0.69	0.82
    2.4049	  1.1917	-1.00	-0.0087	0.44	0.70	0.83
    1.3310	  1.3330	-1.00	-0.0083	0.48	0.59	0.76
    -0.0133	  1.4870	-1.00	-0.0077	0.42	0.55	0.69
    -0.7463	  1.5310	-1.00	-0.0065	0.38	0.57	0.68
    -1.4930	  1.5916	-1.00	-0.0058	0.30	0.57	0.64
    -1.8350	  1.5927	-1.00	-0.0051	0.31	0.58	0.66
    -2.1528	  1.6018	-1.00	-0.0046	0.29	0.59	0.66
    -2.6658	  1.6599	-1.00	-0.0046	0.28	0.58	0.64
    -3.1984	  1.7154	-1.00	-0.0042	0.28	0.58	0.64
    -3.5840	  1.7444	-1.00	-0.0039	0.26	0.58	0.63
    -5.9326	  1.9249	-1.00	-0.0031	0.21	0.55	0.58
    -7.2277	  2.0056	-1.00	-0.0024	0.26	0.50	0.56
    -8.3958	  2.0991	-1.00	-0.0020	0.23	0.49	0.54
    -9.3404	  2.1778	-1.00	-0.0019	0.21	0.48	0.53
    -11.3813	2.2878	-1.00	-0.0026	0.25	0.50	0.56];

C       = DATA(index,:);
Dm      = 0.00750*10.^(0.507*M);
R       = (rrup.^2+Dm.^2).^0.5;
lny     = C(1)+ C(2)*M + C(3)*log(R) + C(4)*R;

% convert from cm/s2 to g's
lny = lny- log(980.66);


% sig     = Coeff2(5)*ones(size(M));
% tau     = Coeff2(6)*ones(size(M));
% miguel, check this lines, I think the lives above had phi and sig
% switched (tau's should be < than sig's)
tau     = C(5)*ones(size(M));
sig     = C(6)*ones(size(M));
sigma   = sqrt(sig.^2+tau.^2);
