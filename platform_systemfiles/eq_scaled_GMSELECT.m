function[accSC,SaSC,SvSC,SdSC]=eq_scaled_GMSELECT(acc,T,Sa,Sv,Sd,per,Target)

if per>0
    SA  = exp(interp1(log(T),log(Sa),log(per)));
    amp = Target/SA;
end

if per==0
    PGA = max(abs(acc));
    amp = Target/PGA;
end

accSC = acc*amp;
SaSC  = Sa*amp;
SvSC  = Sv*amp;
SdSC  = Sd*amp;

