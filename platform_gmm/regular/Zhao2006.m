function[lny,sigma,tau,phi]=Zhao2006(To,M,rrup,h,mechanism,Vs30)

% Zhao, J. X., Zhang, J., Asano, A., Ohno, Y., Oouchi, T.,
% Takahashi, T., ... & Fukushima, Y. (2006). Attenuation relations
% of strong ground motion in Japan using site classification based
% on predominant period. Bulletin of the Seismological Society of
% America, 96(3), 898-913.
%
% To        = spectral period
% M         = moment magnitude
% rrup      = closest distance to fault rupture
% h         = focal depth (km)
% mechanism = 'interface','intraslab'
% Vs30      = Shear wave velocity averaged over the upper 30 m

lny   = nan(size(M));
sigma = nan(size(M));
tau   = nan(size(M));
phi   = nan(size(M));

if  To<0 || To> 5
    return
end

To      = max(To,0.001); %PGA is associated to To=0.001;
period  = [0.001;0.05;0.1;0.15;0.2;0.25;0.3;0.4;0.5;0.6;0.7;0.8;0.9;1;1.25;1.5;2;2.5;3;4;5];
T_lo    = max(period(period<=To));
T_hi    = min(period(period>=To));
index   = find(abs((period - T_lo)) < 1e-6); % Identify the period

if T_lo==T_hi
    [lny,sigma,tau,phi] = gmpe(index,M,rrup,h,mechanism,Vs30);
else
    [lny_lo,sigma_lo,tau_lo] = gmpe(index,  M,rrup,h,mechanism,Vs30);
    [lny_hi,sigma_hi,tau_hi] = gmpe(index+1,M,rrup,h,mechanism,Vs30);
    x          = log([T_lo;T_hi]);
    Y_sa       = [lny_lo,lny_hi]';
    Y_sigma    = [sigma_lo,sigma_hi]';
    Y_tau      = [tau_lo,tau_hi]';
    lny        = interp1(x,Y_sa,log(To))';
    sigma      = interp1(x,Y_sigma,log(To))';
    tau        = interp1(x,Y_tau,log(To))';
    phi        = sqrt(sigma.^2-tau.^2);
end

% convert cm/s2 to g's
lny    = lny-log(980.66);


function[lny,sigma,tau,sig]=gmpe(index,M,rrup,h,mechanism,Vs30)

TABLE1 = [
    1.101  -0.00564  0.0055  1.080  0.01412  0.251   0.000  2.607  -0.528
    1.076  -0.00671  0.0075  1.060  0.01463  0.251   0.000  2.764  -0.551
    1.118  -0.00787  0.0090  1.083  0.01423  0.240   0.000  2.156  -0.420
    1.134  -0.00722  0.0100  1.053  0.01509  0.251   0.000  2.161  -0.431
    1.147  -0.00659  0.0120  1.014  0.01462  0.260   0.000  1.901  -0.372
    1.149  -0.00590  0.0140  0.966  0.01459  0.269   0.000  1.814  -0.360
    1.163  -0.00520  0.0150  0.934  0.01458  0.259   0.000  2.181  -0.450
    1.200  -0.00422  0.0100  0.959  0.01257  0.248  -0.041  2.432  -0.506
    1.250  -0.00338  0.0060  1.008  0.01114  0.247  -0.053  2.629  -0.554
    1.293  -0.00282  0.0030  1.088  0.01019  0.233  -0.103  2.702  -0.575
    1.336  -0.00258  0.0025  1.084  0.00979  0.220  -0.146  2.654  -0.572
    1.386  -0.00242  0.0022  1.088  0.00944  0.232  -0.164  2.480  -0.540
    1.433  -0.00232  0.0020  1.109  0.00972  0.220  -0.206  2.332  -0.522
    1.479  -0.00220  0.0020  1.115  0.01005  0.211  -0.239  2.233  -0.509
    1.551  -0.00207  0.0020  1.083  0.01003  0.251  -0.256  2.029  -0.469
    1.621  -0.00224  0.0020  1.091  0.00928  0.248  -0.306  1.589  -0.379
    1.694  -0.00201  0.0025  1.055  0.00833  0.263  -0.321  0.966  -0.248
    1.748  -0.00187  0.0028  1.052  0.00776  0.262  -0.337  0.789  -0.221
    1.759  -0.00147  0.0032  1.025  0.00644  0.307  -0.331  1.037  -0.263
    1.826  -0.00195  0.0040  1.044  0.00590  0.353  -0.390  0.561  -0.169
    1.825  -0.00237  0.0050  1.065  0.00510  0.248  -0.498  0.225  -0.120];

