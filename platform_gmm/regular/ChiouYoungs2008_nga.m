function[lny,sigma,tau,phi] = ChiouYoungs2008_nga(To,M, rrup, rjb, rx, ztor, dip, Z10, mechanism, event, Vs30, Vs30type)

% BrianS-J. Chiou and Robert R. Youngs (2008) An NGA Model for the 
% Average Horizontal Component of Peak Ground Motion and Response Spectra.
% Earthquake Spectra: February 2008, Vol. 24, No. 1, pp. 173-215.

% To         = spectral period
% M          = moment magnitude
% rrup       = closest distance to fault rupture
% rjb        = Closest distance to surface projection of coseismic rupture (km)
% rx         = Horizontal distance from top of rupture measured perpendicular to fault strike (km)
% ztor       = Depth to top of coseismic rupture (km), used in AS08, CB08 and CY08
% dip        = fault dip angle
% Z1         = Depth to 1.0 km/sec velocity horizon (m) (used in AS08 and CY08)
% mechanism  = 'strike-slip','reverse'
% event      = 'mainshock','aftershock'
% Vs30       = Shear wave velocity averaged over the upper 30 m
% Vs30type   = 'measured','inferred'

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
period  = [-1 0.001 0.01	0.02	0.03	0.04	0.05	0.075   0.1	0.15	0.2	0.25	0.3	0.4	0.5	0.75 1.0 1.5 2.0 3.0 4.0 5.0 7.5 10.0]';
T_lo    = max(period(period<=To));
T_hi    = min(period(period>=To));
index   = find(abs((period - T_lo)) < 1e-6); % Identify the period

if T_lo==T_hi
    [lny,sigma,phi] = gmpe(index,M,rrup, rjb, rx, ztor, dip, Z10, mechanism, event, Vs30, Vs30type);
    tau              = sqrt(sigma.^2-phi.^2);
else
    [lny_lo,sigma_lo,sig_lo] = gmpe(index,  M,rrup, rjb, rx, ztor, dip, Z10, mechanism, event, Vs30, Vs30type);
    [lny_hi,sigma_hi,sig_hi] = gmpe(index+1,M,rrup, rjb, rx, ztor, dip, Z10, mechanism, event, Vs30, Vs30type);
    x          = log([T_lo;T_hi]);
    Y_sa       = [lny_lo,lny_hi]';
    Y_sigma    = [sigma_lo,sigma_hi]';
    Y_sig      = [sig_lo,sig_hi]';
    lny        = interp1(x,Y_sa,log(To))';
    sigma      = interp1(x,Y_sigma,log(To))';
    phi        = interp1(x,Y_sig,log(To))';
    tau        = sqrt(sigma.^2-phi.^2);
end

function[lnSa,sigma,sig]=gmpe(index,M,rrup, rjb, rx, ztor, dip, Z10, mechanism, event, Vs30, Vs30type)

switch event
    case 'mainshock', event=0;
    case 'aftershock',event=1;
end

switch Vs30type
    case 'measured', Vs30type=0;
    case 'inferred', Vs30type=1;
end

deltar=dip*pi()/180.0;
% frv   = lambda >= 30 & lambda <= 150; % frv: 1 for lambda between 30 and 150, 0 otherwise
% fnm   = lambda >= -120 & lambda <= -60; % fnm: 1 for lambda between -120 and -60, 0 otherwise
% FRV	=  Reverse-faulting factor:  0 for strike slip, normal, normal-oblique; 1 for reverse, reverse-oblique and thrust									
% FNM	=  Normal-faulting factor:   0 for strike slip, reverse, reverse-oblique, thrust and normal-oblique; 1 for normal									

switch mechanism
    case 'strike-slip',     frv = 0; fnm=0;
    case 'normal',          frv = 0; fnm=1;
    case 'normal-oblique',  frv = 0; fnm=0;
    case 'reverse',         frv = 1; fnm=0;
    case 'reverse-oblique', frv = 1; fnm=0;
    case 'thrust',          frv = 1; fnm=0;
