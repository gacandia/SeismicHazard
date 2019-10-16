function shakefield = dsha_gmpe(shakefield,r0,Vs30,opt)
IM1         = opt.IM1;
IM2         = opt.IM2;
% NumSim      = opt.SimDSHA;
ellipsoid   = opt.ellipsoid;
IMs         = [IM1;IM2];
NIM         = length(IMs);
Nsites      = size(r0,1);
mulogIM     = zeros(Nsites,NIM);
[tau,phi]   = deal(zeros(1,NIM));

for i=1:Nsites
    for j=1:NIM
        [mulogIM(i,j),~,tau(j),phi(j)]=run_gmpe(shakefield,r0(i,:),IMs(j),Vs30(i),ellipsoid);
    end
end

shakefield.mulogIM  = mulogIM(:);
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
    case 'point',      param = mGMPEassemblePoint(r0,scenario,Rmetric,ellipsoid);
    case 'line',       param = mGMPEassembleLine(r0,scenario,Rmetric,ellipsoid);
    case 'area',       param = mGMPEassembleArea(r0,scenario,Rmetric,ellipsoid);  
    case 'background', param = mGMPEassembleArea(r0,scenario,Rmetric,ellipsoid);
    case 'fault',      param = mGMPEassembleFault_S(r0,scenario,rateM,Rmetric,ellipsoid);
end

[mu,sigma,tau,sig] = gmpefun(IM,param{:});
