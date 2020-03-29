function [lny, sigma,tau,phi] = CB_2014_nga(To, M, Rrup, Rjb, Rx, W, Ztor, Zbot, delta, mechanism, HWEffect, Vs30, Z25, Zhyp, reg)

% Kenneth W. Campbell and Yousef Bozorgnia (2014) NGA-West2 Ground Motion 
% Model for the Average Horizontal Components of PGA, PGV, and 5% Damped 
% Linear Acceleration Response Spectra. Earthquake Spectra: August 2014, 
% Vol. 30, No. 3, pp. 1087-1115.
lny   = nan(size(M));
sigma = nan(size(M));
tau   = nan(size(M));
phi   = nan(size(M));

if  and(To<0 || To> 10,To~=-1)
    return
end

if isnan(W)       ,W    = 999;end
if ischar(W)      ,W    = 999;end
if ischar(Zbot(1)),Zbot = 999;end
if ischar(Zhyp(1)),Zhyp = 999*ones(size(M));end

if To>=0
    To      = max(To,0.001); %PGA is associated to To=0.01;
end
period = [0.010 0.020 0.030 0.050 0.075 0.10 0.15 0.20 0.25 0.30 0.40 0.50 0.75 1.0 1.5 2.0 3.0 4.0 5.0 7.5 10.0 0.001 -1];
T_lo    = max(period(period<=To));
T_hi    = min(period(period>=To));
index   = find(abs((period - T_lo)) < 1e-6); % Identify the period

if T_lo==T_hi
    [lny,sigma,tau] = gmpe(index,  M, Rrup, Rjb, Rx, W, Ztor,  Zbot, delta, mechanism, HWEffect, Vs30, Z25, Zhyp,reg);
    phi        = sqrt(sigma.^2-tau.^2);
else
    [lny_lo,sigma_lo,tau_lo] = gmpe(index,   M, Rrup, Rjb, Rx, W, Ztor,  Zbot, delta, mechanism, HWEffect, Vs30, Z25, Zhyp,reg);
    [lny_hi,sigma_hi,tau_hi] = gmpe(index+1, M, Rrup, Rjb, Rx, W, Ztor,  Zbot, delta, mechanism, HWEffect, Vs30, Z25, Zhyp,reg);
    x          = log([T_lo;T_hi]);
    Y_sa       = [lny_lo,lny_hi]';
    Y_sigma    = [sigma_lo,sigma_hi]';
    Y_tau      = [tau_lo,tau_hi]';
    lny        = interp1(x,Y_sa,log(To))';
    sigma      = interp1(x,Y_sigma,log(To))';
    tau        = interp1(x,Y_tau,log(To))';
    phi        = sqrt(sigma.^2-tau.^2);
end

if To<0.25
    lnPGA = gmpe(22,  M, Rrup, Rjb, Rx, W, Ztor,  Zbot, delta, mechanism, HWEffect, Vs30, Z25, Zhyp,reg);
    lny(lny<lnPGA)=lnPGA(lny<lnPGA);
end

function[lny,sigma,tau]=gmpe(index, M, Rrup, Rjb, Rx, W, Ztor,  Zbot, delta, mechanism, HWEffect, Vs30, Z25, Zhyp,reg)

% Style of faulting
switch mechanism
    case 'strike-slip',     Frv = 0; Fnm=0;
    case 'normal',          Frv = 0; Fnm=1;
    case 'normal-oblique',  Frv = 0; Fnm=0;
    case 'reverse',         Frv = 1; Fnm=0;
    case 'reverse-oblique', Frv = 1; Fnm=0;
    case 'thrust',          Frv = 1; Fnm=0;
end

switch reg
    case 'global',     region=0;
    case 'california', region=1;
    case 'japan',      region=2;
    case 'china',      region=3;
    case 'italy',      region=4;
    case 'turkey',     region=5; 
end

switch lower(HWEffect)
    case 'include',    Fhw=1;
    case 'exclude',    Fhw=0;
end

% if Ztor is unknown
if Ztor(1) == 999
    if Frv == 1
        Ztor = max(2.704 - 1.226*max(M-5.849,0),0).^2;
    else
        Ztor = max(2.673 - 1.136*max(M-4.970,0),0).^2;
    end
