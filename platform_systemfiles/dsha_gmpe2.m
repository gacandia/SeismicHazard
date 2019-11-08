function shakefield = dsha_gmpe2(shakefield,r0,Vs30,opt)
IM1         = opt.IM1;
IM2         = opt.IM2;
% NumSim      = opt.SimDSHA;
ellipsoid   = opt.ellipsoid;
IMs         = [IM1;IM2];
NIM         = length(IMs);
Nsites      = size(r0,1);
Nscen       = size(shakefield.mscl.M,1);
mulogIM     = zeros(Nsites,NIM,Nscen);
[sig,tau,phi]   = deal(zeros(NIM,Nscen));

for i=1:Nsites
    for j=1:NIM
        [mulogIM(i,j,:),sig(j,:),tau(j,:),phi(j,:)]=run_gmpe(shakefield,r0(i,:),IMs(j),Vs30(i),ellipsoid);
    end
end

% This is an assumption to cope with old GMMs that do not provide a tau and
% phi
if max(tau(:))==0 || max(phi(:))==0
    a=2/3;
    tau = a*sig/sqrt(1+a^2);
    phi =   sig/sqrt(1+a^2);
end


shakefield.mulogIM  = mulogIM;
shakefield.tau      = tau;
shakefield.phi      = phi;

function[mu,sigma,tau,sig]=run_gmpe(scenario,r0,IM,Vs30,ellipsoid)

mscl     = scenario.mscl;
gmpe     = scenario.gmpe;
rateM    = mscl.dPm;
gmpefun  = gmpe.handle;
Rmetric  = gmpe.Rmetric;
scenario = mGMPEVs30(scenario,Vs30);
switch scenario.type
    case 'point'
        param = mGMPEassemblePoint(r0,scenario,Rmetric,ellipsoid,true);
    case 'line'
        param = mGMPEassembleLine(r0,scenario,Rmetric,ellipsoid,true);
    case 'area'
        switch scenario.mechanism
            case 'shallowcrustal'
                param = mGMPEassembleCrustal(r0,scenario,rateM,Rmetric,ellipsoid,true);
            case {'interface','intraslab','grid','crustal'}
                param = mGMPEassembleArea(r0,scenario,Rmetric,ellipsoid,true);
        end
end

[mu,sigma,tau,sig] = gmpefun(IM,param{:});
