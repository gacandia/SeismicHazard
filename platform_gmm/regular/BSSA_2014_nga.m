function [lny, sigma,tau,phi] = BSSA_2014_nga(To,M, rjb, mechanism, reg, BasinDepth, Vs30)

% David M. Boore, Jonathan P. Stewart, Emel Seyhan, and Gail M.
% Atkinson (2014) NGA-West2 Equations for Predicting PGA, PGV, and 5
% Damped PSA for Shallow Crustal Earthquakes. Earthquake Spectra:
% August 2014, Vol. 30, No. 3, pp. 1057-1085.
lny   = nan(size(M));
sigma = nan(size(M));
tau   = nan(size(M));
phi   = nan(size(M));

if  and(To<0 || To> 10,To~=-1)
    return
end

if To>=0
    To      = max(To,0.001); %PGA is associated to To=0.001;
end
period  = [-1 0.001 0.01 0.02 0.03 0.05 0.075 0.1 0.15 0.2 0.25 0.3 0.4 0.5 0.75 1 1.5 2 3 4 5 7.5 10];
T_lo    = max(period(period<=To));
T_hi    = min(period(period>=To));
index   = find(abs((period - T_lo)) < 1e-6); % Identify the period

if T_lo==T_hi
    [lny,sigma,tau] = gmpe(index,M, rjb, mechanism, reg, BasinDepth, Vs30);
    phi             = sqrt(sigma.^2-tau.^2);
else
    [lny_lo,sigma_lo,tau_lo] = gmpe(index,  M, rjb, mechanism, reg, BasinDepth, Vs30);
    [lny_hi,sigma_hi,tau_hi] = gmpe(index+1,M, rjb, mechanism, reg, BasinDepth, Vs30);
    x          = log([T_lo;T_hi]);
    Y_sa       = [lny_lo,lny_hi]';
    Y_sigma    = [sigma_lo,sigma_hi]';
    Y_tau      = [tau_lo,tau_hi]';
    lny        = interp1(x,Y_sa,log(To))';
    sigma      = interp1(x,Y_sigma,log(To))';
    tau        = interp1(x,Y_tau,log(To))';
    phi        = sqrt(sigma.^2-tau.^2);
end

function[lny,sigma,tau]=gmpe(index,M, rjb, mechanism, reg, z1, Vs30)

U=0;SS=0;NS=0;RS=0;
switch mechanism
    case 'unspecified',U=1;
    case 'strike-slip',SS=1;
    case 'normal',     NS=1;
    case 'reverse',    RS=1;
end

switch reg
    case 'global',     region=0;
    case 'california', region=1;
    case 'japan',      region=2;
    case 'china',      region=3;
    case 'italy',      region=4;
    case 'turkey',     region=5;
end

% Computation with input periods
% interpolate between periods if neccesary
PGA              = exp(BSSA_2014_nga_sub (rjb,M,U,SS,NS,RS,760,2,'pga4nl',region,z1));
[lny, sigma,tau] = BSSA_2014_nga_sub (rjb,M,U,SS,NS,RS,Vs30,index,PGA,region,z1);