end

HW = rx>=0;
% event = event==1;

% interpolate between periods if neccesary

C = [2.2884	0.1094	-0.0626	1.648	4.2979	5.176	0.4407	0.0207	0.0437	0.3079	2.669	-0.1166	-0.00275	-0.00625	-0.7861	-0.0699	-0.008444	5.41	0.2899	0.006718	459	0.1138	0.2539	0.2381	0.4496	0.3554	0.7504	0.0133
-1.2687	0.1	-0.255	2.996	4.184	6.16	0.4893	0.0512	0.086	0.79	1.5005	-0.3218	-0.00804	-0.00785	-0.4417	-0.1417	-0.00701	0.102151	0.2289	0.014996	580	0.07	0.3437	0.2637	0.4458	0.3459	0.8	0.0663
-1.2687	0.1	-0.255	2.996	4.184	6.16	0.4893	0.0512	0.086	0.79	1.5005	-0.3218	-0.00804	-0.00785	-0.4417	-0.1417	-0.00701	0.102151	0.2289	0.014996	580	0.07	0.3437	0.2637	0.4458	0.3459	0.8	0.0663
-1.2515	0.1	-0.255	3.292	4.1879	6.158	0.4892	0.0512	0.086	0.8129	1.5028	-0.3323	-0.00811	-0.00792	-0.434	-0.1364	-0.007279	0.10836	0.2289	0.014996	580	0.0699	0.3471	0.2671	0.4458	0.3459	0.8	0.0663
-1.1744	0.1	-0.255	3.514	4.1556	6.155	0.489	0.0511	0.086	0.8439	1.5071	-0.3394	-0.00839	-0.00819	-0.4177	-0.1403	-0.007354	0.119888	0.2289	0.014996	580	0.0701	0.3603	0.2803	0.4535	0.3537	0.8	0.0663
-1.0671	0.1	-0.255	3.563	4.1226	6.1508	0.4888	0.0508	0.086	0.874	1.5138	-0.3453	-0.00875	-0.00855	-0.4	-0.1591	-0.006977	0.133641	0.2289	0.014996	579.9	0.0702	0.3718	0.2918	0.4589	0.3592	0.8	0.0663
-0.9464	0.1	-0.255	3.547	4.1011	6.1441	0.4884	0.0504	0.086	0.8996	1.523	-0.3502	-0.00912	-0.00891	-0.3903	-0.1862	-0.006467	0.148927	0.229	0.014996	579.9	0.0701	0.3848	0.3048	0.463	0.3635	0.8	0.0663
-0.7051	0.1	-0.254	3.448	4.086	6.12	0.4872	0.0495	0.086	0.9442	1.5597	-0.3579	-0.00973	-0.0095	-0.404	-0.2538	-0.005734	0.190596	0.2292	0.014996	579.6	0.0686	0.3878	0.3129	0.4702	0.3713	0.8	0.0663
-0.5747	0.1	-0.253	3.312	4.103	6.085	0.4854	0.0489	0.086	0.9677	1.6104	-0.3604	-0.00975	-0.00952	-0.4423	-0.2943	-0.005604	0.230662	0.2297	0.014996	579.2	0.0646	0.3835	0.3152	0.4747	0.3769	0.8	0.0663
-0.5309	0.1	-0.25	3.044	4.1717	5.9871	0.4808	0.0479	0.086	0.966	1.7549	-0.3565	-0.00883	-0.00862	-0.5162	-0.3113	-0.005845	0.266468	0.2326	0.014988	577.2	0.0494	0.3719	0.3128	0.4798	0.3847	0.8	0.0612
-0.6352	0.1	-0.2449	2.831	4.2476	5.8699	0.4755	0.0471	0.086	0.9334	1.9157	-0.347	-0.00778	-0.00759	-0.5697	-0.2927	-0.006141	0.255253	0.2386	0.014964	573.9	-0.0019	0.3601	0.3076	0.4816	0.3902	0.8	0.053
-0.7766	0.1	-0.2382	2.658	4.3184	5.7547	0.4706	0.0464	0.086	0.8946	2.0709	-0.3379	-0.00688	-0.00671	-0.6109	-0.2662	-0.006439	0.231541	0.2497	0.014881	568.5	-0.0479	0.3522	0.3047	0.4815	0.3946	0.7999	0.0457
-0.9278	0.0999	-0.2313	2.505	4.3844	5.6527	0.4665	0.0458	0.086	0.859	2.2005	-0.3314	-0.00612	-0.00598	-0.6444	-0.2405	-0.006704	0.207277	0.2674	0.014639	560.5	-0.0756	0.3438	0.3005	0.4801	0.3981	0.7997	0.0398
-1.2176	0.0997	-0.2146	2.261	4.4979	5.4997	0.4607	0.0445	0.085	0.8019	2.3886	-0.3256	-0.00498	-0.00486	-0.6931	-0.1975	-0.007125	0.165464	0.312	0.013493	540	-0.096	0.3351	0.2984	0.4758	0.4036	0.7988	0.0312
-1.4695	0.0991	-0.1972	2.087	4.5881	5.4029	0.4571	0.0429	0.083	0.7578	2.5	-0.3189	-0.0042	-0.0041	-0.7246	-0.1633	-0.007435	0.133828	0.361	0.011133	512.9	-0.0998	0.3353	0.3036	0.471	0.4079	0.7966	0.0255
-1.9278	0.0936	-0.162	1.812	4.7571	5.29	0.4531	0.0387	0.069	0.6788	2.6224	-0.2702	-0.00308	-0.00301	-0.7708	-0.1028	-0.00812	0.085153	0.4353	0.006739	441.9	-0.0765	0.3429	0.3205	0.4621	0.4157	0.7792	0.0175
-2.2453	0.0766	-0.14	1.648	4.882	5.248	0.4517	0.035	0.045	0.6196	2.669	-0.2059	-0.00246	-0.00241	-0.799	-0.0699	-0.008444	0.058595	0.4629	0.005749	391.8	-0.0412	0.3577	0.3419	0.4581	0.4213	0.7504	0.0133
-2.7307	0.0022	-0.1184	1.511	5.0697	5.2194	0.4507	0.028	0.0134	0.5101	2.6985	-0.0852	-0.0018	-0.00176	-0.8382	-0.0425	-0.007707	0.031787	0.4756	0.005544	348.1	0.014	0.3769	0.3703	0.4493	0.4213	0.7136	0.009
-3.1413	-0.0591	-0.11	1.47	5.2173	5.2099	0.4504	0.0213	0.004	0.3917	2.7085	0.016	-0.00147	-0.00143	-0.8663	-0.0302	-0.004792	0.019716	0.4785	0.005521	332.5	0.0544	0.4023	0.4023	0.4459	0.4213	0.7035	0.0068
-3.7413	-0.0931	-0.104	1.456	5.4385	5.204	0.4501	0.0106	0.001	0.1244	2.7145	0.1876	-0.00117	-0.00115	-0.9032	-0.0129	-0.001828	0.009643	0.4796	0.005517	324.1	0.1232	0.4406	0.4406	0.4433	0.4213	0.7006	0.0045
-4.1814	-0.0982	-0.102	1.465	5.5977	5.202	0.4501	0.0041	0	0.0086	2.7164	0.3378	-0.00107	-0.00104	-0.9231	-0.0016	-0.001523	0.005379	0.4799	0.005517	321.7	0.1859	0.4784	0.4784	0.4424	0.4213	0.7001	0.0034
-4.5187	-0.0994	-0.101	1.478	5.7276	5.201	0.45	0.001	0	0	2.7172	0.4579	-0.00102	-0.00099	-0.9222	0	-0.00144	0.003223	0.4799	0.005517	320.9	0.2295	0.5074	0.5074	0.442	0.4213	0.7	0.0027
-5.1224	-0.0999	-0.101	1.498	5.9891	5.2	0.45	0	0	0	2.7177	0.7514	-0.00096	-0.00094	-0.8346	0	-0.001369	0.001134	0.48	0.005517	320.3	0.266	0.5328	0.5328	0.4416	0.4213	0.7	0.0018
-5.5872	-0.1	-0.1	1.502	6.193	5.2	0.45	0	0	0	2.718	1.1856	-0.00094	-0.00091	-0.7332	0	-0.001361	0.000515	0.48	0.005517	320.1	0.2682	0.5542	0.5542	0.4414	0.4213	0.7	0.0014];

