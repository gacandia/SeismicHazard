function [A]=rupRelation(M,epsilon,Amax,model,varargin)

switch lower(model)
    case 'custom'
        % logA=a*M-b + sigma*epsilon
        param  = varargin{1};
        a      = param(1);
        b      = param(2);
        sigma  = param(3);
        logA   = a*M-b+sigma*epsilon;
        A      = 10.^logA;
        
    case 'ellsworth'
        a=1.00; b =4.20; sigma = 0.12;
        logA   = (M-b-sigma*epsilon)/a;
        A      = 10.^logA;
        
    case 'hanksbakun2001'
        a=1.00; b =3.98; sigma = 0.12; a2=4/3; b2= 3.09;
        log10A  = (M-b -sigma*epsilon)/a;
        log10A2 = (M-b2-sigma*epsilon)/a2; A2  = 10.^log10A2;
        A      = 10.^log10A;
        ind    = (A>468);
        A(ind) = A2(ind);
        
    case 'somerville1999'
        a=1.00; b =3.95; sigma = 0.12;
        logA   = (a*M-b-sigma*epsilon)/a;
        A      = 10.^logA;
        
    case {'wc1994','wellscoppersmith1994'}
        a=0.98; b =4.07; sigma = 0.24;
        logA   = (M-b-sigma*epsilon)/a;
        A      = 10.^logA;
        
    case 'wellscoppersmithr1994'
        a=0.90; b =4.33; sigma = 0.25;
        logA   = (M-b-sigma*epsilon)/a;
        A      = 10.^logA;
        
    case 'wellscoppersmithss1994'
        a=1.02; b =3.94; sigma = 0.23;
        logA   = (M-b-sigma*epsilon)/a;
        A      = 10.^logA;
        
    case 'strasser2010'
        a=0.846; b =4.441; sigma = 0.286;
        logA   = (M-b-sigma*epsilon)/a;
        A      = 10.^logA;
        
    case 'ucerf2'
        a = 400/1711;
        b = 5000/363;
        A = (a*M).^b;
end

% A = min(A,Amax);