function[SA,SV,SD]=timespec(time,ugg,spec,filteroptions)

%  ugg must be dimensionless (normalized acceleration)
%  Every row of ugg correspond to a ground motion
% -The response spectrum is calculated for each value of period
%  if period=[], the code selects them automatically

% patch to reduce execution time (crop earthquake length)
xi   = spec.damping/100;
To   = spec.T;
Nper = length(To);
dt   = mean(diff(time));

if nargin==4
    fch = filteroptions(1);
    fcl = filteroptions(2);
    if or(fch>0,~isinf(fcl))
        f      = fftf(time);
        filter = buttfilter(f,filteroptions);
        N      = size(ugg,2);
        UDD    = fft(ugg,N,2);
        ugg    = ifft(UDD.*filter,N,2,'symmetric');
    end
end

ugg   = ugg(:,1:end-1)+1/2*diff(ugg,1,2); %linear acceleration
ZEROS = zeros(Nper,Nper);
ONES  = eye(Nper);
om    = 2*pi./To;
AL    = [-diag(om.^2),-2*xi*diag(om)];
A     = [ZEROS,ONES;AL];
B     = [zeros(Nper,1);-ones(Nper,1)];
G     = expm(A*dt);
H0    = (A\(G-eye(2*Nper)))*B;
Np    = length(time);


u = zeros(2*Nper,Np);
for j=1:Np-1
    u(:,j+1)=G*u(:,j)+H0*ugg(j);
end

if nargout>1
    maxu    = max(abs(u),[],2);
    SD      = maxu(1:Nper)';
    SV      = maxu(Nper+1:end)';
end
u       = AL*u;
SA      = max(abs(u),[],2)';
