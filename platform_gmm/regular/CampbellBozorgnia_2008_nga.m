function[lny,sigma,tau,sig] = CampbellBozorgnia_2008_nga(To, M, rrup, rjb, ztor, dip, mechanism, Vs30, Z25, arb)

% Kenneth W. Campbell and Yousef Bozorgnia (2008) NGA Ground Motion 
% Model for the Geometric Mean Horizontal Component of PGA, PGV, PGD and 5
% Damped Linear Elastic Response Spectra for Periods Ranging from 
% 0.01?to?10?s. Earthquake Spectra: February 2008, Vol. 24, No. 1, pp. 139-171.
if  and(To<0 || To> 10,To~=-1 && To~=-10)
    lny   = nan(size(M));
    sigma = nan(size(M));
    tau   = nan(size(M));
    sig   = nan(size(M));
    %IM    = IM2str(To);
    %h=warndlg(sprintf('GMPE %s not available for %s',mfilename,IM{1}));
    %uiwait(h);
    return
end

if To>=0
    To      = max(To,0.001); %PGA is associated to To=0.01;
end
period  = [-10 -1 0.001 0.01 0.02 0.03 0.05 0.075 0.1 0.15 0.2 0.25 0.3 0.4 0.5 0.75 1 1.5 2 3 4 5 7.5 10];
T_lo    = max(period(period<=To));
T_hi    = min(period(period>=To));
index   = find(abs((period - T_lo)) < 1e-6); % Identify the period

if T_lo==T_hi
    [lny,sigma,tau,sig] = gmpe(index,M, rrup, rjb, ztor, dip, mechanism, Vs30, Z25, arb);
else
    [lny_lo,sigma_lo,tau_lo] = gmpe(index,  M, rrup, rjb, ztor, dip, mechanism, Vs30, Z25, arb);
    [lny_hi,sigma_hi,tau_hi] = gmpe(index+1,M, rrup, rjb, ztor, dip, mechanism, Vs30, Z25, arb);
    x          = log([T_lo;T_hi]);
    Y_sa       = [lny_lo,lny_hi]';
    Y_sigma    = [sigma_lo,sigma_hi]';
    Y_tau      = [tau_lo,tau_hi]';
    lny        = interp1(x,Y_sa,log(To))';
    sigma      = interp1(x,Y_sigma,log(To))';
    tau        = interp1(x,Y_tau,log(To))';
    sig        = sqrt(sigma.^2-tau.^2);
end

function[lny,sigma,tau,sig]=gmpe(index,M,rrup, rjb, ztor, dip, mechanism, Vs30, Z25, arb)
switch mechanism
    case 'strike-slip',     Frv = 0; Fnm=0;
    case 'normal',          Frv = 0; Fnm=1;
    case 'normal-oblique',  Frv = 0; Fnm=1;
    case 'reverse',         Frv = 1; Fnm=0;
    case 'reverse-oblique', Frv = 1; Fnm=0;
    case 'thrust',          Frv = 1; Fnm=0;
end

switch arb
    case 'arbitrary', arb=1;
    case 'average',   arb=0;
end

% Style of faulting
ffltz = min(ztor,1);
Nt    = length(M);
znt   = zeros(Nt,1);
fhngr = znt;
fhngr(rjb == 0) = 1;

fhn1 = (max(rrup,sqrt(rjb.^2+1))-rjb)./max(rrup,sqrt(rjb.^2+1));
fhn2 =(rrup - rjb)./rrup;

ind1 = and(rjb ~= 0,ztor < 1);
ind2 = and(rjb ~= 0,ztor >=1);
fhngr (ind1)=fhn1(ind1);
fhngr (ind2)=fhn2(ind2);


fhngm = znt;
fhngm(M<6.5)=2 * (M(M<6.5) - 6);
fhngm(M>=6.5)=1;

