function Z10=Z10_default_AS08_NGA(Vs30)

if Vs30<180
    Z10=exp(6.745);
elseif Vs30<=500
    Z10=exp(6.745-1.35*log(Vs30/180));
else
    Z10=exp(5.394-4.48*log(Vs30/500));
end
