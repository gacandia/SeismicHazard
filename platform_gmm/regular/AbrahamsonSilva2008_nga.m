function[lny,sigma,tau,phi] = AbrahamsonSilva2008_nga(T, M, Rrup, Rjb, Rx, Ztor, dip,W, Z10, Vs30,mechanism, event, Vs30type)

lny   = nan(size(M));
sigma = nan(size(M));
tau   = nan(size(M));
phi   = nan(size(M));

if  and(T<0 || T> 10,T~=-1)
    return
end

%% Process Input
    switch mechanism
        case 'strike-slip',     FRV = 0; FNM=0;
        case 'normal',          FRV = 0; FNM=1;
        case 'normal-oblique',  FRV = 0; FNM=1;
        case 'reverse',         FRV = 1; FNM=0;
        case 'reverse-oblique', FRV = 1; FNM=0;
        case 'thrust',          FRV = 1; FNM=0;
    end
    
    switch event
        case 'aftershock';FAS=1;
        case 'mainshock'; FAS=0;
        case 'foreshock'; FAS=0;
        case 'swarms';    FAS=0;
    end
    
    FHW = (Rx>0);
    
    switch Vs30type
        case 'measured', FVS30=0;
        case 'inferred', FVS30=1;
    end

%% Compute AS
Td         = min(10.^( -1.25 + 0.3*M ),10);
[SaTd,~    ,pga_rock,pga_sigmaB,pga_tauB] = AS_2008_nga_parallel(M, 1100, Td    , Rrup, Rjb, Rx, dip, Ztor, 0  , W, FRV, FNM, FAS, FHW, FVS30, 0*M ,1);
[Sa  ,sigma,~,~,~,tau,phi]= AS_2008_nga_parallel(M, Vs30, T*(M.^0), Rrup, Rjb, Rx, dip, Ztor, Z10, W, FRV, FNM, FAS, FHW, FVS30, SaTd,0,pga_rock,pga_sigmaB,pga_tauB);
lny = log(Sa);

function [Sa,sigma,pga_rock,pga_sigmaB,pga_tauB,tau,sig] = AS_2008_nga_parallel(M, Vs30, T, Rrup, Rjb, Rx, dip, Ztor, Z10, W, FRV, FNM, FAS, FHW, FVS30, SaTd,irock,pga_rock,pga_sigmaB,pga_tauB)

% for the given period T, get the index for the constants
period = [-1, 0, 0.01, 0.02, 0.03, 0.04, 0.05,   0.075,  0.1, 0.15,  0.2, 0.25,  0.3,  0.4,  0.5, 0.75,    1,  1.5,    2,    3,    4,    5,  7.5,   10];
Td     = min(10.^( -1.25 + 0.3*M ),10);

if nargin==17
    on     = ones(size(M));
    
    indice   = 2*on;
    cst_rock = get_abrahamson_silva_constants(indice,1100,FVS30);
    pga_rock = exp(calc_val(M, Rrup, Rjb, Rx, dip, Ztor, Z10, W, FRV, FNM, FAS, FHW, 0, 1100, cst_rock));
    
    indice   = 2*on;
    cst_rock = get_abrahamson_silva_constants(indice,Vs30,FVS30);
    [~, ~, ~, pga_sigmaB, pga_tauB] = abrahamson_silva_sigma(M, pga_rock, Vs30,0, 0, cst_rock);
end

nT=length(T);

T_low=nan(size(T));index_low=nan(size(T));
T_hi =nan(size(T));index_hi =nan(size(T));
for i=1:length(T)
    T_low(i) = max(period(period<=T(i)));
    T_hi(i)  = min(period(period>=T(i)));
    
    index_low(i) = find(abs((period - T_low(i))) < 0.00001); % Identify the period
    index_hi(i)  = find(abs((period - T_hi(i))) < 0.00001); % Identify the period
end

