function[UHS]=uhspectrum(sa,lambda,hazardlevel)
% COMPUTES UNIFORM HAZARD SPECTRUM AT THE SPECIFIED HAZARD LEVELS

NIM = size(lambda,2);
UHS = zeros(NIM,1);

logsa     = log(sa);
loglambda = log(lambda);
loghazard = log(hazardlevel);
for i=1:NIM
    xx = loglambda(:,i);
    yy = logsa;
    ind = or(isnan(xx),isinf(xx));
    xx(ind)=[];
    yy(ind)=[];
    
    [~,ind] = unique(xx,'stable');
    xx = xx(ind);
    yy = yy(ind);
    
    if min(xx)>loghazard || max(xx)<loghazard
        fprintf('Warning: UHS used extrapolation for T = %g\n',1/exp(loghazard));
        logSA = interp1(xx,yy,loghazard,'pchip','extrap');
        UHS(i)= exp(logSA);
    else
        logSA = interp1(xx,yy,loghazard,'pchip');
        UHS(i)= exp(logSA);
    end
end



