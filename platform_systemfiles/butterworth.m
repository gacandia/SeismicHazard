function[u]=butterworth(time,u,param)

% Buttherworth Filter Parameters
N      = length(time);
f      = fftf(time);
filter = buttfilter(f,param);
r      = ones(size(u,1),1);
U      = fft(u,N,2);
u      = ifft(U.*filter(r,:),N,2,'symmetric');