Coef = C(index,:);
c1   = Coef(1);
c1a  = Coef(2);
c1b  = Coef(3);
cn   = Coef(4);
cm   = Coef(5);
c5   = Coef(6);
c6   = Coef(7);
c7   = Coef(8);
c7a  = Coef(9);
c9   = Coef(10);
c9a  = Coef(11);
c10  = Coef(12);
cy1  = Coef(13);
cy2  = Coef(14);
phi1 = Coef(15);
phi2 = Coef(16);
phi3 = Coef(17);
phi4 = Coef(18);
phi5 = Coef(19);
phi6 = Coef(20);
phi7 = Coef(21);
phi8 = Coef(22);
tau1   = Coef(23);
tau2   = Coef(24);
sigma1 = Coef(25);
sigma2 = Coef(26);
sigma3 = Coef(27);
sigma4 = Coef(28);

c2     = 1.06;
c3     = 3.45;
c4     = -2.1;
c4a    = -0.5;
crb    = 50.0;
chm    = 3.0;
cy3    = 4.0;

term1 = c1;
term2 = (c1a*frv + c1b*fnm + c7*(ztor-4))*(1-event) + (c10 + c7a*(ztor-4))*event;
term5 = c2*(M - 6);
term6 = ((c2 - c3)/cn) * log (1 + exp(cn * (cm - M)));
term7 = c4 * log(rrup + c5     * cosh(c6     * max(M - chm,0)));

