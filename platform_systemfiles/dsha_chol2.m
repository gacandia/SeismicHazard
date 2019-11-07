function L = dsha_chol2(shakefield,h,opt)

%% determins unique list of scenarios
[Lptr,B]  = unique(vertcat(shakefield.Lptr),'stable');
TAU    = horzcat(shakefield.tau)'; TAU=TAU(B,:);
PHI    = horzcat(shakefield.phi)'; PHI=PHI(B,:);

mag    = [];
mec = cell(0,1);
for i=1:length(shakefield)
    Nel = length(shakefield(i).mscl.M);
    mag = [mag;shakefield(i).mscl.M];  %#ok<AGROW>
    mec = [mec;repmat({shakefield(i).mechanism},Nel,1)]; %#ok<AGROW>
end
mag = mag(B);
mec = mec(B);

Nunk   = length(Lptr);
IM1    = opt.IM1;
IM2    = opt.IM2;
IMs    = [IM1;IM2];
[IMcorr1,IMcorr2] = meshgrid(IMs,IMs);
Nsites  = size(h,1);
NIM     = length(IMs);
L       = zeros(Nsites*NIM,Nsites*NIM,Nunk);

param(1:Nunk)= struct('opp',0,'residual','phi','direction','horizontal','isVs30clustered',1,'mechanism',[],'M',[]);
for i=1:Nunk
    param(i).mechanism = mec{i};
    param(i).M         = mag(i);
end

%% Computes Spatial Correlation Structures
funSpatial  = opt.Spatial;
funSpectral = opt.Spectral;
for jj=1:Nunk
    Lii    = zeros(Nsites,Nsites,NIM);
    tau    = TAU(jj,:);
    phi    = PHI(jj,:);
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