end

% if W is unknown
if W == 999
    if Frv == 1
        Ztori = max(2.704 - 1.226*max(M-5.849,0),0).^2;
    else
        Ztori = max(2.673 - 1.136*max(M-4.970,0),0).^2;
    end
    W = min(sqrt(10.^((M-4.07)./0.98)),(Zbot - Ztori)./sin(pi/180*delta));
    Zhyp = 9;
end

% if Zhyp is unknown
if Zhyp(1) == 999 && W ~= 999
    fdZM=-4.317 + 0.984.*M;
    fdZM(M>=6.75)=1.325;
    if delta <= 40
        fdZD = 0.0445*(delta-40);
    else
        fdZD = 0;
    end
    if Frv == 1
        Ztori = max(2.704 - 1.226*max(M-5.849,0),0).^2;
    else
        Ztori = max(2.673 - 1.136*max(M-4.970,0),0).^2;
    end
    Zbor = Ztori + W.*sin(pi/180*delta); % The depth to the bottom of the rupture plane
    d_Z = exp(min(fdZM+fdZD,log(0.9*(Zbor-Ztori))));
    Zhyp = d_Z + Ztori;
end

% Compute lnSa and sigma with user-defined period

A1100            =  exp(CB_2014_nga_sub (22   ,M, Rrup, Rjb, Rx, W, Ztor, Zhyp, delta, Fhw, 1100, Z25, Frv, Fnm, region, 999));
[lny, sigma,tau] =      CB_2014_nga_sub (index,M, Rrup, Rjb, Rx, W, Ztor, Zhyp, delta, Fhw, Vs30, Z25, Frv, Fnm, region, A1100);

