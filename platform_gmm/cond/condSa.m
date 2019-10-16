function [lny,sigma,tau,sig] = condSa(T,M,func,mechanism,varargin)

% T         = 1; %not used
% M         = Moment magnitude
% func      = function handle to Sa model
% mechanism = 1 for interface earthquakes
%             2 for intraslab earthquakes
% varargin  = input parameters that follow T in the matlab function that
%              runs the Sa GMPE

if T~=1
    lny    = nan(size(M));
    sigma  = nan(size(M));
    tau    = nan(size(M));
    sig    = nan(size(M));
    %IM     = IM2str(T);
    %h=warndlg(sprintf('GMPE %s not available for %s',mfilename,IM{1}));
    %uiwait(h);
    return
end

rho  = 0.5;   % assumed correlation coefficient between Sa(1) and PGA
[lnyi,sigmai,tau,sig]  = func(T,varargin{:});
lny   = lnyi;
sigma = sigmai*sqrt(1-rho^2);


