function [rho] = SR_spatial_2019(T,h,~)

% Spatial Correlation model based on 8 strong motions using the SIBER RISK
% dataset
% Eq subset : eq1     eq2     eq3     eq4     eq5     eq6     eq7     eq8
% Event     :  47      44      79      17      28      66      54      85
% Records   :  31      30      29      24      22      22      20      20
% Mag       : 8.4     6.8     7.6     6.7     7.6     6.4     6.4     6.0

T    = max(T,0.01); % PGA is treated as T=0.01; 
b    = 110*T^0.13;
gama = 1-exp(-3*h/b);
rho = 1-gama;

