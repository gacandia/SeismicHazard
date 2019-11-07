function [kvk,MRDkvkm] = computeMRDkmkv (Ts, Tm, im, MRD,rho)
% clearvars
% clc
% close all
% 
% load mydata Ts Tm opt MRD
PGVz    = im(:,1); kvmaxz  = PGVz;
PGAz    = im(:,2); kmaxz   = PGAz;
kvk     = im;
sigk    = 0.25;
sigkv   = 0.25;
sigkvk  = sigkv * sqrt(1-rho^2);%sig_lnkvmaxkmax;

Nim     = length(PGAz);
Pkmax   = zeros(Nim,Nim);
lnkvmax = zeros(Nim,Nim,Nim);
MRDkvkm = zeros(Nim,Nim);

if Ts / Tm > 0.1
    PGA_thresh = 1 / (0.702 * log(Ts / Tm / 0.1) - ...
        0.076 * (log(Ts / Tm / 0.1)) ^ 2);
else
    PGA_thresh = max(PGAz);
end

for j = 1 : length(PGAz)
    if PGAz(j) < PGA_thresh
        pga = PGAz(j);
    else
        pga = PGA_thresh;
    end
    
    if Ts / Tm > 0.1
        lnkmax = log(pga) + (0.459 - 0.702 * pga) * log(Ts / Tm / 0.1) + ...
            (-0.228 + 0.076 * pga) * (log(Ts / Tm / 0.1)) ^ 2;
    else
        lnkmax= log(pga);
    end
    
    for k = 1:length(kmaxz)
        % P[kmax|PGA, PGV]
        if k == 1
            mu         = log((kmaxz(k+1) + kmaxz(k)) / 2);
            xhat       = (mu - lnkmax)/sigk;
            Pkmax(j,k) = 0.5*(erfc(-xhat/sqrt(2)));
        elseif k == length(kmaxz)
            mu         = log((kmaxz(k-1) + kmaxz(k)) / 2);
            xhat       = (mu - lnkmax)/sigk;
            Pkmax(j,k) = 1-0.5*(erfc(-xhat/sqrt(2)));
        else
            mu1        = log((kmaxz(k+1) + kmaxz(k)) / 2);
            xhat1      = (mu1 - lnkmax)/sigk;
            mu2        = log((kmaxz(k) + kmaxz(k-1)) / 2);
            xhat2      = (mu2 - lnkmax)/sigk;
            Pkmax(j,k) = 0.5*erfc(-xhat1/sqrt(2)) - 0.5*erfc(-xhat2/sqrt(2));
        end
        
        for i = 1 : length(PGVz)
            if Ts / Tm > 0.2
                lnkvmax(j,k,i) = log(PGVz(i)) + 0.24 * log(Ts / Tm / 0.2) + ...
                    (-0.091 - 0.171 * PGAz(j)) * (log(Ts / Tm / 0.2)) ^ 2 + ...
                    rho * sigkv / sigk * (log(kmaxz(k)) - lnkmax);
            else
                lnkvmax(j,k,i) = log(PGVz(i)) + ...
                    rho * sigkv / sigk * (log(kmaxz(k)) - lnkmax);
            end
        end
    end
end

for l = 1 : length(kvmaxz)
    for k = 1 : length(kmaxz)
        total = 0;
        for i = 1 : length(PGVz)
            for j = 1 : length(PGAz)
                % P[kvmax|kmax, PGA, PGV]
                if l == 1
                    mu     = log((kvmaxz(l+1) + kvmaxz(l)) /2);
                    xhat   = (mu-lnkvmax(j,k,i))/sigkvk;
                    Pkvmax = 0.5*(erfc(-xhat/sqrt(2)));
                elseif l == length(kvmaxz)
                    mu     = log((kvmaxz(l-1) + kvmaxz(l)) /2);
                    xhat   = (mu-lnkvmax(j,k,i))/sigkvk;
                    Pkvmax = 1-0.5*(erfc(-xhat/sqrt(2)));
                else
                    mu1   = log((kvmaxz(l+1) + kvmaxz(l)) /2);
                    xhat1 = (mu1-lnkvmax(j,k,i))/sigkvk;
                    
                    mu2 = log((kvmaxz(l) + kvmaxz(l-1)) /2);
                    xhat2 = (mu2-lnkvmax(j,k,i))/sigkvk;
                    Pkvmax = 0.5*erfc(-xhat1/sqrt(2)) - 0.5*erfc(-xhat2/sqrt(2));
                end
                total = Pkvmax * Pkmax(j,k) * MRD(i,j) + total;
            end
        end
        MRDkvkm(l,k) = total;
        
    end
end

