function [rho] = none_spatial(~, h, varargin)

% No Spatial Correlation
rho = zeros(size(h));
rho(abs(h)<eps)=1;