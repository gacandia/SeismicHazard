function[SA,SV,SD]=freqspec(time,udd,spec,filteroptions)

% -Single degree of freedom spectrum for MULTIPLE ground acceleration ugg calculated in the frequency domain.
%  ugg must be in units of length/time^2
%  Every row of ugg correspond to a ground motion
% -The response spectrum is calculated for each period

% Pads with zeros
xi   = spec.damping/100;
To   = spec.T;
Nper = length(To);
N    = size(udd,2);
f    = fftf(time);
w    = 2*pi*f;
wo   = 2*pi./To;
SA   = nan(1,Nper);
SV   = SA;
SD   = SA;

if nargin==4
    fch = filteroptions(1);
    fcl = filteroptions(2);
    if and(fch==0,isinf(fcl))
        Ug   = fft(udd,N,2);
    else
        filter = buttfilter(f,filteroptions);
        Ug     = fft(udd,N,2).*filter;
    end
else
    Ug   = fft(udd,N,2);
end

for j=1:Nper
    % transfer functiob
    H   = -1./(wo(j)^2-w.^2+2*1i*xi*wo(j)*w);
    U     = H.*Ug;
    
    if nargout>1
        % displacement response
        u     = ifft(U  ,N,2,'symmetric');
        SD(j) = max(abs(u)  ,[],2);

        % velocity response
        UD    = (1i*w).^1 .* U;
        ud    = ifft(UD,N,2,'symmetric');
        SV(j) = max(abs(ud) ,[],2);
    end
    
    % acceleration response
    UDD   = (1i*w).^2 .* U;
    udd   = ifft((UDD+Ug),N,2,'symmetric');
    SA(j) = max(abs(udd),[],2);
end