function [ln_Sa, sigma,tau] = CB_2014_nga_sub (index,M, Rrup, Rjb, Rx, W, Ztor, Zhyp, delta, Fhw, Vs30, Z25in, Frv, Fnm, region, A1100)
%Constants
c0	= [-4.365	-4.348	-4.024	-3.479	-3.293	-3.666	-4.866	-5.411	-5.962	-6.403	-7.566	-8.379	-9.841	-11.011	-12.469	-12.969	-13.306	-14.02	-14.558	-15.509	-15.975	-4.416	-2.895];
c1	= [0.977	0.976	0.931	0.887	0.902	0.993	1.267	1.366	1.458	1.528	1.739	1.872	2.021	2.180	2.270	2.271	2.150	2.132	2.116	2.223	2.132	0.984	1.510];
c2 = [	0.533	0.549	0.628	0.674	0.726	0.698	0.510	0.447	0.274	0.193	-0.020	-0.121	-0.042	-0.069	0.047	0.149	0.368	0.726	1.027	0.169	0.367	0.537	0.270];
c3 = [	-1.485	-1.488	-1.494	-1.388	-1.469	-1.572	-1.669	-1.750	-1.711	-1.770	-1.594	-1.577	-1.757	-1.707	-1.621	-1.512	-1.315	-1.506	-1.721	-0.756	-0.800	-1.499	-1.299];
c4 = [	-0.499	-0.501	-0.517	-0.615	-0.596	-0.536	-0.490	-0.451	-0.404	-0.321	-0.426	-0.440	-0.443	-0.527	-0.630	-0.768	-0.890	-0.885	-0.878	-1.077	-1.282	-0.496	-0.453];
c5	= [-2.773	-2.772	-2.782	-2.791	-2.745	-2.633	-2.458	-2.421	-2.392	-2.376	-2.303	-2.296	-2.232	-2.158	-2.063	-2.104	-2.051	-1.986	-2.021	-2.179	-2.244	-2.773	-2.466];
c6	= [0.248	0.247	0.246	0.240	0.227	0.210	0.183	0.182	0.189	0.195	0.185	0.186	0.186	0.169	0.158	0.158	0.148	0.135	0.140	0.178	0.194	0.248	0.204];
c7	= [6.753	6.502	6.291	6.317	6.861	7.294	8.031	8.385	7.534	6.990	7.012	6.902	5.522	5.650	5.795	6.632	6.759	7.978	8.538	8.468	6.564	6.768	5.837];
c8	= [0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0];
c9	= [-0.214	-0.208	-0.213	-0.244	-0.266	-0.229	-0.211	-0.163	-0.150	-0.131	-0.159	-0.153	-0.090	-0.105	-0.058	-0.028	0	0	0	0	0	-0.212	-0.168];
c10	= [0.720	0.730	0.759	0.826	0.815	0.831	0.749	0.764	0.716	0.737	0.738	0.718	0.795	0.556	0.480	0.401	0.206	0.105	0	0	0	0.720	0.305];
c11	= [1.094	1.149	1.290	1.449	1.535	1.615	1.877	2.069	2.205	2.306	2.398	2.355	1.995	1.447	0.330	-0.514	-0.848	-0.793	-0.748	-0.664	-0.576	1.090	1.713];
c12	= [2.191	2.189	2.164	2.138	2.446	2.969	3.544	3.707	3.343	3.334	3.544	3.016	2.616	2.470	2.108	1.327	0.601	0.568	0.356	0.075	-0.027	2.186	2.602];
c13=[1.416	1.453	1.476	1.549	1.772	1.916	2.161	2.465	2.766	3.011	3.203	3.333	3.054	2.562	1.453	0.657	0.367	0.306	0.268	0.374	0.297	1.420	2.457];
c14	= [-0.0070	-0.0167	-0.0422	-0.0663	-0.0794	-0.0294	0.0642	0.0968	0.1441	0.1597	0.1410	0.1474	0.1764	0.2593	0.2881	0.3112	0.3478	0.3747	0.3382	0.3754	0.3506	-0.0064	0.1060];
c15=[-0.207	-0.199	-0.202	-0.339	-0.404	-0.416	-0.407	-0.311	-0.172	-0.084	0.085	0.233	0.411	0.479	0.566	0.562	0.534	0.522	0.477	0.321	0.174	-0.202	0.332];
c16	= [0.390	0.387	0.378	0.295	0.322	0.384	0.417	0.404	0.466	0.528	0.540	0.638	0.776	0.771	0.748	0.763	0.686	0.691	0.670	0.757	0.621	0.393	0.585];
c17	= [0.0981	0.1009	0.1095	0.1226	0.1165	0.0998	0.0760	0.0571	0.0437	0.0323	0.0209	0.0092	-0.0082	-0.0131	-0.0187	-0.0258	-0.0311	-0.0413	-0.0281	-0.0205	0.0009	0.0977	0.0517];
c18	= [0.0334	0.0327	0.0331	0.0270	0.0288	0.0325	0.0388	0.0437	0.0463	0.0508	0.0432	0.0405	0.0420	0.0426	0.0380	0.0252	0.0236	0.0102	0.0034	0.0050	0.0099	0.0333	0.0327];
c19	= [0.00755	0.00759	0.00790	0.00803	0.00811	0.00744	0.00716	0.00688	0.00556	0.00458	0.00401	0.00388	0.00420	0.00409	0.00424	0.00448	0.00345	0.00603	0.00805	0.00280	0.00458	0.00757	0.00613];
c20	= [-0.0055	-0.0055	-0.0057	-0.0063	-0.0070	-0.0073	-0.0069	-0.0060	-0.0055	-0.0049	-0.0037	-0.0027	-0.0016	-0.0006	0	0	0	0	0	0	0	-0.0055	-0.0017];
Dc20 =  [	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0];
Dc20_JI = [	-0.0035	-0.0035	-0.0034	-0.0037	-0.0037	-0.0034	-0.0030	-0.0031	-0.0033	-0.0035	-0.0034	-0.0034	-0.0032	-0.0030	-0.0019	-0.0005	0	0	0	0	0	-0.0035	-0.0006];
Dc20_CH = [	0.0036	0.0036	0.0037	0.0040	0.0039	0.0042	0.0042	0.0041	0.0036	0.0031	0.0028	0.0025	0.0016	0.0006	0	0	0	0	0	0	0	0.0036	0.0017];
a2 =[	0.168	0.166	0.167	0.173	0.198	0.174	0.198	0.204	0.185	0.164	0.160	0.184	0.216	0.596	0.596	0.596	0.596	0.596	0.596	0.596	0.596	0.167	0.596];
h1	= [0.242	0.244	0.246	0.251	0.260	0.259	0.254	0.237	0.206	0.210	0.226	0.217	0.154	0.117	0.117	0.117	0.117	0.117	0.117	0.117	0.117	0.241	0.117];
h2	= [1.471	1.467	1.467	1.449	1.435	1.449	1.461	1.484	1.581	1.586	1.544	1.554	1.626	1.616	1.616	1.616	1.616	1.616	1.616	1.616	1.616	1.474	1.616];
h3	= [-0.714	-0.711	-0.713	-0.701	-0.695	-0.708	-0.715	-0.721	-0.787	-0.795	-0.770	-0.770	-0.780	-0.733	-0.733	-0.733	-0.733	-0.733	-0.733	-0.733	-0.733	-0.715	-0.733];
h4	= [1.000	1.000	1.000	1.000	1.000	1.000	1.000	1.000	1.000	1.000	1.000	1.000	1.000	1.000	1.000	1.000	1.000	1.000	1.000	1.000	1.000	1.000	1.000];
h5	= [-0.336	-0.339	-0.338	-0.338	-0.347	-0.391	-0.449	-0.393	-0.339	-0.447	-0.525	-0.407	-0.371	-0.128	-0.128	-0.128	-0.128	-0.128	-0.128	-0.128	-0.128	-0.337	-0.128];
h6	= [-0.270	-0.263	-0.259	-0.263	-0.219	-0.201	-0.099	-0.198	-0.210	-0.121	-0.086	-0.281	-0.285	-0.756	-0.756	-0.756	-0.756	-0.756	-0.756	-0.756	-0.756	-0.270	-0.756];
k1 = [865 865 908 1054 1086 1032 878 748 654 587 503 457 410 400 400 400 400 400 400 400 400 865 400];
k2=[-1.186	-1.219	-1.273	-1.346	-1.471	-1.624	-1.931	-2.188	-2.381	-2.518	-2.657	-2.669	-2.401	-1.955	-1.025	-0.299	0.000	0.000	0.000	0.000	0.000	-1.186	-1.955];
k3	= [1.839	1.840	1.841	1.843	1.845	1.847	1.852	1.856	1.861	1.865	1.874	1.883	1.906	1.929	1.974	2.019	2.110	2.200	2.291	2.517	2.744	1.839	1.929];
c	= 1.88;
n	= 1.18;
f1	= [0.734	0.738	0.747	0.777	0.782	0.769	0.769	0.761	0.744	0.727	0.690	0.663	0.606	0.579	0.541	0.529	0.527	0.521	0.502	0.457	0.441	0.734	0.655];
f2	= [0.492	0.496	0.503	0.520	0.535	0.543	0.543	0.552	0.545	0.568	0.593	0.611	0.633	0.628	0.603	0.588	0.578	0.559	0.551	0.546	0.543	0.492	0.494];
t1	= [0.404	0.417	0.446	0.508	0.504	0.445	0.382	0.339	0.340	0.340	0.356	0.379	0.430	0.470	0.497	0.499	0.500	0.543	0.534	0.523	0.466	0.409	0.317];
t2	= [0.325	0.326	0.344	0.377	0.418	0.426	0.387	0.338	0.316	0.300	0.264	0.263	0.326	0.353	0.399	0.400	0.417	0.393	0.421	0.438	0.438	0.322	0.297];
flnAF	= [0.300	0.300	0.300	0.300	0.300	0.300	0.300	0.300	0.300	0.300	0.300	0.300	0.300	0.300	0.300	0.300	0.300	0.300	0.300	0.300	0.300	0.300	0.300];
rlnPGA_lnY = [1.000, 0.998, 0.986, 0.938, 0.887, 0.870, 0.876,0.870, 0.850, 0.819, 0.743, 0.684, 0.562, 0.467, 0.364, 0.298, 0.234, 0.202, 0.184, 0.176, 0.154, 1.000, 0.684];

