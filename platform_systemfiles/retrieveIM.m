function eq = retrieveIM(fun,eq,FULLPATH,out)

do_vel   = or(out.velocity,out.PGV);
do_dis   = or(out.displacement,out.PGD);
do_arias = any([out.Arias,out.D595,out.D2575,out.aRMS,out.Dbracket]);

switch out.accunits
    case 'g'     , accConv = 9.80665;
    case 'm/s2'  , accConv = 1;
    case 'cm/s2' , accConv = 0.1;
end

%  time histories
[eq.dt,acc]=fun(FULLPATH);
eq.samples = length(acc);

if isempty(acc)
    acc=nan(1,100);
    eq.dt=0.01;
end
acc  = acc*accConv; % acc in m/s2
dt   = eq.dt;
time = eq.dt*(0:length(acc)-1);
acc  = butterworth(time,acc,out.filterOpt);

if do_vel,   vel = freqInt(time,acc,1); end
if do_dis,   dis = freqInt(time,acc,2); end
if out.acceleration, eq.acc = acc; end
if out.velocity,     eq.vel = vel; end
if out.displacement, eq.dis = dis; end

% response spectra
if out.PGA,          eq.PGA = max(abs(acc)); end
if out.PGV,          eq.PGV = max(abs(vel)); end
if out.PGD,          eq.PGD = max(abs(dis)); end
eq.T =[];
if any([out.SA,out.SV,out.SD,out.PredPeriod])
    eq.T =out.T;
    [Sa,Sv,Sd]  = out.method(time,acc,out);
end
if out.SA,eq.Sa=Sa;end
if out.SV,eq.Sv=Sv;end
if out.SD,eq.Sd=Sd;end

% duration
if do_arias
    g = 9.8066; %all in g at this point
    ari = cumsum(acc.^2,2)*pi*dt/(2*g);
    ariasI  = ari/ari(end);
end

if out.D595
    timed   = time(ariasI>=0.05 & ariasI<=0.95);
    eq.D595 = timed(end)-timed(1);
end

if out.D2575
    ariasI   = ari/ari(end);
    timed    = time(ariasI>=0.25 & ariasI<=0.75);
    eq.D2575 = timed(end)-timed(1);
end

if out.Dbracket
    pos1     = find(abs(acc)>(0.05*9.81),1,'first');
    pos2     = find(abs(acc)>(0.05*9.81),1,'last');
    if or(isempty(pos1),isempty(pos2))
        eq.DBracket = 0;
    else
        eq.DBracket = time(pos2)-time(pos1);
    end
end

% frequency content
if out.MeanPeriod
   [f,C] = Fou(time,acc,1);
   C = C(and(f>=0.25,f<=20));
   f = f(and(f>=0.25,f<=20));
   eq.Tm = ((C.^2)*(1./f'))/(C*C');
end

if out.PredPeriod
    [~,ind] = max(Sa);
   eq.Tp = eq.T(ind); 
end

if out.AvgPeriod
    options.damping = out.damping;
    options.T       = logsp(0.01,10,50);
    SA  = out.method(time,acc,options);
    MHA = max(abs(acc));
    eq.To= sum(options.T.*log(SA).*(SA>1.2*MHA))/sum(log(SA).*(SA>1.2*MHA));
end

% other parameters
if out.aRMS         % uses significant duration D959
    timed    = time(ariasI>=0.05 & ariasI<=0.95);
    accd     = acc (ariasI>=0.05 & ariasI<=0.95);
    Td       = timed(end)-timed(1);
    eq.aRMS  = sqrt(1/Td*trapz(timed,accd.^2));
end
if out.CAV,          eq.CAV   = trapz(time,abs(acc));end
if out.Arias,        eq.Arias = pi/(2*g)*trapz(time,acc.^2); end

% unit conversion
switch out.outputunits
    case 'g - m/s - m'
        factorAcc   = 1/9.80665;
        factorVel   = 1;
        factorDis   = 1;
    case 'g - cm/s - cm'
        factorAcc   = 1/9.80665;
        factorVel   = 100;
        factorDis   = 100;
    case 'm/s2 - m/s - m'
        factorAcc   = 1;
        factorVel   = 1;
        factorDis   = 1;
    case 'cm/s2 - cm/s - cm'
        factorAcc   = 100;
        factorVel   = 100;
        factorDis   = 100;
end


%%%%%%%%%%%%%%%%%% UNIT CONVERTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% time histories
eq.acc   = eq.acc   * factorAcc;
eq.vel   = eq.vel   * factorVel;
eq.dis   = eq.dis   * factorDis;

% response spectra
eq.PGA   = eq.PGA   * factorAcc;
eq.PGV   = eq.PGV   * factorVel;
eq.Sa    = eq.Sa    * factorAcc;
eq.Sv    = eq.Sv    * factorVel;
eq.Sd    = eq.Sd    * factorDis;

% frequency content

% duration

% other parameters
eq.aRMS  = eq.aRMS   * factorAcc;
eq.CAV   = eq.CAV   * factorVel;
eq.Arias = eq.Arias * factorVel;

