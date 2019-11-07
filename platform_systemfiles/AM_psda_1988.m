function[varargout]=AM_psda_1988(ky,~,im,varargin)

% ky = yield acceleration
% im = PGA, intensity measure
%
% Reference:
% Ambraseys, N. N., & Menu, J. M. (1988). Earthquake-induced ground 
% displacements. Earthquake engineering & structural dynamics, 
% 16(7), 985-1006.
%
%
%------------------------------------------------------------
im    = max(im,ky+eps);
aratio = ky./im;
%------------------------------------------------------------
%mu    = displacement in cm;
logEDP = 0.9+log10(((1-aratio).^2.53).*(aratio.^(-1.09)));
logsig = 0.30;
lnEDP  = logEDP *log(10);
sig    = logsig*log(10)*ones(size(lnEDP));

if nargin==3
    % empty varargin returns medium values and the standard deviation
    varargout{1}=lnEDP;
    varargout{2}=sig;
    return
end

y    = varargin{1};
dist = varargin{2};
if strcmp(dist,'pdf')
    varargout{1} = lognpdf(y,lnEDP,sig);
elseif strcmp(dist,'cdf')
    varargout{1} = logncdf(y,lnEDP,sig);
elseif strcmp(dist,'ccdf')
    varargout{1} = 1-logncdf(y,lnEDP,sig);
end