function [lny, sigma,tau] = BSSA_2014_nga_sub (rjb,M,U,SS,NS,RS,Vs30,index,pga4nl,region,z1)
% Coefficients
period=[-1 0 0.01 0.02 0.03 0.05 0.075 0.1 0.15 0.2 0.25 0.3 0.4 0.5 0.75 1 1.5 2 3 4 5 7.5 10];
To = period(index);
%Same order as PEER report
c1=[-1.24300	-1.13400	-1.13400	-1.13940	-1.14210	-1.11590	-1.08310	-1.06520	-1.05320	-1.06070	-1.07730	-1.09480	-1.12430	-1.14590	-1.17770	-1.19300	-1.20630	-1.21590	-1.21790	-1.21620	-1.21890	-1.25430	-1.32530];
c2=[0.14890	0.19170	0.19160	0.18962	0.18842	0.18709	0.18225	0.17203	0.15401	0.14489	0.13925	0.13388	0.12512	0.12015	0.11054	0.10248	0.09645	0.09636	0.09764	0.10218	0.10353	0.12507	0.15183];
c3=[-0.00344	-0.00809	-0.00809	-0.00807	-0.00834	-0.00982	-0.01058	-0.01020	-0.00898	-0.00772	-0.00652	-0.00548	-0.00405	-0.00322	-0.00193	-0.00121	-0.00037	0.00000	0.00000	-0.00005	0.00000	0.00000	0.00000];
h=[5.3	4.5	4.5	4.5	4.49	4.2	4.04	4.13	4.39	4.61	4.78	4.93	5.16	5.34	5.6	5.74	6.18	6.54	6.93	7.32	7.78	9.48	9.66];
e0=[5.037	0.4473	0.4534	0.48598	0.56916	0.75436	0.96447	1.1268	1.3095	1.3255	1.2766	1.2217	1.1046	0.96991	0.66903	0.3932	-0.14954	-0.58669	-1.1898	-1.6388	-1.966	-2.5865	-3.0702];
e1=[5.078	0.4856	0.4916	0.52359	0.6092	0.79905	1.0077	1.1669	1.3481	1.359	1.3017	1.2401	1.1214	0.99106	0.69737	0.4218	-0.11866	-0.55003	-1.142	-1.5748	-1.8882	-2.4874	-2.9537];
e2=[4.849	0.2459	0.2519	0.29707	0.40391	0.60652	0.77678	0.8871	1.0648	1.122	1.0828	1.0246	0.89765	0.7615	0.47523	0.207	-0.3138	-0.71466	-1.23	-1.6673	-2.0245	-2.8176	-3.3776];
e3=[5.033	0.4539	0.4599	0.48875	0.55783	0.72726	0.9563	1.1454	1.3324	1.3414	1.3052	1.2653	1.1552	1.012	0.69173	0.4124	-0.1437	-0.60658	-1.2664	-1.7516	-2.0928	-2.6854	-3.1726];
e4=[1.073	1.431	1.421	1.4331	1.4261	1.3974	1.4174	1.4293	1.2844	1.1349	1.0166	0.95676	0.96766	1.0384	1.2871	1.5004	1.7622	1.9152	2.1323	2.204	2.2299	2.1187	1.8837];
e5=[-0.1536	0.05053	0.04932	0.053388	0.061444	0.067357	0.073549	0.055231	-0.042065	-0.11096	-0.16213	-0.1959	-0.22608	-0.23522	-0.21591	-0.18983	-0.1467	-0.11237	-0.04332	-0.014642	-0.014855	-0.081606	-0.15096 ];
e6=[0.2252	-0.1662	-0.1659	-0.16561	-0.1669	-0.18082	-0.19665	-0.19838	-0.18234	-0.15852	-0.12784	-0.092855	-0.023189	0.029119	0.10829	0.17895	0.33896	0.44788	0.62694	0.76303	0.87314	1.0121	1.0651];
mh=[6.2 5.5 5.5 5.5 5.5 5.5 5.5 5.54 5.74 5.92 6.05 6.14 6.2 6.2 6.2 6.2 6.2 6.2 6.2 6.2 6.2 6.2 6.2];
deltac3_gloCATW=[0.000000	0.000000	0.000000	0.000000	0.000000	0.000000	0.000000	0.000000	0.000000	0.000000	0.000000	0.000000	0.000000	0.000000	0.000000	0.000000	0.000000	0.000000	0.000000	0.000000	0.000000	0.000000	0.000000];
deltac3_CHTU=[0.004350	0.002860	0.002820	0.002780	0.002760	0.002960	0.002960	0.002880	0.002790	0.002610	0.002440	0.002200	0.002110	0.002350	0.002690	0.002920	0.003040	0.002920	0.002620	0.002610	0.002600	0.002600	0.003030];
deltac3_ITJA=[-0.000330	-0.002550	-0.002440	-0.002340	-0.002170	-0.001990	-0.002160	-0.002440	-0.002710	-0.002970	-0.003140	-0.003300	-0.003210	-0.002910	-0.002530	-0.002090	-0.001520	-0.001170	-0.001190	-0.001080	-0.000570	0.000380	0.001490];
c=[-0.8400	-0.6000	-0.6037	-0.5739	-0.5341	-0.4580	-0.4441	-0.4872	-0.5796	-0.6876	-0.7718	-0.8417	-0.9109	-0.9693	-1.0154	-1.0500	-1.0454	-1.0392	-1.0112	-0.9694	-0.9195	-0.7766	-0.6558];
vc=[1300.00	1500.00	1500.20	1500.36	1502.95	1501.42	1494.00	1479.12	1442.85	1392.61	1356.21	1308.47	1252.66	1203.91	1147.59	1109.95	1072.39	1009.49	922.43	844.48	793.13	771.01	775.00];
f4=[-0.1000	-0.1500	-0.1483	-0.1471	-0.1549	-0.1963	-0.2287	-0.2492	-0.2571	-0.2466	-0.2357	-0.2191	-0.1958	-0.1704	-0.1387	-0.1052	-0.0679	-0.0361	-0.0136	-0.0032	-0.0003	-0.0001	0.0000];
f5=[-0.00844	-0.00701	-0.00701	-0.00728	-0.00735	-0.00647	-0.00573	-0.00560	-0.00585	-0.00614	-0.00644	-0.00670	-0.00713	-0.00744	-0.00812	-0.00844	-0.00771	-0.00479	-0.00183	-0.00152	-0.00144	-0.00137	-0.00136];
f6=[-9.900	-9.900	-9.9	-9.9	-9.9	-9.9	-9.9	-9.9	-9.9	-9.9	-9.9	-9.9	-9.9	-9.9	0.092	0.367	0.638	0.871	1.135	1.271	1.329	1.329	1.183];
f7=[-9.900	-9.900	-9.9	-9.9	-9.9	-9.9	-9.9	-9.9	-9.9	-9.9	-9.9	-9.9	-9.9	-9.9	0.059	0.208	0.309	0.382	0.516	0.629	0.738	0.809	0.703];
R1=[105.000	110.000	111.670	113.100	112.130	97.930	85.990	79.590	81.330	90.910	97.040	103.150	106.020	105.540	108.390	116.390	125.380	130.370	130.360	129.490	130.220	130.720	130.000];
R2=[272.000	270.000	270.000	270.000	270.000	270.000	270.040	270.090	270.160	270.000	269.450	268.590	266.540	265.000	266.510	270.000	262.410	240.140	195.000	199.450	230.000	250.390	210.000];
dphiR=[0.082	0.100	0.096	0.092	0.081	0.063	0.064	0.087	0.120	0.136	0.141	0.138	0.122	0.109	0.100	0.098	0.104	0.105	0.088	0.070	0.061	0.058	0.060];
dphiV=[0.080	0.070	0.070	0.030	0.029	0.030	0.022	0.014	0.015	0.045	0.055	0.050	0.049	0.060	0.070	0.020	0.010	0.008	0.000	0.000	0.000	0.000	0.000];
phi1=[0.6440	0.6950	0.6980	0.7020	0.7210	0.7530	0.7450	0.7280	0.7200	0.7110	0.6980	0.6750	0.6430	0.6150	0.5810	0.5530	0.5320	0.5260	0.5340	0.5360	0.5280	0.5120	0.5100];
phi2=[0.5520	0.4950	0.4990	0.5020	0.5140	0.5320	0.5420	0.5410	0.5370	0.5390	0.5470	0.5610	0.5800	0.5990	0.6220	0.6250	0.6190	0.6180	0.6190	0.6160	0.6220	0.6340	0.6040];
tau1=[0.4010	0.3980	0.4020	0.4090	0.4450	0.5030	0.4740	0.4150	0.3540	0.3440	0.3500	0.3630	0.3810	0.4100	0.4570	0.4980	0.5250	0.5320	0.5370	0.5430	0.5320	0.5110	0.4870];
tau2=[0.3460	0.3480	0.3450	0.3460	0.3640	0.4260	0.4660	0.4580	0.3880	0.3090	0.2660	0.2290	0.2100	0.2240	0.2660	0.2980	0.3150	0.3290	0.3440	0.3490	0.3350	0.2700	0.2390];

