function [mu,sig,tau,phi]=franky(T,varargin)

Ndepend  = length(varargin)/3;
ind3     = (1:Ndepend)+Ndepend;
iptrs    = getIMptrs(T,varargin(ind3));
gmpefun  = varargin{iptrs};
ind4     = iptrs+2*Ndepend;
param    = varargin{ind4};
[mu,sig,tau,phi] = gmpefun(T,param{:});