Coef = [
-5.27	1.6	-0.07	0	-2	0.17	4	0	0	0	-0.82	0.3	1	400	0	2.744	0.667	0.485	0.29	0.825	0.874	0.174
0.954	0.696	-0.309	-0.019	-2.016	0.17	4	0.245	0	0.358	1.694	0.092	1	400	-1.955	1.929	0.484	0.203	0.19	0.525	0.558	0.691
-1.715	0.5	-0.53	-0.262	-2.118	0.17	5.6	0.28	-0.12	0.49	1.058	0.04	0.61	865	-1.186	1.839	0.478	0.219	0.166	0.526	0.551	1
-1.715	0.5	-0.53	-0.262	-2.118	0.17	5.6	0.28	-0.12	0.49	1.058	0.04	0.61	865	-1.186	1.839	0.478	0.219	0.166	0.526	0.551	1
-1.68	0.5	-0.53	-0.262	-2.123	0.17	5.6	0.28	-0.12	0.49	1.102	0.04	0.61	865	-1.219	1.84	0.48	0.219	0.166	0.528	0.553	0.999
-1.552	0.5	-0.53	-0.262	-2.145	0.17	5.6	0.28	-0.12	0.49	1.174	0.04	0.61	908	-1.273	1.841	0.489	0.235	0.165	0.543	0.567	0.989
-1.209	0.5	-0.53	-0.267	-2.199	0.17	5.74	0.28	-0.12	0.49	1.272	0.04	0.61	1054	-1.346	1.843	0.51	0.258	0.162	0.572	0.594	0.963
-0.657	0.5	-0.53	-0.302	-2.277	0.17	7.09	0.28	-0.12	0.49	1.438	0.04	0.61	1086	-1.471	1.845	0.52	0.292	0.158	0.596	0.617	0.922
-0.314	0.5	-0.53	-0.324	-2.318	0.17	8.05	0.28	-0.099	0.49	1.604	0.04	0.61	1032	-1.624	1.847	0.531	0.286	0.17	0.603	0.627	0.898
-0.133	0.5	-0.53	-0.339	-2.309	0.17	8.79	0.28	-0.048	0.49	1.928	0.04	0.61	878	-1.931	1.852	0.532	0.28	0.18	0.601	0.628	0.89
-0.486	0.5	-0.446	-0.398	-2.22	0.17	7.6	0.28	-0.012	0.49	2.194	0.04	0.61	748	-2.188	1.856	0.534	0.249	0.186	0.589	0.618	0.871
-0.89	0.5	-0.362	-0.458	-2.146	0.17	6.58	0.28	0	0.49	2.351	0.04	0.7	654	-2.381	1.861	0.534	0.24	0.191	0.585	0.616	0.852
-1.171	0.5	-0.294	-0.511	-2.095	0.17	6.04	0.28	0	0.49	2.46	0.04	0.75	587	-2.518	1.865	0.544	0.215	0.198	0.585	0.618	0.831
-1.466	0.5	-0.186	-0.592	-2.066	0.17	5.3	0.28	0	0.49	2.587	0.04	0.85	503	-2.657	1.874	0.541	0.217	0.206	0.583	0.618	0.785
-2.569	0.656	-0.304	-0.536	-2.041	0.17	4.73	0.28	0	0.49	2.544	0.04	0.883	457	-2.669	1.883	0.55	0.214	0.208	0.59	0.626	0.735
-4.844	0.972	-0.578	-0.406	-2	0.17	4	0.28	0	0.49	2.133	0.077	1	410	-2.401	1.906	0.568	0.227	0.221	0.612	0.65	0.628
-6.406	1.196	-0.772	-0.314	-2	0.17	4	0.255	0	0.49	1.571	0.15	1	400	-1.955	1.929	0.568	0.255	0.225	0.623	0.662	0.534
-8.692	1.513	-1.046	-0.185	-2	0.17	4	0.161	0	0.49	0.406	0.253	1	400	-1.025	1.974	0.564	0.296	0.222	0.637	0.675	0.411
-9.701	1.6	-0.978	-0.236	-2	0.17	4	0.094	0	0.371	-0.456	0.3	1	400	-0.299	2.019	0.571	0.296	0.226	0.643	0.682	0.331
-10.556	1.6	-0.638	-0.491	-2	0.17	4	0	0	0.154	-0.82	0.3	1	400	0	2.11	0.558	0.326	0.229	0.646	0.686	0.289
-11.212	1.6	-0.316	-0.77	-2	0.17	4	0	0	0	-0.82	0.3	1	400	0	2.2	0.576	0.297	0.237	0.648	0.69	0.261
-11.684	1.6	-0.07	-0.986	-2	0.17	4	0	0	0	-0.82	0.3	1	400	0	2.291	0.601	0.359	0.237	0.7	0.739	0.2
-12.505	1.6	-0.07	-0.656	-2	0.17	4	0	0	0	-0.82	0.3	1	400	0	2.517	0.628	0.428	0.271	0.76	0.807	0.174
-13.087	1.6	-0.07	-0.422	-2	0.17	4	0	0	0	-0.82	0.3	1	400	0	2.744	0.667	0.485	0.29	0.825	0.874	0.174];


C   = Coef(index,:);

c0	= C(1);
c1	= C(2);
c2  = C(3);
c3  = C(4);
c4  = C(5);
c5  = C(6);
c6  = C(7);
c7  = C(8);
c8  = C(9);
c9  = C(10);
c10 = C(11);
c11 = C(12);
c12 = C(13);
k1  = C(14);
k2  = C(15);
k3  = C(16);
slny = C(17);
tlny = C(18);
sigmac = C(19);
% sigmat = C(20);
% sigmaarb = C(21);
roh = C(22);

