function [b_value,sigma_b,a_value,sigma_a]=Weichert(tper,fmag,nobs,mmin,mmax) %#ok<INUSD>

%         Weichert algorithm
%         tper: vector with length of observation period corresponding to magnitude
%         fmag: vector with central magnitude
%         nobs: number of events in magnitude increment
%         mmin: mimimum magnitude for the seismic source
%         mmax: maximum magnitude for the seismic source
%         mrate: reference magnitude
%         bval: initial value for b-value
%         itstab: stabilisation tolerance
%         maxiter: Maximum number of iterations
%         returns: b-value, sigma_b, a-value, sigma_a
%
% mrate=0.0;
bval=1.0;
itstab=1E-5;
maxiter=1000;

beta=bval*log(10);
% d_m=fmag(2)-fmag(1);
itbreak = 0;
snm = sum(nobs .* fmag);
nkount = sum(nobs);
iteration = 1;

while (itbreak ~= 1)
    beta_exp=exp(-beta * fmag);
    tjexp = tper .* beta_exp;
    tmexp = tjexp .* fmag;
    sumexp = sum(beta_exp);
    stmex = sum(tmexp);
    sumtex =sum(tjexp);
    stm2x = sum(fmag.* tmexp);
    dldb = stmex / sumtex;
    if isnan(stmex)||isnan(sumtex)
        msgbox('NaN occurs in Weichert iteration');
        return
    end
    
    d2ldb2 = nkount * ((dldb^2.0) - (stm2x/sumtex));
    dldb = (dldb * nkount) - snm;
    betl = beta;
    beta = beta - (dldb/d2ldb2);
    sigbeta = sqrt(-1. / d2ldb2);
    
    if abs(beta - betl) <= itstab
        %Iteration has reached convergence
        bval = beta /log(10.0);
        sigb = sigbeta/log(10.0); %confirm with Norm
        fngtm0 = nkount*(sumexp/sumtex);
        %fn0 = fngtm0*exp((beta) * (fmag(1)-(d_m / 2.0)));
%         fact= (exp(-beta*(fmag(1)-mmin))-exp(-beta*(mmax-mmin)))/(1-exp(-beta*(mmax-mmin)));
        fact=1;%activate to fix everithing respect the minimum magnitude
        v=fngtm0/fact;%this is v in equation 4.7 and 4.10 (Kramer book)
        alpha=log(v)+beta*mmin;
        a_m=alpha/log(10);
        %a_m = fngtm0*exp((-beta) * (mrate -(fmag(1) - (d_m/2.0))));%alternative as openquake,seems wrong
        itbreak = 1;
    else
        iteration= iteration+1;
        if iteration > maxiter
            msgbox('Maximum Number of Iterations reached');
            return
        end
    end
end

b_value=bval;
sigma_b=sigb;
a_value=a_m;
sigma_a= a_m/sqrt(nkount);
