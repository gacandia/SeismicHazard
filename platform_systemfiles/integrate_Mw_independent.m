function hd=integrate_Mw_independent(fun,d,ky,Ts,Sa,lambda)

Nd   = length(d);
hd   = zeros(1,Nd);

for i=1:Nd
    di    = d(i);
    PD    = fun(ky,Ts,Sa,di,'ccdf');
    hd(i) = -trapz(lambda,PD);
end




