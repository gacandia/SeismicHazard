function [lny,sigma,tau,phi] = MA19(To,Mw,~,Vs30,varargin)

lny   = nan(size(Mw));
sigma = nan(size(Mw));
tau   = nan(size(Mw));
phi   = nan(size(Mw));

if To~=-4
    return
end

%% Model Coefficients
c_coef = [-0.79771	0.57546	0.48913	-0.30894	0.11076	0.18282	0.21353];
c1 = c_coef(1);
c2 = c_coef(2);
c3 = c_coef(3);
c4 = c_coef(4);
c5 = c_coef(5);
tau = c_coef(6);
phi = c_coef(7);

%% Median GMPE model for CAV (Shallow Crustal)
CAV = 9.81*exp(c1 + c2*log(PGA) + c3*Mw + c4*log(Vs30) + c5*log(Sa1));
lny   = log(CAV);
sigma = sqrt(tau^2+phi^2);