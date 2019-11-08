function hd=integrate_Mw_dependent(fun,d,ky,Ts,Sa,deagg,optimizeD)

switch optimizeD
    case 'on' %modo macedo (fast, very accurate)
        lambda = zeros(size(deagg));
        for i=1:length(deagg)
            lambda(i)=nansum(deagg{i}(:,3));
        end
        applyCorr = false;
        [Sa,Mag,deriv,Deag]=PSHA2PSDA(deagg,Sa,lambda,applyCorr);
        Nrm       = size(Mag,1);
        Nim       = size(Sa ,2);
        roc       = repmat(deriv,Nrm,1);
        Sa        = repmat(Sa,Nrm,1);
        M         = repmat(Mag,1,Nim);
        Nd        = length(d);
        hd        = zeros(1,Nd);
        for i=1:Nd
            di      = d(i);
            PD      = fun(ky,Ts,Sa,M,di,'ccdf');
            dlambda = nansum((roc.*PD).*(Deag/100),2);
            hd(i)   = sum(dlambda(:));
        end
        
    case 'off' %mode gabriel (slow, but exact)
        Nrm = size(deagg{1},1);
        Nim = size(deagg,1);
        lambdaSa  = zeros(Nrm,Nim);
        for i=1:Nim
            lambdaSa(:,i)=deagg{i}(:,3);
        end
        Sa   = repmat(Sa(:)',Nrm,1);
        M    = repmat(deagg{1}(:,1),1,Nim);
        Nd      = length(d);
        hd = zeros(1,Nd);
        for i=1:Nd
            di      = d(i);
            PD      = fun(ky,Ts,Sa,M,di,'ccdf');
            rateD   = diff(-lambdaSa,1,2).*(PD(:,1:end-1)+PD(:,2:end))/2;
            dlambda = sum(rateD,2);
            hd(i)   = sum(dlambda);
        end
end



