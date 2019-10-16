function L = dsha_chol(shakefield,h,opt)

%% determins unique list of scenarios
Lptr   = vertcat(shakefield.Lptr);
[~,B] = intersect(Lptr,unique(Lptr));
shakefield = shakefield(B);
IM1    = opt.IM1;
IM2    = opt.IM2;
IMs    = [IM1;IM2];
[IMcorr1,IMcorr2] = meshgrid(IMs,IMs);
Nsites  = size(h,1);
NIM     = length(IMs);
Nunk    = length(B);
L       = zeros(Nsites*NIM,Nsites*NIM,Nunk);

param(1:Nunk)= struct('opp',0,'residual','phi','direction','horizontal','isVs30clustered',1,'mechanism',[],'M',[]);
for i=1:Nunk
    param(i).mechanism = shakefield(i).mechanism;
    param(i).M         = shakefield(i).mscl.M;
end


%% Computes Spatial Correlation Structures
funSpatial  = opt.Spatial;
funSpectral = opt.Spectral;
for jj=1:Nunk
    Lii    = zeros(Nsites,Nsites,NIM);
    tau    = shakefield(jj).tau;
    phi    = shakefield(jj).phi;
    paramj = param(jj);
    
    for i=1:NIM
        rho  = funSpatial(IMs(i), h, paramj);
        Cii  = (tau(i)^2+phi(i)^2*rho);
        Lii(:,:,i)  = chol(Cii,'lower');
    end
    
    % Computes Interperiod CorrelationStructures
    rhoIM=funSpectral(IMcorr1,IMcorr2,paramj);
    
    % Builds Extended Covariance Matrix
    C = zeros(Nsites*NIM,Nsites*NIM);
    for i=1:NIM
        II = (1:Nsites)+Nsites*(i-1);
        for j=1:NIM
            JJ       = (1:Nsites)+Nsites*(j-1);
            C(II,JJ) = rhoIM(i,j)*Lii(:,:,i)*Lii(:,:,j)';
        end
    end
    L(:,:,jj) = chol(C,'lower');
end