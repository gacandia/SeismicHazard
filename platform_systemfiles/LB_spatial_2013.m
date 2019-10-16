function [rho] = LB_spatial_2013(T1,h,~)
T2=T1;

% Loth, C., & Baker, J. W. (2013). A spatial cross?correlation model
% of spectral accelerations at multiple periods. Earthquake Engineering &
% Structural Dynamics, 42(3), 397-417.

% Created by Christophe Loth, 12/18/2012
% Compute the spatial correlation of epsilons for the NGA ground motion models
%
% The function is strictly empirical, fitted over the range the range 0.01s <= T1, T2 <= 10s
%
%
% INPUT
%
%   T1, T2      = The two periods of interest. The periods may be equal,
%                 and there is no restriction on which one is larger.
%   h           = The separation distance between two sites (units of km)
%
% OUTPUT
%
%   rho         = The predicted correlation coefficient


% Verify the validity of input arguments
if min(T1,T2)<0.01
    error('The periods must be greater or equal to 0.01s')
end
if max(T1,T2)>10
    error('The periods must be less or equal to 10s')
end
if h<0
    error('The separation distance must be positive')
end
    


Tlist=[0.01 0.1 0.2 0.5 1 2 5 7.5 10.0001];

% Table II. Short range coregionalization matrix, B1
B1=[0.30 0.24 0.23 0.22 0.16 0.07 0.03 0 0;
0.24 0.27 0.19 0.13 0.08 0 0 0 0;
0.23 0.19 0.26 0.19 0.12 0.04 0 0 0;
0.22 0.13 0.19 0.32 0.23 0.14 0.09 0.06 0.04;
0.16 0.08 0.12 0.23 0.32 0.22 0.13 0.09 0.07;
0.07 0 0.04 0.14 0.22 0.33 0.23 0.19 0.16;
0.03 0 0 0.09 0.13 0.23 0.34 0.29 0.24;
0 0 0 0.06 0.09 0.19 0.29 0.30 0.25;
0 0 0 0.04 0.07 0.16 0.24 0.25 0.24];

% Table III. Long range coregionalization matrix, B2
B2=[0.31 0.26 0.27 0.24 0.17 0.11 0.08 0.06 0.05;
0.26 0.29 0.22 0.15 0.07 0 0 0 -0.03;
0.27 0.22 0.29 0.24 0.15 0.09 0.03 0.02 0;
0.24 0.15 0.24 0.33 0.27 0.23 0.17 0.14 0.14;
0.17 0.07 0.15 0.27 0.38 0.34 0.23 0.19 0.21;
0.11 0 0.09 0.23 0.34 0.44 0.33 0.29 0.32;
0.08 0 0.03 0.17 0.23 0.33 0.45 0.42 0.42;
0.06 0 0.02 0.14 0.19 0.29 0.42 0.47 0.47;
0.05 -0.03 0 0.14 0.21 0.32 0.42 0.47 0.54];

% Table IV. Nugget effect coregionalization matrix, B3
B3=[0.38 0.36 0.35 0.17 0.04 0.04 0 0.03 0.08;
0.36 0.43 0.35 0.13 0 0.02 0 0.02 0.08;
0.35 0.35 0.45 0.11 -0.04 -0.02 -0.04 -0.02 0.03;
0.17 0.13 0.11 0.35 0.2 0.06 0.02 0.04 0.02;
0.04 0 -0.04 0.20 0.30 0.14 0.09 0.12 0.04;
0.04 0.02 -0.02 0.06 0.14 0.22 0.12 0.13 0.09;
0 0 -0.04 0.02 0.09 0.12 0.21 0.17 0.13;
0.03 0.02 -0.02 0.04 0.12 0.13 0.17 0.23 0.10;
0.08 0.08 0.03 0.02 0.04 0.09 0.13 0.10 0.22];




% Find in which interval each input period is located
for i=1:length(Tlist)-1
    if T1-Tlist(i)>=0 && T1-Tlist(i+1)<0
        index1=i;
    end
    if T2-Tlist(i)>=0 && T2-Tlist(i+1)<0
        index2=i;
    end
end


% Linearly interpolate the corresponding value of each coregionalization
% matrix coefficient

B1coeff1=B1(index1,index2)+(B1(index1+1,index2)-B1(index1,index2))./...
    (Tlist(index1+1)-Tlist(index1)).*(T1-Tlist(index1));

B1coeff2=B1(index1,index2+1)+(B1(index1+1,index2+1)-B1(index1,index2+1))./...
    (Tlist(index1+1)-Tlist(index1)).*(T1-Tlist(index1));

B1coeff0=B1coeff1+(B1coeff2-B1coeff1)./...
    (Tlist(index2+1)-Tlist(index2)).*(T2-Tlist(index2));




B2coeff1=B2(index1,index2)+(B2(index1+1,index2)-B2(index1,index2))./...
    (Tlist(index1+1)-Tlist(index1)).*(T1-Tlist(index1));

B2coeff2=B2(index1,index2+1)+(B2(index1+1,index2+1)-B2(index1,index2+1))./...
    (Tlist(index1+1)-Tlist(index1)).*(T1-Tlist(index1));

B2coeff0=B2coeff1+(B2coeff2-B2coeff1)./...
    (Tlist(index2+1)-Tlist(index2)).*(T2-Tlist(index2));




B3coeff1=B3(index1,index2)+(B3(index1+1,index2)-B3(index1,index2))./...
    (Tlist(index1+1)-Tlist(index1)).*(T1-Tlist(index1));

B3coeff2=B3(index1,index2+1)+(B3(index1+1,index2+1)-B3(index1,index2+1))./...
    (Tlist(index1+1)-Tlist(index1)).*(T1-Tlist(index1));

B3coeff0=B3coeff1+(B3coeff2-B3coeff1)./...
    (Tlist(index2+1)-Tlist(index2)).*(T2-Tlist(index2));


% Compute the correlation coefficient (Equation 42)

rho=B1coeff0*exp(-3*h/20)+B2coeff0*exp(-3*h/70);

if h==0
    rho=B1coeff0*exp(-3*h/20)+B2coeff0*exp(-3*h/70)+B3coeff0;
end


end