e0 = e0 (index) ;
e1 = e1 (index);
e2 = e2 (index);
e3 = e3 (index);
e4 = e4 (index);
e5 = e5 (index);
e6 = e6 (index);
Mh = mh (index);
c1 = c1 (index);
c2 = c2 (index);
c3 = c3 (index);
h  = h(index);
deltac3_gloCATW = deltac3_gloCATW(index);
deltac3_CHTU    = deltac3_CHTU (index);
deltac3_ITJA    = deltac3_ITJA (index);
c  = c(index);
vc = vc (index);
f4 = f4 (index);
f5 = f5 (index);
f6 = f6 (index);
f7 = f7 (index);
R1 = R1 (index);
R2 = R2 (index);
dphiR = dphiR(index);
dphiV = dphiV(index);
phi1  = phi1 (index);
phi2  = phi2 (index);
tau1  = tau1 (index);
tau2  = tau2 (index);

Mref=4.5;
Rref=1;
Vref=760;
f1=0;
f3=0.1;
V1=225;
V2=300;

% The source(event function):
FE1 = e0 * U + e1 * SS + e2 * NS + e3 * RS + e4 * (M - Mh) + e5 * (M - Mh).^2;
FE = e0 * U + e1 * SS + e2 * NS + e3 * RS + e6 * (M - Mh);
FE(M<Mh)  = FE1(M<Mh);

