function [MRDpgapgv] = pIM1IM2(Mcenter, Rcenter, param,rho, im, PIM)

[NM,NR,NIM]=size(PIM);
im1 = im(:,1);
im2 = im(:,2);

[mu1,sig1,mu2,sig2]=deal(zeros(NM,NR));
tol=1e-5;
for i=1:NM
    Mi   = Mcenter(i);
    p    = param{1};
    ind  = abs(p(:,1)-Mi)<tol;
    p    = p(ind,2:end);
    p    = sortrows(p,1);
    logR = log(p(:,1));
    mu   = p(:,2);
    sig  = p(:,3);
    if size(p,1)<3
        mu2(i,:)  = mean(mu);
    else
        fitMU     = createFit(logR, mu ,'poly2');
        mu2(i,:)  = fitMU(log(Rcenter))';
    end
    
    if std(sig)<tol
        sig1(i,:) = mean(sig);
    else
        fitSIG    = createFit(logR, sig,'poly1');
        sig1(i,:) = fitSIG(log(Rcenter))';
    end
end

for i=1:NM
    Mi   = Mcenter(i);
    p    = param{2};
    ind  = abs(p(:,1)-Mi)<tol;
    p    = p(ind,2:end);
    p    = sortrows(p,1);
    logR = log(p(:,1));
    mu   = p(:,2);
    sig  = p(:,3);
    if size(p,1)<3
        mu1(i,:)  = mean(mu);
    else
        fitMU     = createFit(logR, mu ,'poly2');
        mu1(i,:)  = fitMU(log(Rcenter))';
    end
    
    if std(sig)<tol
        sig2(i,:) = mean(sig);
    else
        fitSIG    = createFit(logR, sig,'poly1');
        sig2(i,:) = fitSIG(log(Rcenter))';
    end
end

lnPGVmpga = zeros(NM,NR,NIM);
for m = 1:NIM
    lnPGVmpga(:,:,m) = mu2 + rho * sig2./sig1 .* (log(im1(m))-mu1);
end
lnPGVspga = repmat(sig2,1,1,NIM)*sqrt(1 - rho ^ 2);


dim_MRDpgapgv = [NIM, length(im2)];
MRDpgapgv = zeros(dim_MRDpgapgv);

for n = 1:length(im2)
    for m = 1:NIM
        product = 0;
        for i = 1:NR
            for j = 1:NR
                if n == 1
                    Ppgv_mrpga = normcdf2(log(im2(n) / 2 + im2(n+1) / 2), ...
                        lnPGVmpga(i,j,m),lnPGVspga(i,j,m));
                elseif n == length(im2)
                    Ppgv_mrpga = 1 - normcdf2(log(im2(n) / 2 + im2(n-1) / 2), ...
                        lnPGVmpga(i,j,m),lnPGVspga(i,j,m));
                else
                    Ppgv_mrpga = normcdf2(log(im2(n) / 2 + im2(n+1) / 2), ...
                        lnPGVmpga(i,j,m),lnPGVspga(i,j,m)) - ...
                        normcdf2(log(im2(n-1) / 2 + im2(n) / 2), ...
                        lnPGVmpga(i,j,m), lnPGVspga(i,j,m));
                end
                product = Ppgv_mrpga * PIM(i,j,m) + product;
            end
        end
        MRDpgapgv(m,n) = product;
    end
end

function [fitresult, gof] = createFit(x,y,ftype)
[xData, yData] = prepareCurveData( x, y );
ft = fittype(ftype);
[fitresult, gof] = fit( xData, yData, ft );


