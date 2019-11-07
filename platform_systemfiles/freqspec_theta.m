function[SA,SV,SD]=freqspec_theta(time,udd,spec)

% -Single degree of freedom spectrum for MULTIPLE ground acceleration ugg
% calculated in the frequency domain.
%  ugg must be in units of length/time^2
%  Every row of ugg correspond to a ground motion
% -The response spectrum is calculated for each value of period

% Pads with zeros
xi   = spec.damping/100;
To   = spec.T;
Nper = length(To);
[Neq,N] = size(udd);
f    = fftf(time);
w    = 2*pi*f;
wo   = 2*pi./To;
SA   = nan(Neq,Nper);
SV   = SA;
SD   = SA;

Ug  = fft(udd,N,2);
SA  = zeros(Neq,Nper);

if nargout>1
    SV = zeros(Neq,Nper);
    SD = zeros(Neq,Nper);
end

for j=1:Nper
    H  = -1./(wo(j)^2-w.^2+2*1i*xi*wo(j)*w);
    U  = bsxfun(@times,Ug,H);
    if nargout>1
        UD  = bsxfun(@times,1i*w,U);
        ud  = ifft(UD,N,2,'symmetric');
        SV(:,j) = max(abs(ud),[],2);
        
        u   = ifft(U,N,2,'symmetric');
        SD(:,j) = max(abs(u),[],2);
    end
    
    UDD = bsxfun(@times,-w.^2,U);
    udd = ifft(UDD+Ug,N,2,'symmetric');
    SA(:,j) = max(abs(udd),[],2);
    
end

