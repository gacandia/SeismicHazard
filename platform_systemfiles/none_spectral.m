function [rho] = none_spectral(T1,T2,~)

% No Spectral Correlation
rho = zeros(size(T2));
rho(abs(T1-T2)<eps)=1;