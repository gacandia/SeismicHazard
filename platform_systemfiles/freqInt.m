function[u,U,f]=freqInt(time,ud,n,param)

% Frequency Domain Integration of a time series
% Applies Butterworth filter correction, param = [fch fcl orderh orderl]
% where fch, fcl are the high pass / low pass corner frequencies
% and orderh and orderl the order of the filter.
% nsteps = number of points used to compute fft

% frequency vector
N   = length(time);
r   = ones(size(ud,1),1);
h   = time(2)-time(1);
f   = (0:N-1)/(h*N);
mid=ceil(N/2)+1;
f(mid:N)=f(mid:N)-1/h;
if n>0
    jw  = (1i*2*pi*f).^(-n);
    jw(1)=(1i)^(-n); %correct nyquist frequency
else
    jw = ones(size(f));
end
Ud  = fft(ud,N,2);

% Integration
if nargin==4
    filter = buttfilter(f,param);
    U  = Ud.*jw(r,:);
    U  = U.*filter;
else
    U  = Ud.*jw(r,:);
end

u  = ifft(U,N,2,'symmetric');