term8 = (c4a - c4) * log (sqrt(rrup.^2 + crb^2));
term9 = (cy1 + cy2./cosh(max(M-cy3,0))).*rrup;
term10 = c9*HW .* tanh(rx*cos(deltar)^2/c9a).*(1-sqrt(rjb.^2+ztor.^2)./(rrup + 0.001));

Sa1130 = exp(term1 + term2 + term5 + term6 + term7 + term8 + term9 + term10);

term11 = phi1 * min(log(Vs30/1130),0);
term12 = phi2 * (exp(phi3 * (min(Vs30,1130) - 360)) - exp(phi3 * (1130 - 360))) * log((Sa1130 + phi4)/phi4);
term13 = phi5 * (1-1/cosh(phi6*max(0,Z10-phi7))) + phi8/cosh(0.15*max(0,Z10-15));

% Compute median
lnSa = log(Sa1130) + term11 + term12 + term13;

% Compute standard deviation
Finferred=(Vs30type==1); % 1: Vs30 is inferred from geology.
Fmeasured=(Vs30type==0); % 1: Vs30 is measured.
b=phi2*( exp(phi3*(min(Vs30,1130)-360))-exp(phi3*(1130-360)) );
c=phi4;
NL0=b*Sa1130./(Sa1130+c);
sig = (sigma1+(sigma2 - sigma1)/2.*(min(max(M,5),7)-5) + sigma4*event).*sqrt((sigma3*Finferred + 0.7* Fmeasured) + (1+NL0).^2);
tau = tau1 + (tau2-tau1)/2 .* (min(max(M,5),7)-5);
sigma=sqrt(((1+NL0).^2).*tau.^2+sig.^2);