c0  = c0  (index);
c1  = c1  (index);
c2  = c2  (index);
c3  = c3  (index);
c4  = c4  (index);
c5  = c5  (index);
c6  = c6  (index);
c7  = c7  (index);
c8  = c8  (index);
c9  = c9  (index);
c10 = c10 (index);
c11 = c11 (index);
c12 = c12 (index);
c13 = c13 (index);
c14 = c14 (index);
c15 = c15 (index);
c16 = c16 (index);
c17 = c17 (index);
c18 = c18 (index);
c19 = c19 (index);
c20 = c20 (index);
Dc20= Dc20(index);
Dc20_JI=Dc20_JI (index);
Dc20_CH=Dc20_CH (index);
a2  = a2(index);
h1  = h1(index);
h2  = h2(index);
h3  = h3(index);
h4  = h4(index);
h5  = h5(index);
h6  = h6(index);
k1  = k1(index);
k2  = k2(index);
k3  = k3(index);
f1  = f1(index);
f2  = f2(index);
t1  = t1(index);
t2  = t2(index);
flnAF      = flnAF (index);
rlnPGA_lnY = rlnPGA_lnY(index);

% Adjustment factor based on region
if region == 2
    Dc20 = Dc20_JI;
elseif region ==4
    Dc20 = Dc20_JI;
