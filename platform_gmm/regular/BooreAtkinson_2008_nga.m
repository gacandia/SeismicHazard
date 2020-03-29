function[lny,sigma,tau,phi] = BooreAtkinson_2008_nga (To, M, rjb, mechanism, Vs30)

lny   = nan(size(M));
sigma = nan(size(M));
tau   = nan(size(M));
phi   = nan(size(M));

if  and(To<0 || To> 10,To~=-1)
    return
end

if To>=0
    To      = max(To,0.001); %PGA is associated to To=0.01;
end
period  = [-1 0.001 0.01 0.02 0.03 0.05 0.075 0.1 0.15 0.2 0.25 0.3 0.4 0.5 0.75 1 1.5 2 3 4 5 7.5 10];
T_lo    = max(period(period<=To));
T_hi    = min(period(period>=To));
index   = find(abs((period - T_lo)) < 1e-6); % Identify the period

if T_lo==T_hi
    [lny,sigma,tau,phi] = gmpe(index,M, rjb, mechanism, Vs30);
else
    [lny_lo,sigma_lo,tau_lo] = gmpe(index,  M, rjb, mechanism, Vs30);
    [lny_hi,sigma_hi,tau_hi] = gmpe(index+1,M, rjb, mechanism, Vs30);
    x          = log([T_lo;T_hi]);
    Y_sa       = [lny_lo,lny_hi]';
    Y_sigma    = [sigma_lo,sigma_hi]';
    Y_tau      = [tau_lo,tau_hi]';
    lny        = interp1(x,Y_sa,log(To))';
    sigma      = interp1(x,Y_sigma,log(To))';
    tau        = interp1(x,Y_tau,log(To))';
    phi        = sqrt(sigma.^2-tau.^2);
end

function[lny,sigma,tau,sig]=gmpe(index,M, rjb, mechanism, Vs30)

U=0;S=0;N=0;R=0;
switch mechanism
    case 'unspecified',U=1;
    case 'strike-slip',S=1;
    case 'normal',     N=1;
    case 'reverse',    R=1;
end

% Computation with input periods
% interpolate between periods if neccesary
lnPGA                = BA_2008_nga_sub (rjb,  M, U,S,N,R, 760 ,2    ,'pga4nl');
[lny, sigma,tau,sig] = BA_2008_nga_sub (rjb,  M, U,S,N,R, Vs30,index,exp(lnPGA));

function [lny, sigma,tau,sig] = BA_2008_nga_sub (Rjb,  M, U,S,N,R, Vs30,index,pga4nl)

% Coefficients
C=[-0.8737	0.1006	-0.00334	2.54	5.00121	5.04727	4.63188	5.0821	0.18322	-0.12736	0	8.5	0.5	0.286	0.576	0.256	0.56	-0.6	-0.5	-0.06
-0.6605	0.1197	-0.01151	1.35	-0.53804	-0.5035	-0.75472	-0.5097	0.28805	-0.10164	0	6.75	0.502	0.265	0.566	0.26	0.564	-0.36	-0.64	-0.14
-0.6622	0.12	-0.01151	1.35	-0.52883	-0.49429	-0.74551	-0.49966	0.28897	-0.10019	0	6.75	0.502	0.267	0.569	0.262	0.566	-0.36	-0.64	-0.14
-0.666	0.1228	-0.01151	1.35	-0.52192	-0.48508	-0.73906	-0.48895	0.25144	-0.11006	0	6.75	0.502	0.267	0.569	0.262	0.566	-0.34	-0.63	-0.12
-0.6901	0.1283	-0.01151	1.35	-0.45285	-0.41831	-0.66722	-0.42229	0.17976	-0.12858	0	6.75	0.507	0.276	0.578	0.274	0.576	-0.33	-0.62	-0.11
-0.717	0.1317	-0.01151	1.35	-0.28476	-0.25022	-0.48462	-0.26092	0.06369	-0.15752	0	6.75	0.516	0.286	0.589	0.286	0.589	-0.29	-0.64	-0.11
-0.7205	0.1237	-0.01151	1.55	0.00767	0.04912	-0.20578	0.02706	0.0117	-0.17051	0	6.75	0.513	0.322	0.606	0.32	0.606	-0.23	-0.64	-0.11
-0.7081	0.1117	-0.01151	1.68	0.20109	0.23102	0.03058	0.22193	0.04697	-0.15948	0	6.75	0.52	0.313	0.608	0.318	0.608	-0.25	-0.6	-0.13
-0.6961	0.09884	-0.01113	1.86	0.46128	0.48661	0.30185	0.49328	0.1799	-0.14539	0	6.75	0.518	0.288	0.592	0.29	0.594	-0.28	-0.53	-0.18
-0.583	0.04273	-0.00952	1.98	0.5718	0.59253	0.4086	0.61472	0.52729	-0.12964	0.00102	6.75	0.523	0.283	0.596	0.288	0.596	-0.31	-0.52	-0.19
-0.5726	0.02977	-0.00837	2.07	0.51884	0.53496	0.3388	0.57747	0.6088	-0.13843	0.08607	6.75	0.527	0.267	0.592	0.267	0.592	-0.39	-0.52	-0.16
-0.5543	0.01955	-0.0075	2.14	0.43825	0.44516	0.25356	0.5199	0.64472	-0.15694	0.10601	6.75	0.546	0.272	0.608	0.269	0.608	-0.44	-0.52	-0.14
-0.6443	0.04394	-0.00626	2.24	0.3922	0.40602	0.21398	0.4608	0.7861	-0.07843	0.02262	6.75	0.541	0.267	0.603	0.267	0.603	-0.5	-0.51	-0.1
-0.6914	0.0608	-0.0054	2.32	0.18957	0.19878	0.00967	0.26337	0.76837	-0.09054	0	6.75	0.555	0.265	0.615	0.265	0.615	-0.6	-0.5	-0.06
-0.7408	0.07518	-0.00409	2.46	-0.21338	-0.19496	-0.49176	-0.10813	0.75179	-0.14053	0.10302	6.75	0.571	0.311	0.649	0.299	0.645	-0.69	-0.47	0
-0.8183	0.1027	-0.00334	2.54	-0.46896	-0.43443	-0.78465	-0.3933	0.6788	-0.18257	0.05393	6.75	0.573	0.318	0.654	0.302	0.647	-0.7	-0.44	0
-0.8303	0.09793	-0.00255	2.66	-0.86271	-0.79593	-1.20902	-0.88085	0.70689	-0.2595	0.19082	6.75	0.566	0.382	0.684	0.373	0.679	-0.72	-0.4	0
-0.8285	0.09432	-0.00217	2.73	-1.22652	-1.15514	-1.57697	-1.27669	0.77989	-0.29657	0.29888	6.75	0.58	0.398	0.702	0.389	0.7	-0.73	-0.38	0
-0.7844	0.07282	-0.00191	2.83	-1.82979	-1.7469	-2.22584	-1.91814	0.77966	-0.45384	0.67466	6.75	0.566	0.41	0.7	0.401	0.695	-0.74	-0.34	0
-0.6854	0.03758	-0.00191	2.89	-2.24656	-2.15906	-2.58228	-2.38168	1.24961	-0.35874	0.79508	6.75	0.583	0.394	0.702	0.385	0.698	-0.75	-0.31	0
-0.5096	-0.02391	-0.00191	2.93	-1.28408	-1.2127	-1.50904	-1.41093	0.14271	-0.39006	0	8.5	0.601	0.414	0.73	0.437	0.744	-0.75	-0.291	0
-0.3724	-0.06568	-0.00191	3	-1.43145	-1.31632	-1.81022	-1.59217	0.52407	-0.37578	0	8.5	0.626	0.465	0.781	0.477	0.787	-0.692	-0.247	0
-0.09824	-0.138	-0.00191	3.04	-2.15446	-2.16137	-2.53323	-2.14635	0.40387	-0.48492	0	8.5	0.645	0.355	0.735	0.477	0.801	-0.65	-0.215	0];

