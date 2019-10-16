function[SA,SV,SD]=timespec_theta(time,ugg,spec)

% -Single degree of freedom spectrum for MULTIPLE ground acceleration ugg.
%  ugg must be in units of length/time^2
%  Every row of ugg correspond to a ground motion
% -The response spectrum is calculated for each value of period
%  if period=[], the code selects them automatically

% patch to reduce execution time (crop earthquake length)
xi   = spec.damping/100;
To   = spec.T;
Nper = length(To);
dt   = mean(diff(time));
ugg    = ugg(:,1:end-1)+1/2*diff(ugg,1,2); %linear acceleration
Naccel = size(ugg,1);
SD   = zeros(Nper,Naccel);
SV   = zeros(Nper,Naccel);
SA   = zeros(Nper,Naccel);

ZEROS = sparse(Nper,Nper);
ONES  = speye(Nper);
om    = 2*pi./To;
AL    = sparse([-diag(om.^2),-2*xi*diag(om)]);
A     = [ZEROS,ONES;AL];
B     = [zeros(Nper,1);-ones(Nper,1)];
G     = sparse(expm(A*dt));
H0    = (A\(G-speye(2*Nper)))*B;
utest   = max(abs(ugg),[],1);
[~,ind] = max(utest);
Np      = sum(time<(time(ind)+2*max(To)));
for i=1:Naccel
    u = zeros(2*Nper,Np);
    ugi = ugg(i,:);
    for j=1:Np-1
        u(:,j+1)=G*u(:,j)+H0*ugi(j);
    end
    maxu = max(abs(u),[],2);
    SD(:,i) = maxu(1:Nper,:);
    SV(:,i) = maxu(Nper+1:end,:);
    u = AL*u;
    SA(:,i) = max(abs(u),[],2);
end

SA = SA';
SV = SV';
SD = SD';