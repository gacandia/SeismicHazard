function RotDpp = GMSelect_RotDpp(RotDpp,H1,H2,Dpp,out,ROOT)

do_vel   = or(out.velocity,out.PGV);
do_dis   = or(out.displacement,out.PGD);

switch out.accunits
    case 'g'     , accConv = 9.80665;
    case 'm/s2'  , accConv = 1;
    case 'cm/s2' , accConv = 0.1;
end

Neq   = length(RotDpp);

filterOpt =out.filterOpt;
do_PGA  = out.PGA;
do_PGV  = out.PGV;
do_PGD  = out.PGD;
do_SA   = out.SA;
do_SV   = out.SV;
do_SD   = out.SD;
do_spec = any([do_SA,do_SV,do_SD,out.PredPeriod]);
g       = 9.8066; %all in g at this point

spmd
    warning('off','MATLAB:mir_warning_maybe_uninitialized_temporary');
end

parfor i=1:Neq
    fprintf('%3.3f\n',i/Neq);
    theta = 0:1:90;
    Nth   = length(theta);
    
    % loads H1 and H2
    FULLPATH1 = fullfile(ROOT,H1(i).earthquake,H1(i).filename); [dt,acc1,num1]= readSIBERRISK(FULLPATH1); %#ok<*ASGLU>
    FULLPATH2 = fullfile(ROOT,H2(i).earthquake,H2(i).filename); [dt,acc2,num2]= readSIBERRISK(FULLPATH2);
    
    % fixes time histories if the records have different length. 
    % There are 235 of these in the SIBER RISK database
    if numel(acc1)~=numel(acc2)
        time1  = (0:(length(acc1)-1))*dt;
        time2  = (0:(length(acc2)-1))*dt;
        shift2 = round(etime(num2,num1)/dt)*dt;
        time2  = time2+shift2;
        tini   = max([time1(1),time2(1)]);
        tfin   = min([time1(end),time2(end)]);
        ind1   = find(abs(time1-tini)<dt/100):find(abs(time1-tfin)<dt/100); acc1 = acc1(ind1);
        ind2   = find(abs(time2-tini)<dt/100):find(abs(time2-tfin)<dt/100); acc2 = acc2(ind2);
    end
    
    time     = dt*(0:length(acc1)-1);
    acc1     = butterworth(time,acc1,filterOpt); acc1     = acc1*accConv; % acc in m/s2   
    acc2     = butterworth(time,acc2,filterOpt); acc2     = acc2*accConv; % acc in m/s2
    
    % response spectra
    osc1 = zeros(Nth,length(acc1));
    osc2 = zeros(Nth,length(acc2));
    for k=1:Nth
        th   = theta(k);
        osc1(k,:) = acc1*cosd(th)+acc2*sind(th);
        osc2(k,:) =-acc1*sind(th)+acc2*cosd(th);
    end
    ari1  = cumsum(osc1.^2,2)*pi*dt/(2*g);
    ari2  = cumsum(osc2.^2,2)*pi*dt/(2*g);
    
    if do_vel
        vel1 = freqInt(time,osc1,1);
        vel2 = freqInt(time,osc2,1);
    end
    if do_dis
        dis1  = freqInt(time,osc1,2);
        dis2  = freqInt(time,osc2,2);
    end
    
    if do_PGA
        PGA = sqrt(max(abs(osc1),[],2).*max(abs(osc2),[],2));
        RotDpp(i).PGA = prctile(PGA,Dpp);
    end
    if do_PGV
        PGV = sqrt(max(abs(vel1),[],2).*max(abs(vel2),[],2));
        RotDpp(i).PGV = prctile(PGV,Dpp);
    end
    if do_PGD
        PGD = sqrt(max(abs(dis1),[],2).*max(abs(dis2),[],2));
        RotDpp(i).PGD = prctile(PGD,Dpp);
    end
    
    if do_spec
        [Sa1,Sv1,Sd1] = timespec_theta(time,osc1,out);
        [Sa2,Sv2,Sd2] = timespec_theta(time,osc2,out);
        if do_SA, RotDpp(i).Sa = prctile(sqrt(Sa1.*Sa2),Dpp,1); end
        if do_SV, RotDpp(i).Sv = prctile(sqrt(Sv1.*Sv2),Dpp,1); end
        if do_SD, RotDpp(i).Sd = prctile(sqrt(Sd1.*Sd2),Dpp,1); end
    end
    
    if out.D595
        D595 = zeros(Nth,2);
        for cont=1:Nth
            ariasI       = ari1(cont,:)/ari1(cont,end);
            timed        = time(ariasI>=0.05 & ariasI<=0.95);
            D595(cont,1) = timed(end)-timed(1);
            
            ariasI       = ari2(cont,:)/ari2(cont,end);
            timed        = time(ariasI>=0.05 & ariasI<=0.95);
            D595(cont,2) = timed(end)-timed(1);
        end
        D595 = sqrt(D595(:,1).*D595(:,2));
        RotDpp(i).D595   = prctile(D595,Dpp);
    end
    
    if out.D2575
        D2575 = zeros(Nth,2);
        for cont=1:Nth
            ariasI        = ari1(cont,:)/ari1(cont,end);
            timed         = time(ariasI>=0.25 & ariasI<=0.75);
            D2575(cont,1) = timed(end)-timed(1);
            ariasI        = ari2(cont,:)/ari2(cont,end);
            timed         = time(ariasI>=0.25 & ariasI<=0.75);
            D2575(cont,2) = timed(end)-timed(1);
        end
        D2575 = sqrt(D2575(:,1).*D2575(:,2));
        RotDpp(i).D2575   = prctile(D2575,Dpp);
    end
    
    if out.Dbracket
        DBracket = zeros(Nth,2);
        for cont=1:Nth
            pos1     = find(abs(osc1(cont,:))>(0.05*9.81),1,'first');
            pos2     = find(abs(osc1(cont,:))>(0.05*9.81),1,'last');
            
            if or(isempty(pos1),isempty(pos2))
                DBracket(cont,1) = 0;
            else
                DBracket(cont,1) = time(pos2)-time(pos1);
            end
            
            pos1     = find(abs(osc2(cont,:))>(0.05*9.81),1,'first');
            pos2     = find(abs(osc2(cont,:))>(0.05*9.81),1,'last');
            if or(isempty(pos1),isempty(pos2))
                DBracket(cont,2) = 0;
            else
                DBracket(cont,2) = time(pos2)-time(pos1);
            end
        end
        
        DBracket = sqrt(DBracket(:,1).*DBracket(:,2));
        RotDpp(i).DBracket   = prctile(DBracket,Dpp);
    end
    
    % frequency content
    if out.MeanPeriod
        [f,C] = Fou(time,osc1,1);
        C = C(:,and(f>=0.25,f<=20));
        f = f(:,and(f>=0.25,f<=20));
        Tm(:,1) = sum(bsxfun(@times,C.^2,1./f),2)./sum(C.^2,2);
        
        [f,C] = Fou(time,osc2,1);
        C = C(:,and(f>=0.25,f<=20));
        f = f(:,and(f>=0.25,f<=20));
        Tm(:,2) = sum(bsxfun(@times,C.^2,1./f),2)./sum(C.^2,2);
        
        Tm  = sqrt(Tm(:,1).*Tm(:,2));
        RotDpp(i).Tm = prctile(Tm,Dpp);
    end
    if out.PredPeriod
        T = out.T(:);
        [~,ind1] = max(Sa1,[],2);
        [~,ind2] = max(Sa2,[],2);
        Tp       = [T(ind1),T(ind2)];
        Tp  = sqrt(Tp(:,1).*Tp(:,2));
        RotDpp(i).Tp = prctile(Tp,Dpp);
    end
    if out.AvgPeriod
        MHA1 = max(abs(osc1),[],2);
        MHA2 = max(abs(osc2),[],2);
        T = out.T;
        To= zeros(Nth,2);
        for cont=1:Nth
            To(cont,1)= sum(T.*log(Sa1(cont,:)).*(Sa1(cont,:)>1.2*MHA1(cont)))/sum(log(Sa1(cont,:)).*(Sa1(cont,:)>1.2*MHA1(cont)));
            To(cont,2)= sum(T.*log(Sa2(cont,:)).*(Sa2(cont,:)>1.2*MHA2(cont)))/sum(log(Sa2(cont,:)).*(Sa2(cont,:)>1.2*MHA2(cont)));
        end
        To  = sqrt(To(:,1).*To(:,2));
        RotDpp(i).To = prctile(To,Dpp);
    end
    
    % other parameters
    if out.aRMS         % uses significant duration D959
        aRMS    = zeros(Nth,2);
        for cont=1:Nth
            ariasI  = ari1(cont,:)/ari1(cont,end);
            timed   = time(ariasI>=0.05 & ariasI<=0.95);
            accd    = osc1(cont,ariasI>=0.05 & ariasI<=0.95);
            Td      = timed(end)-timed(1);
            aRMS(cont,1)  = sqrt(1/Td*trapz(timed,accd.^2));
            
            ariasI  = ari2(cont,:)/ari2(cont,end);
            timed   = time(ariasI>=0.05 & ariasI<=0.95);
            accd    = osc2(cont,ariasI>=0.05 & ariasI<=0.95);
            Td      = timed(end)-timed(1);
            aRMS(cont,2)  = sqrt(1/Td*trapz(timed,accd.^2));
        end
        aRMS  = sqrt(aRMS(:,1).*aRMS(:,2));
        RotDpp(i).aRMS = prctile(aRMS,Dpp);
    end
    
    if out.CAV
        CAV = zeros(Nth,2);
        for cont=1:Nth
            CAV(cont,1)=trapz(time,abs(osc1(cont,:)));
            CAV(cont,2)=trapz(time,abs(osc2(cont,:)));
        end
        CAV  = sqrt(CAV(:,1).*CAV(:,2));
        RotDpp(i).CAV = prctile(CAV,Dpp);
    end
    
    if out.Arias
        Arias = zeros(Nth,2);
        for cont=1:Nth
            Arias(cont,1) = pi/(2*g)*trapz(time,osc1(cont,:).^2);
            Arias(cont,2) = pi/(2*g)*trapz(time,osc2(cont,:).^2);
        end
        Arias  = sqrt(Arias(:,1).*Arias(:,2));
        RotDpp(i).Arias = prctile(Arias,Dpp);
    end
    
    RotDpp(i).T=H1(i).T;
    
end

spmd
    warning('on','MATLAB:mir_warning_maybe_uninitialized_temporary');
end

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
for i=1:Neq
    % time histories
    RotDpp(i).acc   = RotDpp(i).acc   * factorAcc;
    RotDpp(i).vel   = RotDpp(i).vel   * factorVel;
    RotDpp(i).dis   = RotDpp(i).dis   * factorDis;
    
    % response spectra
    RotDpp(i).PGA   = RotDpp(i).PGA   * factorAcc;
    RotDpp(i).PGV   = RotDpp(i).PGV   * factorVel;
    RotDpp(i).Sa    = RotDpp(i).Sa    * factorAcc;
    RotDpp(i).Sv    = RotDpp(i).Sv    * factorVel;
    RotDpp(i).Sd    = RotDpp(i).Sd    * factorDis;
    
    % frequency content
    
    % other parameters
    RotDpp(i).aRMS  = RotDpp(i).aRMS   * factorAcc;
    RotDpp(i).CAV   = RotDpp(i).CAV    * factorVel;
    RotDpp(i).Arias = RotDpp(i).Arias  * factorVel;
    
end