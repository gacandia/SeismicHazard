function [lny,sigma,tau,phi] = Macedo2019(T,M,Rrup,func,mechanism,Vs30,varargin)

% Conditional Model for Arias Intensity
% M         = Moment magnitude
% func      = function handle to Sa model
% mechanism = 1 for interface earthquakes
%             2 for intraslab earthquakes
% un        = units of IM
% Vs30      = Avg. Shear wave velocity
% varargin  = input parameters that follow T in the matlab function that
%              runs the Sa GMPE

if T~=-5
    lny   = nan(size(M));
    sigma = nan(size(M));
    tau   = nan(size(M));
    phi   = nan(size(M));
    %IM    = IM2str(T);
    %h=warndlg(sprintf('GMPE %s not available for %s',mfilename,IM{1}));
    %uiwait(h);
    return
end

REGION='south-america';

switch mechanism
    case 'interface'
        switch REGION
            case 'global'       , c1 = 0.85; c2 =-0.36; c3 = 0.53; c4 = 1.54; c5 = 0.17; phi = 0.30; tau = 0.18;
            case 'japan'        , c1 = 0.98; c2 =-0.38; c3 = 0.53; c4 = 1.54; c5 = 0.17; phi = 0.30; tau = 0.16;
            case 'taiwan'       , c1 = 0.75; c2 =-0.35; c3 = 0.53; c4 = 1.54; c5 = 0.17; phi = 0.27; tau = 0.15;
            case 'south-america', c1 = 0.95; c2 =-0.36; c3 = 0.53; c4 = 1.54; c5 = 0.17; phi = 0.32; tau = 0.19;
            case 'new-zeeland'  , c1 = 0.82; c2 =-0.36; c3 = 0.53; c4 = 1.54; c5 = 0.17; phi = 0.28; tau = 0.17;
        end
        s1 = 0.130;
        s2 = 2.370;
        s3 = 0.030;
        s4 = 0.270;
    case 'intraslab'
        switch REGION
            case 'global'       , c1 = -0.74; c2 =-0.24; c3 = 0.66; c4 = 1.58; c5 = 0.14; phi = 0.28; tau = 0.16;
            case 'japan'        , c1 = -0.22; c2 =-0.32; c3 = 0.66; c4 = 1.58; c5 = 0.14; phi = 0.26; tau = 0.15;
            case 'taiwan'       , c1 = -1.02; c2 =-0.20; c3 = 0.66; c4 = 1.58; c5 = 0.14; phi = 0.29; tau = 0.17;
            case 'south-america', c1 = -0.75; c2 =-0.24; c3 = 0.66; c4 = 1.58; c5 = 0.14; phi = 0.30; tau = 0.14;
            case 'new-zeeland'  , c1 = -0.84; c2 =-0.22; c3 = 0.66; c4 = 1.58; c5 = 0.14; phi = 0.30; tau = 0.13;
        end
        
        s1 = 0.190;
        s2 = 2.500;
        s3 = 0.020;
        s4 = 0.230;        
    otherwise %temporary code used, we need shallow crustal coefficients or migrate to another GMM
        c1 = 0.95;
        c2 =-0.36;
        c3 = 0.53;
        c4 = 1.54;
        c5 = 0.17;
        
        s1 = 0.130;
        s2 = 2.370;
        s3 = 0.030;
        s4 = 0.270;
        
        phi = 0.30;
        tau = 0.19;        
        
end

[lnPGA,sPGA]  = func(0,varargin{:}); % evaluates GMM for PGA
[lnSa1,sSa1]  = func(1,varargin{:}); % evaluates GMM for Sa(T=1)

% evaluates conditional GMM
lny   = c1+c2*log(Vs30)+c3*M+c4*lnPGA+c5*lnSa1;
sigma = sqrt(s1+s2*sPGA.^2+s3*sSa1.^2+s4*sPGA.*sSa1);

