function [lnY,sigma]=PCE_nga(To,M, Rrup, Vs30, Vs30type, reg)

if 1
    if  To<0 || To> 10
        lnY   = nan(size(M));
        sigma = nan(size(M));
        return
    end
    
    load PCE_nga_coefs.mat COEF
    Nreal      = 2000;
    To         = max(To,0.01); %PGA is associated to To=0.01;
    %[~, sigma] = ASK_2014_nga(To,M, Rrup, Rjb, Rx, Ry0, Ztor, delta, W, mechanism, event, Z10, Vs30, Vs30type, reg);
    sigma      = 0.715*ones(size(M));
    period     = [0.001 0.02 0.03 0.05 0.075 0.1 0.15 0.2 0.25 0.3 0.4 0.5 0.75 1 1.5 2 3 4 5 6 7 8 10];
    T_lo       = max(period(period<=To));
    T_hi       = min(period(period>=To));
    index      = find(abs((period - T_lo)) < 1e-6); % Identify the period
    X1         = ones(size(M));
    X2         = M-M.^3/(3*8.7^2);
    X3         = M.^2-2*M.^3/(3*8.7);
    X4         = log(Rrup.^2+6^2);
    X5         = Rrup;
    X6         = log(Vs30*ones(size(M))/760);
    X          = [X1,X2,X3,X4,X5,X6];
    
    
    if T_lo==T_hi
        mean_theta = COEF(:,1,index);
        cov_ini    = COEF(:,2:end,index);
        c          = mvnrnd(mean_theta,cov_ini,Nreal);
        lnY        = c*X';
    else
        x1    = log(T_lo);
        x2    = log(T_hi);
        x0    = log(To);
        S     = [1-(x0-x1)/(x2-x1),(x0-x1)/(x2-x1)];
        mu1   = COEF(:,1,index);
        cov1  = COEF(:,2:end,index);
        mu2   = COEF(:,1,index+1);
        cov2  = COEF(:,2:end,index+1);
        mu    = [mu1,mu2]*S';
        cov12 = S(1)^2*cov1+S(2)^2*cov2;
        c     = mvnrnd(mu,cov12,Nreal);
        lnY   = c*X';
    end
end

% original model
if 0
    % computes sigma from ASK2014
    [~, sigma] = ASK_2014_nga(To,M, Rrup, Rjb, Rx, Ry0, Ztor, delta, W, mechanism, event, Z10, Vs30, Vs30type, reg);
    
    switch mechanism
        case 'strike-slip',     f_r = 0; f_n=0;
        case 'normal',          f_r = 0; f_n=1;
        case 'normal-oblique',  f_r = 0; f_n=0;
        case 'reverse',         f_r = 1; f_n=0;
        case 'reverse-oblique', f_r = 1; f_n=0;
        case 'thrust',          f_r = 1; f_n=0;
    end
    
    % mean_theta and cov_ini for Sa(T=0.2s)
    mean_theta =[1.6785;    0.21047;    0.71507;    -0.24208;    -1.2507;    0.21008;    5.4874;    0.0835;    0.15534;    0.099484;    0.3362;    0.85089];
    cov_ini =[    0.044231      0.015689     0.026576       0.014234     -0.0039939     -0.0064213        0.18176    -0.00090874     -0.0085593       0.014835     -0.0095105     -0.0028328
        0.015689      0.014276     0.027238      0.0052311      0.0039506     -0.0054538        0.10517    -0.00041542     -0.0065953       0.003349        -0.0131     0.00091063
        0.026576      0.027238      0.44862       -0.04777       0.041696      -0.016756       0.097649     0.00011512       0.013243      -0.051303       0.069912      -0.050332
        0.014234     0.0052311     -0.04777       0.014468     -0.0061282     -0.0014939       0.071288    -0.00052949     -0.0079615       0.014496      -0.018387      0.0080416
        -0.0039939     0.0039506     0.041696     -0.0061282      0.0073742     -0.0021486     -0.0018458     6.6891e-05     0.00021365     -0.0073291      0.0023936     -0.0025075
        -0.0064213    -0.0054538    -0.016756     -0.0014939     -0.0021486      0.0025728      -0.037358     0.00021917          0.003     -0.0011938       0.004003    -0.00017311
        0.18176       0.10517     0.097649       0.071288     -0.0018458      -0.037358         1.1215     -0.0031775      -0.044398       0.054441       -0.10709     -0.0023621
        -0.00090874   -0.00041542   0.00011512    -0.00052949     6.6891e-05     0.00021917     -0.0031775     4.9892e-05     0.00056813    -0.00068163     0.00064259    -0.00033173
        -0.0085593    -0.0065953     0.013243     -0.0079615     0.00021365          0.003      -0.044398     0.00056813      0.0089751     -0.0090377       0.014411     -0.0070278
        0.014835      0.003349    -0.051303       0.014496     -0.0073291     -0.0011938       0.054441    -0.00068163     -0.0090377       0.017727      -0.016503      0.0090343
        -0.0095105       -0.0131     0.069912      -0.018387      0.0023936       0.004003       -0.10709     0.00064259       0.014411      -0.016503       0.041969      -0.016859
        -0.0028328    0.00091063    -0.050332      0.0080416     -0.0025075    -0.00017311     -0.0023621    -0.00033173     -0.0070278      0.0090343      -0.016859       0.011375];
    
    
    Nreal = 2000;
    C     = mvnrnd(mean_theta,cov_ini,Nreal);
    Nscen = length(M);
    lnY   = zeros(Nreal,Nscen);
    
    for k=1:Nscen
        Mk = M(k);
        Rk = Rrup(k);
        Zk = Ztor(k);
        
        if Mk < 5.5
            f_M = -C(:, 2) + C(:, 3) * (Mk - 5.5);
        elseif  5.5 <= Mk && Mk <= 6.5
            f_M = C(:, 2) * (Mk - 6.5);
        elseif M > 6.5
            f_M = C(:, 4) * (Mk - 6.5);
        end
        lnY(:,k) = C(:,1) + f_M + ...
            (C(:,5) + C(:,6)*(Mk-5)).*log(sqrt(Rk^2 + C(:,7).^2)) - ...
            C(:,8).^2 .* Rk + C(:,9).^2 .* Zk + C(:,10).^2 .* f_r - ...
            C(:,11).^2 .* f_n - C(:,12).^2 .* log(Vs30/760);
    end
    
end
