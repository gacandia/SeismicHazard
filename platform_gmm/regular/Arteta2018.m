function[lny,sigma,tau,phi]=Arteta2018(To,M,Rhyp,media,region)

% Ground Motion Prediction Equation for Deep Subduction Earthquakes in Colombia
% Carlos A. Arteta, Cesar A. Pajaro, Carlos Lozano, Anibal E.
% Ojeda, Norman A. Abrahamson.
%
% To        = spectral period
% M         = moment magnitude
% rhyp      = closest distance to rupture plane
% mechanism = 'interface' 'intraslab'
lny   = nan(size(M));
sigma = nan(size(M));
tau   = nan(size(M));
phi   = nan(size(M));

if  To<0 || To> 10
    return
end

To      = max(To,0.01); %PGA is associated to To=0.01;
period  = [0.01;0.02;0.05;0.075;0.1;0.15;0.2;0.25;0.3;0.4;0.5;0.6;0.75;1;1.5;2;2.5;3;4;5;6;7.5;10];
T_lo    = max(period(period<=To));
T_hi    = min(period(period>=To));
index   = find(abs((period - T_lo)) < 1e-6); % Identify the period

if T_lo==T_hi
    [lny,sigma,tau,phi] = gmpe(index,M,Rhyp,media,region);
else
    [lny_lo,sigma_lo,tau_lo] = gmpe(index,  M,Rhyp,media,region);
    [lny_hi,sigma_hi,tau_hi] = gmpe(index+1,M,Rhyp,media,region);
    x          = log([T_lo;T_hi]);
    Y_sa       = [lny_lo,lny_hi]';
    Y_sigma    = [sigma_lo,sigma_hi]';
    Y_tau      = [tau_lo,tau_hi]';
    lny        = interp1(x,Y_sa,log(To))';
    sigma      = interp1(x,Y_sigma,log(To))';
    tau        = interp1(x,Y_tau,log(To))';
    phi        = sqrt(sigma.^2-tau.^2);
end

function[lnSa,sigma,tau,phi]=gmpe(index,M,Rhyp,media,region)

[th1,th2,th3GL,th4,th5,th6,tau,phi]=getcoefs(index);

% FSITE
switch media
    case 'rock' , Fsite = 0; 
    case 'soil' , Fsite = 1;
end
% FFABA
switch region
    case 'forearc', FFABA = 0; 
    case 'backarc', FFABA = 1;
end

% fmagGL y fmagREG
fmagGL = M*0;
ind    = (M<=6.5);
fmagGL(ind) = 0.8*(M(ind)-6.5);
fmagREG = th2*(10-M).^2;

% fpathGL y fpathREG
fpathGL  = (th3GL+0.1*(M-7.8)).*log(Rhyp+10*exp(0.4*(M-6)));
fpathREG = th4*Rhyp;

% regresion model
lnSa = th1+fmagGL+fmagREG+fpathGL+fpathREG+th5*Fsite+th6*FFABA;

% STANDARD DEVIATION
tau   = tau*ones(size(lnSa));
phi   = phi*ones(size(lnSa));
sigma = sqrt(tau.^2+phi.^2);

function[th1,th2,th3GL,th4,th5,th6,tau,phi,sig,phis2s,phiss,sigss]=getcoefs(index)

COEFF =[
    3.7799  0.0000 -1.350 -0.00032  0.802 -1.2158  0.385  0.806  0.893  0.617  0.524  0.650
    3.8081  0.0000 -1.350 -0.00032  0.787 -1.2126  0.392  0.804  0.895  0.616  0.522  0.653
    4.2673  0.0000 -1.400 -0.00032  0.658 -1.3313  0.376  0.824  0.906  0.625  0.537  0.655
    4.7719  0.0000 -1.450 -0.00032  0.572 -1.3958  0.387  0.853  0.937  0.670  0.523  0.651
    5.0129  0.0000 -1.450 -0.00032  0.542 -1.4270  0.401  0.895  0.980  0.715  0.509  0.648
    5.2413  0.0000 -1.450 -0.00032  0.584 -1.4061  0.415  0.911  1.001  0.738  0.517  0.663
    4.9622  0.0000 -1.400 -0.00032  0.722 -1.3255  0.403  0.887  0.975  0.700  0.556  0.687
    4.6000  0.0000 -1.350 -0.00032  0.910 -1.2646  0.365  0.846  0.921  0.674  0.544  0.655
    4.1906 -0.0003 -1.280 -0.00032  1.037 -1.2148  0.399  0.832  0.923  0.650  0.553  0.682
    3.6431 -0.0021 -1.197 -0.00029  1.197 -1.1362  0.417  0.804  0.906  0.640  0.539  0.681
    3.2184 -0.0059 -1.133 -0.00028  1.282 -1.0753  0.383  0.892  0.970  0.715  0.582  0.696
    2.8715 -0.0117 -1.081 -0.00031  1.293 -1.0255  0.380  0.946  1.019  0.735  0.617  0.725
    2.4468 -0.0242 -1.016 -0.00042  1.223 -0.9646  0.371  0.923  0.994  0.700  0.620  0.722
    1.8993 -0.0419 -0.934 -0.00085  1.099 -0.8859  0.320  0.905  0.960  0.637  0.656  0.730
    1.1277 -0.0671 -0.817 -0.00143  0.976 -0.7753  0.334  0.837  0.901  0.621  0.592  0.680
    0.5802 -0.0844 -0.734 -0.00189  0.906 -0.6967  0.351  0.810  0.883  0.617  0.569  0.668
    0.1555 -0.0988 -0.670 -0.00220  0.852 -0.6358  0.286  0.824  0.872  0.611  0.572  0.639
    -0.1915 -0.1106 -0.640 -0.00243  0.825 -0.5859  0.274  0.831  0.875  0.602  0.577  0.639
    -0.7390 -0.1292 -0.580 -0.00271  0.810 -0.5271  0.307  0.821  0.876  0.593  0.582  0.658
    -1.1636 -0.1419 -0.540 -0.00286  0.824 -0.5125  0.391  0.835  0.922  0.550  0.627  0.738
    -1.5724 -0.1486 -0.500 -0.00294  0.852 -0.5122  0.464  0.863  0.980  0.579  0.641  0.791
    -2.2162 -0.1533 -0.460 -0.00298  0.906 -0.5122  0.525  0.925  1.063  0.623  0.663  0.845
    -3.1750 -0.1533 -0.400 -0.00298  1.007 -0.5122  0.581  1.008  1.163  0.718  0.671  0.888];

Coeff  = COEFF(index,:);
th1    = Coeff(1);
th2    = Coeff(2);
th3GL  = Coeff(3);
th4    = Coeff(4);
th5    = Coeff(5);
th6    = Coeff(6);
tau    = Coeff(7);
phi    = Coeff(8);
sig    = Coeff(9);
phis2s = Coeff(10);
phiss  = Coeff(11);
sigss  = Coeff(12);