TABLE2 = [
    0.293   1.111   1.344   1.355   1.420  0.604  0.398  0.723
    0.939   1.684   1.793   1.747   1.814  0.640  0.444  0.779
    1.499   2.061   2.135   2.031   2.082  0.694  0.490  0.849
    1.462   1.916   2.168   2.052   2.113  0.702  0.460  0.839
    1.280   1.669   2.085   2.001   2.030  0.692  0.423  0.811
    1.121   1.468   1.942   1.941   1.937  0.682  0.391  0.786
    0.852   1.172   1.683   1.808   1.770  0.670  0.379  0.770
    0.365   0.655   1.127   1.482   1.397  0.659  0.390  0.766
    -0.207   0.071   0.515   0.934   0.955  0.653  0.389  0.760
    -0.705  -0.429  -0.003   0.394   0.559  0.653  0.401  0.766
    -1.144  -0.866  -0.449  -0.111   0.188  0.652  0.408  0.769
    -1.609  -1.325  -0.928  -0.620  -0.246  0.647  0.418  0.770
    -2.023  -1.732  -1.349  -1.066  -0.643  0.653  0.411  0.771
    -2.451  -2.152  -1.776  -1.523  -1.084  0.657  0.410  0.775
    -3.243  -2.923  -2.542  -2.327  -1.936  0.660  0.402  0.773
    -3.888  -3.548  -3.169  -2.979  -2.661  0.664  0.408  0.779
    -4.783  -4.410  -4.039  -3.871  -3.640  0.669  0.414  0.787
    -5.444  -5.049  -4.698  -4.496  -4.341  0.671  0.411  0.786
    -5.839  -5.431  -5.089  -4.893  -4.758  0.667  0.396  0.776
    -6.598  -6.181  -5.882  -5.698  -5.588  0.647  0.382  0.751
    -6.752  -6.347  -6.051  -5.873  -5.798  0.643  0.377  0.745];

Coeff1 = TABLE1(index,:);
Coeff2 = TABLE2(index,:);
a  = Coeff1(1);
b  = Coeff1(2);
c  = Coeff1(3);
d  = Coeff1(4);
e  = Coeff1(5);


SR = 0;
SI = 0;
SS = 0;
SSL = 0;
h  = min(h,125);
hc = 15;
deltah = (h>hc);


switch lower(mechanism)
    case 'crustal(reverse)',  SR = Coeff1(6);
    case 'interface',         SI = Coeff1(7);
    case 'intraslab',         SS = Coeff1(8); SSL = Coeff1(9);
    case 'crustal(other)'
end

if numel(Vs30)==1
    if Vs30>1100
        Ck = Coeff2(1);
    elseif and(Vs30>600,Vs30<=1100)
        Ck = Coeff2(2);
    elseif and(300<Vs30,Vs30<=600)
        Ck = Coeff2(3);
    elseif and(200<Vs30,Vs30<=300)
        Ck = Coeff2(4);
    elseif Vs30<=200
        Ck = Coeff2(5);
    end
else
    Ck                           = Coeff2(1)*M.^0;
    Ck(and(Vs30>600,Vs30<=1100)) = Coeff2(2);
    Ck(and(300<Vs30,Vs30<=600))  = Coeff2(3);
    Ck(and(200<Vs30,Vs30<=300))  = Coeff2(4);
    Ck(Vs30<=200)                = Coeff2(5);
end



r     = rrup + c*exp(d*M);
lny   = a*M+b*rrup-log(r)+e*(h-hc).*deltah + SR + SI + SS + SSL*log(rrup) + Ck;
sig   = Coeff2(6)*ones(size(M));
tau   = Coeff2(7)*ones(size(M));
sigma = sqrt(sig.^2+tau.^2);