Coef = C(index,:);

c1   =Coef(1);   
c2   =Coef(2);
c3   =Coef(3);
h    =Coef(4);
e1   =Coef(5);
e2   =Coef(6);
e3   =Coef(7);
e4   =Coef(8);
e5   =Coef(9);
e6   =Coef(10);
e7   =Coef(11);
Mh   =Coef(12);
sig   =Coef(13);
tauU  =Coef(14);
tauM  =Coef(16);
blin =Coef(18);
b1   =Coef(19);
b2   =Coef(20);

a1 = 0.03;
pga_low = 0.06;
a2 = 0.09;
v1 = 180;
v2 = 300;
vref = 760;
mref=4.5;
rref=1;

% Magnitude Scaling
FM1 = e1 * U + e2 * S + e3 * N + e4 * R + e5 * (M - Mh) + e6 * (M - Mh).^2;
FM  = e1 * U + e2 * S + e3 * N + e4 * R + e7 * (M - Mh);
FM(M<Mh)  = FM1(M<Mh);

% Distance Scaling
r = sqrt (Rjb.^2 + h^2);
FD = (c1 + c2*(M-mref)).*log(r/rref)+ c3*(r-rref);

if ischar(pga4nl)
    lny    = FM+FD;
    sigma  = [];
    return
end

% Site Amplification Factor

% Linear term
Flin = blin * log (Vs30 / vref);

% Nonlinear term
if Vs30 <= v1
    bnl = b1;
elseif Vs30 <= v2
    bnl = b2 + (b1 - b2) * log (Vs30 / v2) / log (v1 / v2);
elseif Vs30 <= vref
    bnl = b2 * log (Vs30 / vref) / log (v2 / vref);
else
    bnl = 0.0;
end
deltax = log(a2/a1);
deltay = bnl * log(a2/pga_low);
c    = (3*deltay - bnl * deltax)/(deltax^2);
d    = - (2* deltay - bnl * deltax)/(deltax^3);
Fnl1 = bnl * log (pga_low / 0.1);
Fnl2 = bnl * log (pga_low / 0.1) + c * (log (pga4nl / a1)).^2 + d * (log (pga4nl / a1)).^3;
Fnl  = bnl * log (pga4nl / 0.1);
Fnl(pga4nl <= a2)=Fnl2(pga4nl <= a2);
Fnl(pga4nl <= a1)=Fnl1;%(pga4nl <= a1); 
FS = Flin + Fnl;

% Compute median and sigma
lny = FM + FD + FS;
switch U
    case 1 
        sig   = sig*ones(size(M));
        tau   = tauU*ones(size(M));
        sigma = sqrt(sig.^2+tau.^2);
    case 0
        sig   = sig*ones(size(M));
        tau   = tauM*ones(size(M));
        sigma =sqrt(sig.^2+tau.^2);
end