c = 1.88;
n = 1.18;

% Magnitude dependence
fmag = znt;
ind1 = (M <= 5.5);        fmag(ind1) = c0  + c1  * M(ind1);
ind2 = and(5.5<M,M<=6.5); fmag(ind2) = c0  + c1  * M(ind2) + c2  * (M(ind2) - 5.5);
ind3 = M>6.5;             fmag(ind3) = c0  + c1  * M(ind3) + c2  * (M(ind3) - 5.5) + c3  * (M(ind3) - 6.5);  


% Distance dependence
fdis = (c4  + c5  * M) .* log(sqrt(rrup.^2 + c6 ^2));

% Style of faulting
fflt = c7  * Frv * ffltz + c8  * Fnm;

% Hanging-wall effects
fhngz     = ((20 - ztor)/20) .* (ztor >= 0).* (ztor < 20);
fhngdelta = (dip <= 70) + ((90 - dip)/20) * (dip > 70);
if isnan(fhngdelta)
    fhng      = zeros(size(M));
else
    fhng      = c9  * fhngr .* fhngm .* fhngz * fhngdelta;
end

% Site conditions
if Vs30 < k1
    A1100 = getA1100(M, rrup, Z25,Frv,Fnm,ffltz,fhngr,fhngm,fhngz,fhngdelta);
    fsite = c10  * log(Vs30/k1 ) + k2  * (log(A1100 + c * (Vs30/k1 )^n) - log(A1100 + c));
elseif Vs30 < 1100
    fsite = (c10  + k2  * n) * log(Vs30/k1 );
else
    fsite = (c10  + k2  * n) * log(1100/k1 );
end

% Sediment effects
if Z25 < 1
    fsed = c11  * (Z25 - 1);
elseif Z25 <= 3
    fsed = 0;
else
    fsed = c12  * k3  * exp(-0.75) * (1 - exp(-0.25 * (Z25 - 3)));
end

% Median value
lny = fmag + fdis + fflt + fhng + fsite + fsed;

% Standard deviation computations
if (Vs30 < k1 )
    alpha = k2  * A1100 .* ((A1100 + c*(Vs30/k1 ).^n).^(-1) - (A1100+c).^(-1));
else
    alpha = znt;
end

slnaf=0.3;
slnpga=0.478;
slnab=sqrt(slnpga^2    -slnaf^2);
slnyb=sqrt(slny ^2  -slnaf^2);
sig = sqrt(slny ^2 + alpha.^2*slnab^2 + 2*alpha*roh *slnyb*slnab);
tau = tlny*ones(size(M)) ;

sigma=sqrt(sig.^2 + tau.^2);
if arb == 1
    sigma = sqrt(sigma.^2 + sigmac ^2);
end

function [A1100] = getA1100(M, rrup, Z25,Frv,Fnm,ffltz,fhngr,fhngm,fhngz,fhngdelta)

c0  =  -1.7150;
c1  =   0.5000;
c2  =  -0.5300;
c3  =  -0.2620;
c4  =  -2.1180;
c5  =   0.1700;
c6  =   5.6000;
c7  =   0.2800;
c8  =  -0.1200;
c9  =   0.4900;
c10 =   1.0580;
c11 =   0.0400;
c12 =   0.6100;
k1  = 865.0000;
k2  =  -1.1860;
k3  =   1.8390;
n   =   1.18;

% Magnitude dependence
Nt    = length(M);
fmag = zeros(Nt,1);
ind1 = (M <= 5.5);        fmag(ind1) = c0  + c1  * M(ind1);
ind2 = and(5.5<M,M<=6.5); fmag(ind2) = c0  + c1  * M(ind2) + c2  * (M(ind2) - 5.5);
ind3 = M>6.5;             fmag(ind3) = c0  + c1  * M(ind3) + c2  * (M(ind3) - 5.5) + c3  * (M(ind3) - 6.5);  

% Distance dependence
fdis  = (c4  + c5  * M) .* log(sqrt(rrup.^2 + c6 ^2));
fflt  = c7  * Frv * ffltz + c8  * Fnm;
fhng  = c9  * fhngr .* fhngm .* fhngz * fhngdelta;
fsite = (c10  + k2  * n) * log(1100/k1 );

% Sediment effects
if Z25 < 1
    fsed = c11  * (Z25 - 1);
elseif Z25 <= 3
    fsed = 0;
else
    fsed = c12  * k3  * exp(-0.75) * (1 - exp(-0.25 * (Z25 - 3)));
end

% Median value
A1100 = exp(fmag + fdis + fflt + fhng + fsite + fsed);
