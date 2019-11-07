function [param,val] = mGMPEusp(gmpe) %#ok<*INUSD,*DEFNU>

method = pshatoolbox_methods(1);
val    = zeros(1,18);

switch gmpe.type
    case 'regular', fun = func2str(gmpe.handle);
    case 'cond',    fun = func2str(gmpe.cond.conditioning);
    case 'udm' ,    fun = 'udm';
    case 'pce' ,    fun = func2str(gmpe.handle);
end

[~,B]  = intersect({method.str},fun);
val(end)=B;

source.gmpe=gmpe;
Vs30   = 760;
source = mGMPEVs30(source,Vs30);
usp    = source.gmpe.usp;

switch fun
       
    case 'Youngs1997'
        M         = 7.0;
        rrup      = 90;
        Zhyp      = 50;
        [~,val(4)]=intersect({'interface','intraslab'},usp.mechanism);
        [~,val(5)]=intersect({'rock','soil'},usp.media);
        param   = {M,rrup,Zhyp,usp.mechanism,usp.media}; % system defined parameters
        
    case 'Garcia2005'
        M         = 7.0;
        rrup      = 90;
        rhyp      = 90;
        H         = 50;
        [~,val(4)]=intersect({'horizontal','vertical'},usp.direction);
        param   = {M,rrup,rhyp,H,usp.direction}; % system defined parameters   
        
    case 'AtkinsonBoore2003'
        M         = 7.0;
        rrup      = 90;
        Zhyp      = 50;
        [~,val(4)]=intersect({'interface','intraslab'},usp.mechanism);
        [~,val(5)]=intersect({'nehrpb','nehrpc','nehrpd','nehrpe'},usp.media);
        [~,val(6)]=intersect({'general','cascadia','japan'},usp.region);
        param   = {M,rrup,Zhyp,usp.mechanism,usp.media,usp.region}; % system defined parameters
        
    case 'Zhao2006'
        M         = 7.0;
        rrup      = 90;
        Zhyp      = 50;
        [~,val(4)]=intersect({'interface','intraslab'},usp.mechanism);
        param   = {M,rrup,Zhyp,usp.mechanism,usp.Vs30}; % system defined parameters
        
    case 'Mcverry2006'
        M         = 7;
        rrup      = 50;
        Hc        = 50;
        [~,val(4)]= intersect({'interface','intraslab','normal','reverse','oblique','strike-slip'},usp.mechanism);
        [~,val(5)]= intersect({'A','B','C','D','E'},upper(usp.media));
        param     = {M,rrup,Hc,usp.mechanism,usp.media,usp.rvol}; % system defined parameters
        
    case 'ContrerasBoroschek2012'
        M         = 7.0;
        rrup      = 90;
        Zhyp      = 50;
        param     = {M,rrup,Zhyp,usp.media};
        
    case 'BCHydro2012'
        M         = 7.0;
        rrup      = 90;
        Zhyp      = 50;
        [~,val(4)]=intersect({'interface','intraslab'},usp.mechanism);
        [~,val(5)]=intersect({'forearc','backarc','unkown'},usp.region);
        [~,val(6)]=intersect({'lower','central','upper','none'},usp.DeltaC1);
        param     = {M,rrup,Zhyp,usp.mechanism,usp.region,usp.DeltaC1,usp.Vs30}; % system defined parameters

    case 'Arteta2018'
        M         = 7.0;
        rhyp      = 90;
        [~,val(3)]=intersect({'rock','soil'},usp.media);
        [~,val(4)]=intersect({'forearc','backarc'},usp.region);
        param   = {M,rhyp,usp.media,usp.region}; % system defined parameters        
        
    case 'Idini2016'
        M         = 7.0;
        rrup      = 90;
        Zhyp      = 50;
        [~,val(4)]=intersect({'interface','intraslab'},usp.mechanism);
        [~,val(5)]=intersect({'si','sii','siii','siv','sv','svi'},usp.spectrum);
        param   = {M,rrup,Zhyp,usp.mechanism,usp.spectrum,usp.Vs30};
        
    case 'MontalvaBastias2017'
        M         = 7.0;
        rrup      = 90;
        Zhyp      = 50;
        [~,val(4)]=intersect({'interface','intraslab'},usp.mechanism);
        [~,val(5)]=intersect({'forearc','backarc','unkown'},usp.region);
        param     = {M,rrup,Zhyp,usp.mechanism,usp.region,usp.Vs30}; % system defined parameters
        
    case 'SiberRisk2019'
        M         = 7.0;
        rrup      = 90;
        Zhyp      = 50;
        [~,val(4)]=intersect({'interface','intraslab'},usp.mechanism);
        param     = {M,rrup,Zhyp,usp.mechanism,usp.Vs30}; % system defined parameters        
        
    case 'Jaimes2006'
        M        = 7.0;
        rrup     = 90;
        param   = {M,rrup}; % system defined parameters
        
    case 'Jaimes2015'
        M        = 7.0;
        rrup     = 90;
        param   = {M,rrup}; % system defined parameters
        
    case 'Jaimes2016'
        M        = 7.0;
        rrup     = 90;
        param   = {M,rrup}; % system defined parameters
        
    case 'GarciaJaimes2017'
        M        = 7.0;
        rrup     = 90;
        param   = {M,rrup}; % system defined parameters

    case 'Bernal2014'
        M         = 7.0;
        rrup      = 90;
        Zhyp      = 50;
        [~,val(4)]=intersect({'interface','intraslab'},usp.mechanism);
        param   = {M,rrup,Zhyp,usp.mechanism}; % system defined parameters
        
    case 'Sadigh1997'
        M         = 7.0;
        rrup      = 50;
        [~,val(3)]= intersect({'reverse/thrust','strike-slip'},usp.mechanism);
        [~,val(4)]= intersect({'rock','deepsoil'},usp.media);
        param   = {M,rrup,usp.mechanism,usp.media}; % system defined parameters
        
    case 'Idriss2008_nga'
        M         = 7;
        rrup      = 50;
        [~,val(3)]= intersect({'strike-slip','reverse'},usp.mechanism);
        param     = {M,rrup,usp.mechanism,usp.Vs30};
        
    case 'ChiouYoungs2008_nga'
        M      = 7;
        rrup   = 50;
        rjb    = 50;
        rx     = 50;
        ztor   = 3;
        dip    = 90;
        [~,val(8)] =intersect({'strike-slip','reverse'},usp.mechanism);
        [~,val(9)] =intersect({'mainshock','aftershock'},usp.event);
        [~,val(11)]=intersect({'measured','inferred'},usp.Vs30type);
        param   = {M, rrup, rjb, rx, ztor, dip, usp.Z10, usp.mechanism, usp.event, usp.Vs30, usp.Vs30type};
        
    case 'BooreAtkinson_2008_nga'
        M      = 7;
        Rjb    = 50;
        [~,val(3)] =intersect({'unspecified','strike-slip','normal','reverse'},usp.mechanism);
        param  = {M, Rjb, usp.mechanism, usp.Vs30};
        
    case 'CampbellBozorgnia_2008_nga'
        M      = 7;
        rrup   = 50;
        rjb    = 50;
        ztor   = 3;
        dip    = 90;
        [~,val(6)] =intersect({'strike-slip','normal','normal-oblique','reverse','reverse-oblique','thrust'},usp.mechanism);
        [~,val(9)] =intersect({'arbitrary','average'},usp.sigmatype);
        param  = {M,rrup, rjb, ztor, dip, usp.mechanism, usp.Vs30, usp.Z25, usp.sigmatype};
        
    case 'AbrahamsonSilva2008_nga'
        M     = 7;
        rrup  = 50;
        rjb   = 50;
        rx    = 50;
        ztor  = 3;
        dip   = 90;
        W     = 10;
        [~,val(10)] =intersect({'strike-slip','normal','normal-oblique','reverse','reverse-oblique','thrust'},usp.mechanism);
        [~,val(11)] =intersect({'aftershock','mainshock','foreshock','swarms'},usp.event);
        [~,val(12)] =intersect({'measured','inferred'},usp.Vs30type);
        param={M, rrup, rjb, rx, ztor, dip,W, usp.Z10, usp.Vs30,usp.mechanism,usp.event,usp.Vs30type};

    case 'AS1997h'
        M     = 7;
        rrup  = 90;
        [~,val(3)] =intersect({'deepsoil','rock'},usp.media);
        [~,val(4)] =intersect({'strike-slip','normal','normal-oblique','reverse','reverse-oblique','thrust'},usp.mechanism);
        [~,val(5)] =intersect({'hangingwall','footwall','other'},usp.location);
        [~,val(6)] =intersect({'arbitrary','average'},usp.sigma);
        param={M, rrup, usp.media, usp.mechanism, usp.location, usp.sigma};
        
    case 'Campbell1997h'
        M     = 7.0;
        rseis = 50;
        [~,val(3)] =intersect({'hardrock','softrock','soil'},usp.media);
        [~,val(4)] =intersect({'strike-slip','normal','normal-oblique','reverse','reverse-oblique','thrust'},usp.mechanism);
        [~,val(6)] =intersect({'arbitrary','average'},usp.sig);
        param={M, rseis, usp.media, usp.mechanism, usp.brdepth, usp.sigma};        
        
    case 'I_2014_nga'
        M         = 7;
        rrup      = 50;
        [~,val(3)]= intersect({'strike-slip','reverse'},usp.mechanism);
        param     = {M,rrup,usp.mechanism,usp.Vs30};
        
    case 'CY_2014_nga'
        %M, Rup, Rjb, Rx, Ztor, dip, mechanism, Z10, Vs30, Vs30type, region
        M      = 7;
        rrup   = 50;
        rjb    = 50;
        rx     = 50;
        ztor   = 3;
        dip    = 90;
        [~,val(7)] =intersect({'strike-slip','normal','normal-oblique','reverse','reverse-oblique','thrust'},usp.mechanism);
        [~,val(10)]=intersect({'measured','inferred'},usp.Vs30type);
        [~,val(11)]=intersect({'global','california','japan','china','italy','turkey'},usp.region);
        param   = {M, rrup, rjb, rx, ztor, dip, usp.mechanism, usp.Z10, usp.Vs30, usp.Vs30type, usp.region};
        
    case 'BSSA_2014_nga'
        %M, rjb, mechanism, reg, BasinDepth, Vs30
        M      = 7;
        Rjb    = 10;
        [~,val(3)] =intersect({'unspecified','strike-slip','normal','reverse'},usp.mechanism);
        [~,val(4)] =intersect({'global','california','japan','china','italy','turkey'},usp.region);
        param  = {M, Rjb, usp.mechanism, usp.region,usp.BasinDepth,usp.Vs30};
        
    case 'CB_2014_nga'
        %M, Rrup, Rjb, Rx, W, Ztor, Zhyp, delta, mechanism, HWEffect, Vs30, Z25, reg
        M      = 7;
        rrup   = 50;
        rjb    = 50;
        rx     = 50;
        W      = 12;
        Ztor   = 3;
        Zhyp   = 9;
        dip    = 90;
        [~,val(9)]  = intersect({'strike-slip','normal','normal-oblique','reverse','reverse-oblique','thrust'},usp.mechanism);
        [~,val(10)] = intersect({'include','exclude'},usp.HW);
        [~,val(13)] = intersect({'global','california','japan','china','italy','turkey'},usp.region);
        param  = {M,rrup, rjb, rx,W, Ztor,Zhyp, dip, usp.mechanism, usp.HW,  usp.Vs30, usp.Z25, usp.region};

    case 'ASK_2014_nga'
        %To,M, Rrup, Rjb, Rx, Ry0, Ztor, delta, W, mechanism, event, Z10, Vs30, Vs30type, reg
        M     = 7;
        Rrup  = 50;
        Rjb   = 50;
        Rx    = 50;
        Ry0   = 50;
        Ztor  = 3;
        delta = 90;
        W     = 12;
        [~,val(9) ] = intersect({'strike-slip','normal','normal-oblique','reverse','reverse-oblique','thrust'},usp.mechanism);
        [~,val(10)] = intersect({'mainshock','aftershock'},usp.event);
        [~,val(13)] = intersect({'measured','inferred'},usp.Vs30type);
        [~,val(14)] = intersect({'global','california','japan','china','italy','turkey'},usp.region);
        param  = {M, Rrup, Rjb, Rx, Ry0, Ztor, delta, W, usp.mechanism, usp.event, usp.Z10, usp.Vs30, usp.Vs30type, usp.region};
        
    case 'DW12'
        %To,M, Rrup, Rjb, Rx, Ry0, Ztor, delta, W, mechanism, event, Z10, Vs30, Vs30type, reg
        M     = 7;
        Rrup  = 50;
        [~,val(3) ] = intersect({'strike-slip','normal','normal-oblique','reverse','reverse-oblique','thrust'},usp.mechanism);
        [~,val(4)]  = intersect({'sgs-b','sgs-c','sgs-d'},usp.media);
        param  = {M, Rrup, usp.mechanism, usp.media};
        
        
end
