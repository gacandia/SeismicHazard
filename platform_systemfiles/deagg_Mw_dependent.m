function rateD=deagg_Mw_dependent(fun,d,ky,Ts,Sa,deagg)

Nrm = size(deagg{1},1);
Nim = size(deagg,1);
lambdaSa  = zeros(Nrm,Nim);
for i=1:Nim
    lambdaSa(:,i)=deagg{i}(:,3);
end
Sa      = repmat(Sa(:)',Nrm,1);
M       = repmat(deagg{1}(:,1),1,Nim);
PD      = fun(ky,Ts,Sa,M,d,'ccdf');
rateD   = diff(-lambdaSa,1,2).*(PD(:,1:end-1)+PD(:,2:end))/2;
rateD   = sum(rateD,2);