elseif region == 3
    Dc20 = Dc20_CH;
end
% if region is in Japan
Sj = (region==2);

% if Z2.5 is unknown
if Z25in == 999
    if region ~= 2  % if in California or other locations
        if A1100==999
            Z25 = exp(7.089 - 1.144 * log(Vs30));
        else
            Z25 = exp(7.089 - 1.144 * log(1100));
        end
    elseif region == 2  % if in Japan
        if A1100==999
            Z25 = exp(5.359 - 1.102 * log(Vs30));
        else
            Z25 = exp(5.359 - 1.102 * log(1100));
        end
    end
else
    % Assign Z2.5 from user input into Z25 and calc Z25A for Vs30=1100m/s
    if region ~= 2  % if in California or other locations
        if A1100(1)==999
            Z25 = Z25in;
        else
            Z25 = exp(7.089 - 1.144 * log(1100));
        end
    elseif region == 2  % if in Japan
        if A1100(1)==999
            Z25 = Z25in;
        else
            Z25 = exp(5.359 - 1.102 * log(1100));
        end
    end
end

% Magnitude dependence
fmag1 = c0 + c1 * M;
fmag2 = c0 + c1 * M + c2 * (M - 4.5);
fmag3 = c0 + c1 * M + c2 * (M - 4.5) + c3 * (M - 5.5);
fmag  = c0 + c1 * M + c2 * (M - 4.5) + c3 * (M - 5.5) + c4 * (M-6.5);
fmag(M<=6.5)= fmag3(M<=6.5);
fmag(M<=5.5)= fmag2(M<=5.5);
fmag(M<=4.5)= fmag1(M<=4.5);

% Geometric attenuation term
fdis = (c5 + c6 * M) .* log(sqrt(Rrup.^2 + c7^2));

% Style of faulting
F_fltm=M-4.5;
F_fltm(M<=4.5)=0;
F_fltm(M>5.5)=1;

fflt = ((c8 * Frv) + (c9 * Fnm)).*F_fltm;

% Hanging-wall effects
if delta==90
    fhng = zeros(size(M));
else
    R1 = W .* cosd(delta); % W - downdip width
    R2 = 62.* M - 350;
    
    f1_Rx = h1+h2.*(Rx/R1)+h3.*(Rx/R1).^2;
    f2_Rx = h4+h5*((Rx-R1)./(R2-R1))+h6*((Rx-R1)./(R2-R1)).^2;
    
    if Fhw==0
        f_hngRx=0;
    else
        f_hngRx = f1_Rx;
        f_hngRx(Rx>=R1)=max(f2_Rx(Rx>=R1),0);
    end
    f_hngRup = (Rrup-Rjb)./Rrup;
    f_hngRup(Rrup==0) = 1;
    
    f_hngM = (M-5.5).*(1+a2*(M-6.5));
    f_hngM(M<=5.5)= 0;
    f_hngM(M> 6.5)= 1+a2.*(M(M> 6.5)-6.5);
    
    f_hngZ = 1-0.06.*Ztor;
    f_hngZ(Ztor>16.66)=0;
    
    f_hngdelta = (90-delta)/45;
    fhng = c10 .* f_hngRx .* f_hngRup .* f_hngM .* f_hngZ .* f_hngdelta;
