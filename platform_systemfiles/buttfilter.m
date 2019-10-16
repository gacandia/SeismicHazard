function[filter]=buttfilter(f,param)


fch    = param(1);  % High Pass corner frequency
fcl    = param(2);  % Low Pass corner frequency
orderh = param(3);  % Order of High Pass Filter
orderl = param(4);  % Order of Low Pass Filter

FHP = 1./sqrt(1+(fch./f).^(2*orderh));
FHP(f==0)=0;
if fch==0
    FHP(f==0)=1;
end
FLP    = 1./sqrt(1+(f/fcl) .^(2*orderl));
filter = FHP.*FLP;