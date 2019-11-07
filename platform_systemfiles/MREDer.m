function[u]=MREDer(time,u,n)

time = time(:);
u    = u(:);
hmin  = max(min(diff(time))/3,0.001);
time2 = unique(time(1):hmin:time(end)+hmin)';
u2    = interp1(time,u,time2,'pchip','extrap');
Np   = length(time2);
h  = hmin;
e = ones(Np,1)/2;
A = spdiags([-e,e*0,e],[-1 0 1],Np,Np);
A(1,1:2)=[-1,1];
A(Np,Np-1:Np)=[-1,1];

for jj=1:n
    u2   = (A*u2)/h;
end

u = interp1(time2,u2,time,'pchip');
