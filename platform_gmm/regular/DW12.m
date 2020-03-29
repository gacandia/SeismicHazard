function [lny,sigma,tau,phi] = DW12(T,Mw,Rrup,mechanism, media)

% Du, W. and Wang, G. (2013), A simple ground?motion prediction model 
% for cumulative absolute velocity and model validation. 
% Earthquake Engng Struct. Dyn., 42: 1189-1202. 
% DOI: https://doi.org/10.1002/eqe.2266

lny   = nan(size(Mw));
sigma = nan(size(Mw));
tau   = nan(size(Mw));
phi   = nan(size(Mw));

if T~=-4
    return
end

% model coefficients
c1 =  1.826;
c2 = -0.130;
c3 = -1.403;
c4 =  0.098;
c5 =  0.286;
h  =  8.455;
c6 =  0.481;
c7 = -0.155;
c8 =  0.095;


switch mechanism
    case 'strike-slip',     FR = 0;   FN=0;
    case 'normal',          FR = 0;   FN=1;
    case 'normal-oblique',  FR = 0;   FN=1;
    case 'reverse',         FR = 1;   FN=0;
    case 'reverse-oblique', FR = 0.5; FN=0;
    case 'thrust',          FR = 0;   FN=0;
end


switch media % SGS site category 
    case 'sgs-b', SC = 0; SD = 0; 
    case 'sgs-c', SC = 1; SD = 0; 
    case 'sgs-d', SC = 0; SD = 1;  
end

% median model in units of gs
lny = c1 + c2*(8.5-Mw).^2 + (c3+c4*Mw).*log(sqrt(Rrup.^2+h^2)) + c5*SC + c6*SD + c7*FN + c8*FR;

% standard deviation model
CAV   = exp(lny);
sigma = 0.45-0.042*log(CAV/0.02);
sigma(CAV<=0.15) = 0.45;
sigma(CAV>=1.00) = 0.37;

tau = 0.247;
phi = sqrt(sigma.^2-tau^2);

% g-sec to m/s
lny = lny + log(9.8066);




