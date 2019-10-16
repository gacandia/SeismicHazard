function[f,U]=Fou(tau,u,do_simple)

% tau = dt or time vector. Either way.
% Frequency Domain Integration of a time series
% Applies Butterworth filter correction, param = [fch fcl orderh orderl]
% where fch, fcl are the high pass / low pass corner frequencies
% and orderh and orderl the order of the filter.
% nsteps = number of points used to compute fft

% frequency vector
N   = length(u);
if length(tau)==1
    h = tau;
else
    h   = tau(2)-tau(1);
end
f   = (0:N-1)/(h*N);
mid=ceil(N/2)+1;
f(mid:N)=f(mid:N)-1/h;
U   = fft(u,N,2);

if nargin==3
   if do_simple==1
      ind = (f<=0);
      f (:,ind)=[];
      U (:,ind)=[]; 
      U = abs(U);
   end
end