% Compute sa and sigma for T_low
V         = get_abrahamson_silva_constants(index_low,Vs30,FVS30);
ind       = or(period(index_low)'<=Td,SaTd==0);
sa_low    = exp(calc_val(M, Rrup, Rjb, Rx, dip, Ztor, Z10, W, FRV, FNM, FAS, FHW, pga_rock, Vs30, V) + (1-irock)* f_10(Z10, Vs30, V));
sa2       = exp(calc_val2(SaTd,Td, T_low, Z10, pga_rock, Vs30, V));
sa_low(ind==0)=sa2(ind==0);
[sigma_low,sig_low] = abrahamson_silva_sigma(M, pga_rock, Vs30, pga_sigmaB, pga_tauB, V);

% Compute sa and sigma for T_hi
V         = get_abrahamson_silva_constants(index_hi,Vs30,FVS30);
ind       = or(period(index_hi)'<=Td,SaTd==0);
sa_hi     = exp(calc_val(M, Rrup, Rjb, Rx, dip, Ztor, Z10, W, FRV, FNM, FAS, FHW, pga_rock, Vs30, V) + (1-irock)* f_10(Z10, Vs30, V));
sa2       = exp(calc_val2(SaTd,Td, T_hi, Z10, pga_rock, Vs30, V));
sa_hi(ind==0)=sa2(ind==0);
[sigma_hi,sig_hi]  = abrahamson_silva_sigma(M, pga_rock, Vs30, pga_sigmaB, pga_tauB, V);

x          = [log(T_low) log(T_hi)];
Y_sa       = [log(sa_low) log(sa_hi)];
Y_sigma    = [sigma_low sigma_hi];
Y_sig      = [sig_low sig_hi];
Sa         = nan(nT,1);
sigma      = nan(nT,1);
sig        = nan(nT,1);
for i=1:nT
    if or(T(i)==0,index_low(i)==index_hi(i))
        Sa(i)    = sa_low(i);
        sigma(i) = sigma_low(i);
        sig(i)   = sig_low(i);
    else
        Sa(i)    = exp(interp1(x(i,:),Y_sa(i,:),log(T(i))));
        sigma(i) = interp1(x(i,:),Y_sigma(i,:),log(T(i)));
        sig(i)   = interp1(x(i,:),Y_sig(i,:),log(T(i)));
    end
end
tau = sqrt(sigma.^2-sig.^2);

function [f1] = f_1(M, R, V)
f1  = V.a1 + ((M<V.c1).*V.a4+(M>=V.c1).*V.a5).* (M - V.c1) + V.a8 .* (8.5 - M).^2 + (V.a2 + V.a3 .* (M - V.c1)).* log(R);

function [f4] = f_4(Rjb, Rx, dip, Ztor, M, W, V)
Nt = length(M);
T1 = zeros(Nt,1);
T1(Rjb<30)=1-Rjb(Rjb<30)/30;

W1=W*cosd(dip);
if dip==90
    T2=ones(Nt,1);
else
    T2=ones(Nt,1);
    T2(Rx<=W1)=0.5+Rx(Rx<=W1)/(2*W1);
end

T3=Rx./Ztor;
T3(Rx>=Ztor)=1;

T4 = M-6;
T4(M<=6)=0;
T4(M>=7)=1;

% from the Errata for “AS NGA” model (http://peer.berkeley.edu/products/abrahamson-silva_nga_report_files/AS08_NGA_errata.pdf)
T5=1-(dip-30)/60;
T5(dip<30)=1;
f4 = (V.a14.*T1.*T2.*T3.*T4)*T5;

function [f5] = f_5(pga_rock, Vs30, V)
f51 = V.a10 .* log(V.Vs30s./V.lin) - V.b.*log(pga_rock+V.c) + V.b.*log(pga_rock+V.c.*((V.Vs30s./V.lin).^V.n));
f52 = (V.a10 + V.b.*V.n) .* log(V.Vs30s./V.lin);
f5  = f51.*(Vs30<V.lin)+f52.*(Vs30>=V.lin);

function [f6] = f_6(Ztor, V)
f6=V.a16.*Ztor/10;
f6(Ztor>=10)=V.a16(Ztor>=10);

function [f8] = f_8(Rrup, M, V)
T6=0.5*(6.5-M)+0.5;
T6(M<5.5)=1;
T6(M>6.5)=0.5;
f8=V.a18.*(Rrup-100).*T6;
f8(Rrup<100)=0;

function [f10] = f_10(Z10, Vs30, V)
% value of f_10
if Vs30<180
    Z10h=exp(6.745);
elseif Vs30<=500
    Z10h=exp(6.745-1.35*log(Vs30/180));
else
    Z10h=exp(5.394-4.48*log(Vs30/500));
end
a211=(V.a10+V.b.*V.n).*log(V.Vs30s./min(V.v1,1000));
a212=log((Z10+V.c2)./(Z10h+V.c2));

a21 = 0*a212;
for i=1:length(a21)
    if Vs30>=1000
        %a21(i)=0;
    elseif a211(i)+V.e2(i)*a212(i)<0
        a21(i)=-a211(i)/a212(i);
    else
        a21(i)=V.e2(i);
    end
end

f10=a21.*a212;
if Z10>=200
    f10=f10+V.a22.*log(Z10/200);
end

function [X] = calc_val(M, Rrup, Rjb, Rx, dip, Ztor, ~, W, FRV, FNM, FAS, FHW, pga_rock, Vs30, constants)
R = sqrt(Rrup.^2 + constants.c4.^2);
X = f_1(M, R, constants) +  constants.a12*FRV + constants.a13*FNM + constants.a15*FAS ...
    + f_5(pga_rock, Vs30, constants) + FHW.*f_4(Rjb, Rx, dip, Ztor, M, W, constants) + f_6(Ztor, constants) ...
    + f_8(Rrup, M, constants);
%         + f_8(Rrup, M, constants) + f_10(Z10, Vs30, constants);

function [X] = calc_val2(SaTd, Td, T, Z10, pga_rock, Vs30, constants)
X = log((SaTd).* (Td./ T).^2) - f_5(pga_rock, 1100, constants) + f_5(pga_rock, Vs30, constants) + f_10(Z10, Vs30, constants);

function [constants] = get_abrahamson_silva_constants(index,Vs30,FVS30)
% get relevant constants

% arrays with values by index
period = [      -1,       0,    0.01,    0.02,    0.03,    0.04,    0.05,   0.075,     0.1,    0.15,     0.2,    0.25,     0.3,     0.4,     0.5,    0.75,       1,     1.5,       2,       3,       4,       5,     7.5,      10];
lin    = [   400.0,  865.1,   865.1,   865.1,   907.8,   994.5,  1053.5,  1085.7,  1032.5,   877.6,   748.2,   654.3,   587.1,   503.0,   456.6,   410.5,   400.0,   400.0,   400.0,   400.0,   400.0,   400.0,   400.0,   400.0];
b      = [  -1.955, -1.186,  -1.186,  -1.219,  -1.273,  -1.308,  -1.346,  -1.471,  -1.624,  -1.931,  -2.188,  -2.381,  -2.518,  -2.657,  -2.669,  -2.401,  -1.955,  -1.025,  -0.299,     0.0,     0.0,     0.0,     0.0,     0.0];
a1     = [  5.7578,  0.804,   0.811,   0.855,   0.962,   1.037,   1.133,   1.375,   1.563,   1.716,   1.687,   1.646,   1.601,   1.511,   1.397,   1.137,   0.915,   0.510,   0.192,  -0.280,  -0.639,  -0.936,  -1.527,  -1.993];
a2     = [ -0.9046,-0.9679, -0.9679, -0.9774, -1.0024, -1.0289, -1.0508, -1.0810, -1.0833, -1.0357, -0.9700, -0.9202, -0.8974, -0.8677, -0.8475, -0.8206, -0.8088, -0.7995, -0.7960, -0.7960, -0.7960, -0.7960, -0.7960, -0.7960];
a8     = [   -0.12,-0.0372, -0.0372, -0.0372, -0.0372, -0.0315, -0.0271, -0.0191, -0.0166, -0.0254, -0.0396, -0.0539, -0.0656, -0.0807, -0.0924, -0.1137, -0.1289, -0.1534, -0.1708, -0.1954, -0.2128, -0.2263, -0.2509, -0.2683];
a10    = [  1.5390, 0.9445,  0.9445,  0.9834,  1.0471,  1.0884,  1.1333,  1.2808,  1.4613,  1.8071,  2.0773,  2.2794,  2.4201,  2.5510,  2.5395,  2.1493,  1.5705,  0.3991, -0.6072, -0.9600, -0.9600, -0.9208, -0.7700, -0.6630];
a12    = [  0.0800, 0.0000,  0.0000,  0.0000,  0.0000,  0.0000,  0.0000,  0.0000,  0.0000,  0.0181,  0.0309,  0.0409,  0.0491,  0.0619,  0.0719,  0.0800,  0.0800,  0.0800,  0.0800,  0.0800,  0.0800,  0.0800,  0.0800,  0.0800];
a13    = [ -0.0600,-0.0600, -0.0600, -0.0600, -0.0600, -0.0600, -0.0600, -0.0600, -0.0600, -0.0600, -0.0600, -0.0600, -0.0600, -0.0600, -0.0600, -0.0600, -0.0600, -0.0600, -0.0600, -0.0600, -0.0600, -0.0600, -0.0600, -0.0600];
                           
a14    = [  0.7000, 1.0800,  1.0800,  1.0800,  1.1331,  1.1708,  1.2000,  1.2000,  1.2000,  1.1683,  1.1274,  1.0956,  1.0697,  1.0288,  0.9971,  0.9395,  0.8985,  0.8409,  0.8000,  0.4793,  0.2518,  0.0754,  0.0000,  0.0000];
a15    = [ -0.3900,-0.3500, -0.3500, -0.3500, -0.3500, -0.3500, -0.3500, -0.3500, -0.3500, -0.3500, -0.3500, -0.3500, -0.3500, -0.3500, -0.3191, -0.2629, -0.2230, -0.1668, -0.1270, -0.0708, -0.0309,  0.0000,  0.0000,  0.0000];
a16    = [  0.6300, 0.9000,  0.9000,  0.9000,  0.9000,  0.9000,  0.9000,  0.9000,  0.9000,  0.9000,  0.9000,  0.9000,  0.9000,  0.8423,  0.7458,  0.5704,  0.4460,  0.2707,  0.1463, -0.0291, -0.1535, -0.2500, -0.2500, -0.2500];
a18    = [  0.0000,-0.0067, -0.0067, -0.0067, -0.0067, -0.0067, -0.0076, -0.0093, -0.0093, -0.0093, -0.0083, -0.0069, -0.0057, -0.0039, -0.0025,  0.0000,  0.0000,  0.0000,  0.0000,  0.0000,  0.0000,  0.0000,  0.0000,  0.0000];
                           
s1e    = [   0.590,  0.590,   0.590,   0.590,   0.605,   0.615,   0.623,   0.630,   0.630,   0.630,   0.630,   0.630,   0.630,   0.630,   0.630,   0.630,   0.630,   0.615,   0.604,   0.589,   0.578,   0.570,   0.611,   0.640];
s2e    = [   0.470,  0.470,   0.470,   0.470,   0.478,   0.483,   0.488,   0.495,   0.501,   0.509,   0.514,   0.518,   0.522,   0.527,   0.532,   0.539,   0.545,   0.552,   0.558,   0.565,   0.570,   0.587,   0.618,   0.640];
s1m    = [   0.576,  0.576,   0.576,   0.576,   0.591,   0.602,   0.610,   0.617,   0.617,   0.616,   0.614,   0.612,   0.611,   0.608,   0.606,   0.602,   0.594,   0.566,   0.544,   0.527,   0.515,   0.510,   0.572,   0.612];
s2m    = [   0.453,  0.453,   0.453,   0.453,   0.461,   0.466,   0.471,   0.479,   0.485,   0.491,   0.495,   0.497,   0.499,   0.501,   0.504,   0.506,   0.503,   0.497,   0.491,   0.500,   0.505,   0.529,   0.579,   0.612];
s3     = [   0.420,  0.470,   0.420,   0.420,   0.462,   0.492,   0.515,   0.550,   0.550,   0.550,   0.520,   0.497,   0.479,   0.449,   0.426,   0.385,   0.350,   0.350,   0.350,   0.350,   0.350,   0.350,   0.350,   0.350];
s4     = [   0.300,  0.300,   0.300,   0.300,   0.305,   0.309,   0.312,   0.317,   0.321,   0.326,   0.329,   0.332,   0.335,   0.338,   0.341,   0.346,   0.350,   0.350,   0.350,   0.350,   0.350,   0.350,   0.350,   0.350];
ro     = [   0.740,  1.000,   1.000,   1.000,   0.991,   0.982,   0.973,   0.952,   0.929,   0.896,   0.874,   0.856,   0.841,   0.818,   0.783,   0.680,   0.607,   0.504,   0.431,   0.328,   0.255,   0.200,   0.200,   0.200];

c1=6.75;
c4=4.5;
a3=0.265;
a4=-0.231;
a5=-0.398;
n=1.18;
c=1.88;
c2=50;

on               = index.^0;
constants.period = period(index)';
constants.lin    = lin(index)';
constants.a1     = a1(index)';
constants.a2     = a2(index)';
constants.a3     = a3*on;
constants.a4     = a4*on;
constants.a5     = a5*on;
constants.a8     = a8(index)';
constants.a10    = a10(index)';
constants.a12    = a12(index)';
constants.a13    = a13(index)';
constants.a14    = a14(index)';
constants.a15    = a15(index)';
constants.a16    = a16(index)';
constants.a18    = a18(index)';
constants.b      = b(index)';
constants.c      = c*on;
constants.c1     = c1*on;
constants.c2     = c2*on;
constants.c4     = c4*on;
constants.n      = n*on;

if FVS30==1
    constants.s1  = s1e(index)';
    constants.s2  = s2e(index)';
else
    constants.s1  = s1m(index)';
    constants.s2  = s2m(index)';
end
constants.s3     = s3(index)';
constants.s4     = s4(index)';
constants.ro     = ro(index)';

T=period(index);
constants.v1=nan*index;
constants.e2=nan*index;
constants.a22=nan*index;
for i=1:length(T)
    Ti = T(i);
    if index(i)==1
        constants.v1(i) = 862;
    elseif Ti<=0.5
        constants.v1(i) = 1500;
    elseif Ti<=1
        constants.v1(i) = exp(8.0-0.795*log(Ti/0.21));
    elseif Ti<2
        constants.v1(i) = exp(6.76-0.297*log(Ti));
    else
        constants.v1(i) = 700;
    end
    
    if Ti<0.35 || Vs30>1000
        constants.e2(i)=0;
    elseif Ti<=2
        constants.e2(i)=-0.25*log(Vs30/1000)*log(Ti/0.35);
    else
        constants.e2(i)=-0.25*log(Vs30/1000)*log(2/0.35);
    end
    if Ti<2
        constants.a22(i)=0;
    else
        constants.a22(i)=0.0625*(Ti-2);
    end
end
constants.Vs30s=min(Vs30,constants.v1);

function [sigma, sig, tau, sigmaB, tauB] = abrahamson_silva_sigma(M, pga_rock, Vs30, pga_sigmaB, pga_tauB, V)
% calculate the sigma

% use the published coefficients for the geometric mean
on = M.^0;
sigma0 = V.s1.*(M<5)+(V.s1 + (V.s2-V.s1)/2 .*(M-5)).*and(M>=5,M<=7)+V.s2.*(M>7);

sigmaAMP=0.3;
sigmaB=sqrt(sigma0.^2-sigmaAMP^2);
tau0 = V.s3.*(M<5)+(V.s3 + (V.s4-V.s3)/2 .* (M-5)).*and(M>=5,M<=7)+V.s4.*(M>7);
tauB=tau0;

term11 = 0*on;
term12 = V.b .* pga_rock .* ( (-1./(pga_rock+V.c)) + (1./(pga_rock + V.c.*((Vs30./V.lin).^V.n))));
term1 = term11.*(Vs30>=V.lin)+term12.*(Vs30<V.lin);


% from openSHA
sig = sqrt(sigma0.^2 + term1.^2 .* pga_sigmaB.^2 + 2*term1 .* sigmaB.*pga_sigmaB.*V.ro);
tau   = sqrt(tau0.^2   + term1.^2 .* pga_tauB.^2   + 2*term1 .* tauB  .*pga_tauB  .*V.ro);
sigma = sqrt(sig.^2 + tau.^2);