end

% Site conditions
if Vs30 <= k1
    f_siteG = c11 * log(Vs30/k1) + k2 * (log(A1100 + c * (Vs30/k1)^n) - log(A1100 + c));
elseif Vs30 > k1
    f_siteG = (c11 + k2 * n) * log(Vs30/k1);
end

if Vs30 <= 200
    f_siteJ = (c12+k2*n)*(log(Vs30/k1)-log(200/k1))*Sj;
else
    f_siteJ = (c13+k2*n)*log(Vs30/k1)*Sj;
end

fsite = f_siteG + f_siteJ;

% Basin Response Term - Sediment effects
fsed=0;
if Z25 <= 1
    fsed = (c14+c15*Sj) * (Z25 - 1);
end
if Z25 > 3
    fsed = c16 * k3 * exp(-0.75) * (1 - exp(-0.25 * (Z25 - 3)));
end

% Hypocenteral Depth term
f_hypH = Zhyp-7;
f_hypH(Zhyp <= 7)=0;
f_hypH(Zhyp > 20)=13;

f_hypM = c17 + (c18-c17).*(M-5.5);
f_hypM(M<=5.5)=c17;
f_hypM(M> 6.5)=c18;

fhyp = f_hypH .* f_hypM;

% Fault Dip term
f_dip = c19*(5.5-M)*delta;
f_dip(M<=4.5) = c19*delta;
f_dip(M> 5.5) = 0;

% Anelastic Attenuation Term
f_atn = (c20 + Dc20)*(Rrup-80);
f_atn(Rrup<=80) = 0;


% Ln median value
ln_Sa = fmag + fdis + fflt + fhng + fsite + fsed + fhyp + f_dip + f_atn;

% Coefficient values for To=0 (PGA)
f1To = 0.734;%C(2,35);
f2To = 0.492;%C(2,36);
t1To = 0.404;%C(2,37);
t2To = 0.325;%C(2,38);


% Standard deviation computations
tau_lny   = t2+(t1-t2).*(5.5-M);
tau_lny(M<=4.5)=t1;
tau_lny(M>=5.5)=t2;

phi_lny   = f2+(f1-f2).*(5.5-M);
phi_lny(M<=4.5)=f1;
phi_lny(M>=5.5)=f2;

tau_lnPGA = t2To+(t1To-t2To).*(5.5-M);
tau_lnPGA (M<=4.5)= t1To;
tau_lnPGA (M>=5.5)= t2To;

phi_lnPGA = f2To+(f1To-f2To).*(5.5-M);
phi_lnPGA (M<=4.5)= f1To;
phi_lnPGA (M>=5.5)= f2To;

tau_lnyB = tau_lny;
tau_lnPGAB = tau_lnPGA;
phi_lnyB   = sqrt(phi_lny.^2-flnAF^2);
phi_lnPGAB = sqrt(phi_lnPGA.^2-flnAF^2);

if (Vs30 < k1)
    alpha = k2 .* A1100 .* ((A1100 + c*(Vs30/k1)^n).^(-1) - (A1100+c).^(-1));
else
    alpha = 0;
end

tau = sqrt(tau_lnyB.^2 + alpha.^2.*tau_lnPGAB.^2 + 2.*alpha.*rlnPGA_lnY.*tau_lnyB.*tau_lnPGAB);
sig = sqrt(phi_lnyB.^2 + flnAF.^2 + alpha.^2.*phi_lnPGAB.^2 + 2.*alpha.*rlnPGA_lnY.*phi_lnyB.*phi_lnPGAB);

sigma=sqrt(tau.^2+sig.^2);