% The path function:
if region == 0 || region == 1
    deltac3 = deltac3_gloCATW;
elseif region == 3
    deltac3 = deltac3_CHTU;
elseif region == 2 || region == 4
    deltac3 = deltac3_ITJA;
end

r=sqrt(rjb.^2+h.^2);
FP= (c1 + c2 * (M - Mref)).* log (r/Rref) + (c3 + deltac3) * (r - Rref);

if ischar(pga4nl)
    lny    = FE+FP;
    sigma  = [];
    return
end

if Vs30~=Vref || To~=0
    % (M, ip, rjb, U, SS, NS, RS, region, z1, Vs30)
    %(M, 2, rjb, U, SS, NS, RS, region, z1, v_ref);
    lnPGA_r = BSSA_2014_nga_sub(rjb,M,U,SS,NS,RS,Vref,2,pga4nl,region,z1);
    
    % The site function:
    % Linear component
    ln_Flin1 = c * log(Vs30 / Vref);
    ln_Flin = c * log(vc / Vref);
    ln_Flin(Vs30<vc)=ln_Flin1(Vs30<vc);
    
    % Nonlinear component
    f2=f4*(exp(f5*(min(Vs30,760)-360))-exp(f5*(760-360)));
    ln_Fnlin=f1+f2*log((exp(lnPGA_r)+f3)/f3);
    
    % Effect of basin depth
    if not(ischar(z1) || z1==999)
        if region == 1  % if in California
            mu_z1=exp(-7.15/4*log((Vs30^4+570.94^4)/(1360^4+570.94^4)))/1000;
        else
            if region == 2  % if in Japan
                mu_z1=exp(-5.23/2*log((Vs30^2+412.39^2)/(1360^2+412.39^2)))/1000;
            else
                mu_z1=exp(-7.15/4*log((Vs30^4+570.94^4)/(1360^4+570.94^4)))/1000;
            end
        end
        dz1=z1-mu_z1;
    else
        dz1=0;
    end
    
    if not(ischar(z1) || z1==999)
        if To <0.65
            F_dz1=0;
        elseif To >= 0.65 && abs(dz1) <= f7/f6
            F_dz1=f6*dz1;
        else
            F_dz1=f7;
        end
        
    else
        F_dz1=0;
    end
    
    FS=ln_Flin+ln_Fnlin+F_dz1;
    
    lny=FE + FP + FS;
    %median=exp(ln_Y);
    
else
    lny=FE + FP;
    %median = exp(ln_y);
end

% Aleatory - uncertainty function
ind2  = and(4.5<M,M<5.5);
ind3  = (M>=5.5);
on    = ones(size(M));
tau   = tau1*on;
phi_M = phi1*on;

tauInter = tau1+(tau2-tau1)*(M-4.5);
phiInter = phi1+(phi2-phi1)*(M-4.5);

tau(ind2)   = tauInter(ind2);
phi_M(ind2) = phiInter(ind2);

tau(ind3)   = tau2*on(ind3);
phi_M(ind3) = phi2*on(ind3);

ind2   = and(R1 < rjb,rjb <= R2);
ind3   = (rjb>R2);
dr2    = dphiR*(log(rjb/R1)/log(R2/R1));
dr2(rjb==0)=0;
phi_MR = phi_M+dr2.*ind2+dphiR*ind3;

if Vs30 >= V2
    phi_MRV = phi_MR;
else
    if V1 <= Vs30 && Vs30 <= V2
        phi_MRV = phi_MR - dphiV*(log(V2/Vs30)/log(V2/V1));
    else
        if Vs30 <= V1
            phi_MRV = phi_MR - dphiV;
        end
    end
end

sigma = sqrt(phi_MRV.^2 + tau.^2);

