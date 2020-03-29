function[lny,sigma,tau,phi]=Garcia2005(To,M,Rrup,Rhyp,H,direction)

% To        = spectral period
% M         = moment magnitude
% rrup      = closest distance to rupture plane
% rhyp      = distance to hypocenter
% H         = focal depth
% mechanism = 'horizontal' or 'vertical'
lny   = nan(size(M));
sigma = nan(size(M));
tau   = nan(size(M));
phi   = nan(size(M));

if  and(To<0 || To> 5,To~=-1)
    return
end

if To>=0
   To      = max(To,0.01); %PGA is associated to To=0.01;
end

period  = [-1;0.01;1/25;1/20;1/13.33;1/10;1/5;1/3.33;1/2.5;1/2;1/1.33;1/1;1/0.67;1/0.5;1/0.33;1/0.25;1/0.2];
T_lo    = max(period(period<=To));
T_hi    = min(period(period>=To));
index   = find(abs((period - T_lo)) < 1e-6); % Identify the period

if T_lo==T_hi
    [log10y,sigma,tau,phi] = gmpe(index,M,Rrup,Rhyp,H,direction);
else
    [log10y_lo,sigma_lo,tau_lo] = gmpe(index,  M,Rrup,Rhyp,H,direction);
    [log10y_hi,sigma_hi,tau_hi] = gmpe(index+1,M,Rrup,Rhyp,H,direction);
    x          = log([T_lo;T_hi]);
    Y_sa       = [log10y_lo,log10y_hi]';
    Y_sigma    = [sigma_lo,sigma_hi]';
    Y_tau      = [tau_lo,tau_hi]';
    log10y        = interp1(x,Y_sa,log(To))';
    sigma      = interp1(x,Y_sigma,log(To))';
    tau        = interp1(x,Y_tau,log(To))';
    phi        = sqrt(sigma.^2-tau.^2);
end

% log base convertion
lny   = log10y * log(10);
sigma = sigma  * log(10);
tau   = tau    * log(10);
phi   = phi    * log(10);

% convert cm/s2 to g's, and keeps cm/s for PGV
if To==-1
    lny    = lny - log(100);
end

if To>=0
    lny    = lny - log(980.66);
end


function[log10y,sigma,tau,phi]=gmpe(index,M,Rrup,Rhyp,H,direction)

switch direction
    case 'horizontal'
        Coef = [-2.4	0.71	-0.0023	1	0.004	0.26	0.24	0.09
            -0.2	0.59	-0.0039	1	0.008	0.28	0.27	0.1
            0.03	0.59	-0.0043	1	0.007	0.32	0.31	0.08
            0.1	0.58	-0.0043	1	0.008	0.34	0.32	0.09
            0.2	0.57	-0.0043	1	0.008	0.34	0.32	0.1
            0.4	0.55	-0.0041	1	0.008	0.33	0.32	0.1
            0.05	0.59	-0.0037	1	0.007	0.28	0.24	0.14
            -0.3	0.63	-0.0033	1	0.005	0.28	0.23	0.16
            -0.6	0.64	-0.0028	1	0.005	0.27	0.24	0.13
            -0.8	0.67	-0.0024	1	0.004	0.26	0.24	0.11
            -1.3	0.71	-0.002	1	0.004	0.27	0.26	0.09
            -1.7	0.75	-0.0017	1	0.003	0.28	0.26	0.09
            -2.3	0.81	-0.0014	1	0.002	0.28	0.26	0.1
            -2.7	0.85	-0.0012	1	0.001	0.26	0.24	0.1
            -3.3	0.89	-0.0009	1	0.0009	0.26	0.22	0.14
            -3.9	0.94	-0.0008	1	0.0009	0.25	0.22	0.12
            -4.3	0.97	-0.0007	1	0.001	0.25	0.22	0.12];
    case 'vertical'
        Coef=[-2.4	0.7	-0.0018	1	0.002	0.24	0.21	0.11
            -0.4	0.6	-0.0036	1	0.006	0.27	0.25	0.11
            -0.3	0.62	-0.0041	1	0.006	0.31	0.3	0.07
            -0.2	0.62	-0.0043	1	0.007	0.32	0.31	0.08
            -0.06	0.6	-0.0041	1	0.007	0.32	0.31	0.09
            -0.04	0.59	-0.0039	1	0.007	0.31	0.29	0.11
            -0.07	0.59	-0.0033	1	0.004	0.26	0.22	0.14
            -0.2	0.6	-0.0029	1	0.003	0.26	0.22	0.15
            -0.7	0.64	-0.0022	1	0.003	0.26	0.23	0.13
            -0.9	0.66	-0.0018	1	0.002	0.26	0.23	0.11
            -1.3	0.69	-0.0014	1	0.002	0.25	0.22	0.11
            -1.8	0.75	-0.001	1	0.001	0.27	0.24	0.12
            -2.4	0.8	-0.0008	1	0.0004	0.26	0.23	0.12
            -2.8	0.83	-0.0006	1	-0.0005	0.27	0.24	0.14
            -3.3	0.88	-0.0005	1	-0.0004	0.28	0.23	0.17
            -4	0.95	-0.0004	1	-0.0003	0.27	0.23	0.15
            -4.4	0.98	-0.0003	1	-0.0002	0.26	0.22	0.14
            ];
end

c1 = Coef(index,1);
c2 = Coef(index,2);
c3 = Coef(index,3);
c4 = Coef(index,4);
c5 = Coef(index,5);
sr = Coef(index,7);
se = Coef(index,8);

Rcld         = Rrup;
Rcld(M<=6.5) = Rhyp(M<=6.5);
Delta        = 0.00750*10.^(0.507*M);
R            = sqrt(Rcld.^2+Delta.^2);
log10y       = c1+c2*M+c3*R-c4*log10(R)+c5*H;
tau          = se*ones(size(M));
phi          = sr*ones(size(M));
sigma        = sqrt(tau.^2+phi.^2);
