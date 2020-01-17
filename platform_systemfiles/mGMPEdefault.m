function handles=mGMPEdefault(handles,txt,edi)

handles.e1.BackgroundColor=[1 1 1];
handles.e2.BackgroundColor=[1 1 1];
handles.e3.BackgroundColor=[1 1 1];
handles.e4.BackgroundColor=[1 1 1];
handles.e5.BackgroundColor=[1 1 1];
handles.e6.BackgroundColor=[1 1 1];
handles.e7.BackgroundColor=[1 1 1];
handles.e8.BackgroundColor=[1 1 1];
handles.e9.BackgroundColor=[1 1 1];
handles.e10.BackgroundColor=[1 1 1];
handles.e11.BackgroundColor=[1 1 1];
handles.e12.BackgroundColor=[1 1 1];
handles.e13.BackgroundColor=[1 1 1];
handles.e14.BackgroundColor=[1 1 1];
handles.e15.BackgroundColor=[1 1 1];
handles.e16.BackgroundColor=[1 1 1];
handles.e17.BackgroundColor=[1 1 1];

%% SUBDUCTION EARTHQUAKES
models = pshatoolbox_methods(1);
val    = handles.GMPEselect.Value;
str    = models(val).str;
handles.fun = models(val).func;
handles.IM  = mGMPE_info(str);

switch str
    case 'Youngs1997'
        set(txt(1:5),'Visible','on');
        set(edi(1:5),'Visible','on');
        handles.t1.String='Mw';
        handles.t2.String='Rrup (km)';
        handles.t3.String='Zhyp (km)';
        handles.t4.String='Mechanism';
        handles.t5.String='Media';
        handles.e1.String='7.0';
        handles.e2.String='90';
        handles.e3.String='50';
        handles.e4.Style='popupmenu'; handles.e4.Value=1; handles.e4.String={'interface','intraslab'};
        handles.e5.Style='popupmenu'; handles.e5.Value=1; handles.e5.String={'rock','soil'};
        handles.e1.BackgroundColor=[1 1 0.7];
        handles.e2.BackgroundColor=[1 1 0.7];
        handles.e3.BackgroundColor=[1 1 0.7];
        
    case 'AtkinsonBoore2003'
        set(txt(1:6),'Visible','on');
        set(edi(1:6),'Visible','on');
        handles.t1.String='Mw';
        handles.t2.String='Rrup (km)';
        handles.t3.String='Zhyp (km)';
        handles.t4.String='Mechanism';
        handles.t5.String='Media';
        handles.t6.String='Region';
        handles.e1.String='7.0';
        handles.e2.String='90';
        handles.e3.String='50';
        handles.e4.Style='popupmenu'; handles.e4.Value=1; handles.e4.String={'interface','intraslab'};
        handles.e5.Style='popupmenu'; handles.e5.Value=1; handles.e5.String={'nehrpb','nehrpc','nehrpd','nehrpe'};
        handles.e6.Style='popupmenu'; handles.e6.Value=1; handles.e6.String={'general','cascadia','japan'};
        handles.e1.BackgroundColor=[1 1 0.7];
        handles.e2.BackgroundColor=[1 1 0.7];
        handles.e3.BackgroundColor=[1 1 0.7];
        
    case 'Zhao2006'
        set(txt(1:5),'Visible','on');
        set(edi(1:5),'Visible','on');
        handles.t1.String='Mw';
        handles.t2.String='Rrup (km)';
        handles.t3.String='Zhyp (km)';
        handles.t4.String='Mechanism';
        handles.t5.String='Vs30 (m/s)';
        handles.e1.String='7.0';
        handles.e2.String='90';
        handles.e3.String='50';
        handles.e4.Style='popupmenu'; handles.e4.Value=1; handles.e4.String={'interface','intraslab'};
        handles.e5.String='760';
        handles.e1.BackgroundColor=[1 1 0.7];
        handles.e2.BackgroundColor=[1 1 0.7];
        handles.e3.BackgroundColor=[1 1 0.7];
        
    case 'Mcverry2006'
        set(txt(1:6),'Visible','on');
        set(edi(1:6),'Visible','on');
        handles.t1.String='Mw';
        handles.t2.String='Rrup (km)';
        handles.t3.String='Hc(km)';
        handles.t4.String='Mechanism';
        handles.t5.String='Media';
        handles.t6.String='Rvol';
        handles.e1.String='7.0';
        handles.e2.String='90';
        handles.e3.String='50';
        handles.e4.Style='popupmenu'; handles.e4.Value=1; handles.e4.String={'interface','intraslab','normal','reverse','oblique','strike-slip'};
        handles.e5.Style='popupmenu'; handles.e5.Value=1; handles.e5.String={'A','B','C','D','E'};
        handles.e6.String='0';
        handles.e1.BackgroundColor=[1 1 0.7];
        handles.e2.BackgroundColor=[1 1 0.7];
        handles.e3.BackgroundColor=[1 1 0.7];
        
    case 'ContrerasBoroschek2012'
        set(txt(1:4),'Visible','on');
        set(edi(1:4),'Visible','on');
        handles.t1.String='Mw';
        handles.t2.String='Rrup (km)';
        handles.t3.String='Zhyp (km)';
        handles.t4.String='Media';
        handles.e1.String='7.0';
        handles.e2.String='90';
        handles.e3.String='50';
        handles.e4.Style='popupmenu'; handles.e4.Value=1; handles.e4.String={'rock','soil'};
        handles.e1.BackgroundColor=[1 1 0.7];
        handles.e2.BackgroundColor=[1 1 0.7];
        handles.e3.BackgroundColor=[1 1 0.7];
        
    case 'BCHydro2012'
        set(txt(1:7),'Visible','on');
        set(edi(1:7),'Visible','on');
        handles.t1.String='Mw';
        handles.t2.String='Rrup (km)';
        handles.t3.String='Zhyp (km)';
        handles.t4.String='Mechanism';
        handles.t5.String='Region';
        handles.t6.String='DeltaC1';
        handles.t7.String='Vs30 (m/s)';
        handles.e1.String='7.0';
        handles.e2.String='90';
        handles.e3.String='50';
        handles.e4.Style='popupmenu'; handles.e4.Value=1; handles.e4.String={'interface','intraslab'};
        handles.e5.Style='popupmenu'; handles.e5.Value=1; handles.e5.String={'forearc','backarc','unkown'};
        handles.e6.Style='popupmenu'; handles.e6.Value=2; handles.e6.String={'lower','central','upper','none'};
        handles.e7.String='760';
        handles.e1.BackgroundColor=[1 1 0.7];
        handles.e2.BackgroundColor=[1 1 0.7];
        handles.e3.BackgroundColor=[1 1 0.7];
        
    case 'Arteta2018'
        set(txt(1:4),'Visible','on');
        set(edi(1:4),'Visible','on');
        handles.t1.String='Mw';
        handles.t2.String='Rhyp (km)';
        handles.t3.String='Media';
        handles.t4.String='Region';
        handles.e1.String='7.0';
        handles.e2.String='90';
        handles.e3.Style='popupmenu'; handles.e3.Value=1; handles.e3.String={'rock','soil'};
        handles.e4.Style='popupmenu'; handles.e4.Value=1; handles.e4.String={'forearc','backarc'};
        handles.e1.BackgroundColor=[1 1 0.7];
        handles.e2.BackgroundColor=[1 1 0.7];
        
    case 'Idini2016'
        set(txt(1:6),'Visible','on');
        set(edi(1:6),'Visible','on');
        handles.t1.String='Mw';
        handles.t2.String='Rrup (km)';
        handles.t3.String='Zhyp (km)';
        handles.t4.String='Mechanism';
        handles.t5.String='Spectrum';
        handles.t6.String='Vs30 (m/s)';
        handles.e1.String='7.0';
        handles.e2.String='90';
        handles.e3.String='50';
        handles.e4.Style='popupmenu'; handles.e4.Value=1; handles.e4.String={'interface','intraslab'};
        handles.e5.Style='popupmenu'; handles.e5.Value=1; handles.e5.String={'si','sii','siii','siv','sv','svi'};
        handles.e6.String='760';
        handles.e1.BackgroundColor=[1 1 0.7];
        handles.e2.BackgroundColor=[1 1 0.7];
        handles.e3.BackgroundColor=[1 1 0.7];
        
    case 'MontalvaBastias2017'
        set(txt(1:6),'Visible','on');
        set(edi(1:6),'Visible','on');
        handles.t1.String='Mw';
        handles.t2.String='Rrup (km)';
        handles.t3.String='Zhyp (km)';
        handles.t4.String='Mechanism';
        handles.t5.String='Region';
        handles.t6.String='Vs30 (m/s)';
        handles.e1.String='7.0';
        handles.e2.String='90';
        handles.e3.String='50';
        handles.e4.Style='popupmenu'; handles.e4.Value=1; handles.e4.String={'interface','intraslab'};
        handles.e5.Style='popupmenu'; handles.e5.Value=1; handles.e5.String={'forearc','backarc','unkown'};
        handles.e6.String='760';
        handles.e1.BackgroundColor=[1 1 0.7];
        handles.e2.BackgroundColor=[1 1 0.7];
        handles.e3.BackgroundColor=[1 1 0.7];
        
    case 'SiberRisk2019'
        set(txt(1:5),'Visible','on');
        set(edi(1:5),'Visible','on');
        handles.t1.String='Mw';
        handles.t2.String='Rrup (km)';
        handles.t3.String='Zhyp (km)';
        handles.t4.String='Mechanism';
        handles.t5.String='Vs30 (m/s)';
        handles.e1.String='7.0';
        handles.e2.String='90';
        handles.e3.String='50';
        handles.e4.Style='popupmenu'; handles.e4.Value=1; handles.e4.String={'interface','intraslab'};
        handles.e5.String='760';
        handles.e1.BackgroundColor=[1 1 0.7];
        handles.e2.BackgroundColor=[1 1 0.7];
        handles.e3.BackgroundColor=[1 1 0.7];
        
    case 'Garcia2005'
        set(txt(1:5),'Visible','on');
        set(edi(1:5),'Visible','on');
        handles.t1.String='Mw';
        handles.t2.String='Rrup (km)';
        handles.t3.String='Rhyp (km)';
        handles.t4.String='H (km)';
        handles.t5.String='Direction';
        handles.e1.String='7.0';
        handles.e2.String='90';
        handles.e3.String='90';
        handles.e4.String='60';
        handles.e5.Style='popupmenu'; handles.e5.Value=1; handles.e5.String={'horizontal','vertical'};
        handles.e1.BackgroundColor=[1 1 0.7];
        handles.e2.BackgroundColor=[1 1 0.7];
        handles.e3.BackgroundColor=[1 1 0.7];
        handles.e4.BackgroundColor=[1 1 0.7];
        handles.e5.BackgroundColor=[1 1 0.7];
        
    case 'Jaimes2006'
        set(txt(1:2),'Visible','on');
        set(edi(1:2),'Visible','on');
        handles.t1.String='Mw';
        handles.t2.String='Rrup (km)';
        handles.e1.String='7.0';
        handles.e2.String='400';
        handles.e1.BackgroundColor=[1 1 0.7];
        handles.e2.BackgroundColor=[1 1 0.7];
        
    case 'Jaimes2015'
        set(txt(1:3),'Visible','on');
        set(edi(1:3),'Visible','on');
        handles.t1.String='Mw';
        handles.t2.String='Rrup (km)';
        handles.t3.String='Station';
        handles.e1.String='6.0';
        handles.e2.String='200';
        handles.e3.Style='popupmenu'; handles.e3.Value=1; handles.e3.String={'CU','SCT','CDAO'};
        handles.e1.BackgroundColor=[1 1 0.7];
        handles.e2.BackgroundColor=[1 1 0.7];
        handles.e3.BackgroundColor=[1 1 0.7];
        
    case 'Jaimes2016'
        set(txt(1:2),'Visible','on');
        set(edi(1:2),'Visible','on');
        handles.t1.String='Mw';
        handles.t2.String='Rrup (km)';
        handles.e1.String='3.0';
        handles.e2.String='10';
        handles.e1.BackgroundColor=[1 1 0.7];
        handles.e2.BackgroundColor=[1 1 0.7];
        
    case 'GarciaJaimes2017'
        set(txt(1:3),'Visible','on');
        set(edi(1:3),'Visible','on');
        handles.t1.String='Mw';
        handles.t2.String='Rrup (km)';
        handles.t3.String='Component';
        handles.e1.String='7.0';
        handles.e2.String='90';
        handles.e3.Style='popupmenu'; handles.e3.Value=2; handles.e3.String={'vertical','horizontal','h/v'};
        handles.e1.BackgroundColor=[1 1 0.7];
        handles.e2.BackgroundColor=[1 1 0.7];
        handles.e3.BackgroundColor=[1 1 0.7];
        
    case 'Bernal2014'
        set(txt(1:4),'Visible','on');
        set(edi(1:4),'Visible','on');
        handles.t1.String='Mw';
        handles.t2.String='Rrup (km)';
        handles.t3.String='Zhyp (km)';
        handles.t4.String='Mechanism';
        handles.e1.String='7.0';
        handles.e2.String='90';
        handles.e3.String='30';
        handles.e4.Style='popupmenu'; handles.e4.Value=1; handles.e4.String={'interface','intraslab'};

        handles.e1.BackgroundColor=[1 1 0.7];
        handles.e2.BackgroundColor=[1 1 0.7];
        handles.e3.BackgroundColor=[1 1 0.7];        
        handles.e4.BackgroundColor=[1 1 0.7];
end

%% SHALLOW CRUSTAL EARTHQUAKES
switch str
    case 'Sadigh1997'
        set(txt(1:4),'Visible','on');
        set(edi(1:4),'Visible','on');
        handles.t1.String='Mw';
        handles.t2.String='Rrup (km)';
        handles.t3.String='Mechanism';
        handles.t4.String='Media';
        handles.e1.String='7.0';
        handles.e2.String='50';
        handles.e3.Style='popupmenu'; handles.e3.Value=2; handles.e3.String={'reverse/thrust','strike-slip'};
        handles.e4.Style='popupmenu'; handles.e4.Value=1; handles.e4.String={'rock','deepsoil'};
        handles.e1.BackgroundColor=[1 1 0.7];
        handles.e2.BackgroundColor=[1 1 0.7];
        
    case 'AS1997h'
        set(txt(1:6),'Visible','on');
        set(edi(1:6),'Visible','on');
        handles.t1.String='Mw';
        handles.t2.String='Rrup (km)';
        handles.t3.String='Media';
        handles.t4.String='Mechanism';
        handles.t5.String='Location';
        handles.t6.String='Sigma Type';
        handles.e1.String='7.0';
        handles.e2.String='50';
        handles.e3.Style='popupmenu'; handles.e3.Value=1; handles.e3.String={'rock','deepsoil'};
        handles.e4.Style='popupmenu'; handles.e4.Value=1; handles.e4.String={'strike-slip','normal','normal-oblique','reverse','reverse-oblique','thrust'};
        handles.e5.Style='popupmenu'; handles.e5.Value=1; handles.e5.String={'hangingwall','footwall','other'};
        handles.e6.Style='popupmenu'; handles.e6.Value=1; handles.e6.String={'arbitrary','average'};
        handles.e1.BackgroundColor=[1 1 0.7];
        handles.e2.BackgroundColor=[1 1 0.7];
        
    case 'Campbell1997h'
        set(txt(1:7),'Visible','on');
        set(edi(1:7),'Visible','on');
        handles.t1.String='Mw';
        handles.t2.String='Rrup (km)';
        handles.t3.String='Media';
        handles.t4.String='Mechanism';
        handles.t5.String='Basement depth';
        handles.t6.String='Seismogenic zone';
        handles.t7.String='Sigma Type';
        handles.e1.String='7.0';
        handles.e2.String='50';
        handles.e3.Style='popupmenu'; handles.e3.Value=1; handles.e3.String={'hardrock','softrock','soil'};
        handles.e4.Style='popupmenu'; handles.e4.Value=1; handles.e4.String={'strike-slip','normal','normal-oblique','reverse','reverse-oblique','thrust'};
        handles.e5.String='2';
        handles.e6.String='3';
        handles.e7.Style='popupmenu'; handles.e7.Value=1; handles.e7.String={'arbitrary','average'};
        handles.e1.BackgroundColor=[1 1 0.7];
        handles.e2.BackgroundColor=[1 1 0.7];
end

%% NGA2008
switch str
    case 'Idriss2008_nga'
        set(txt(1:4),'Visible','on');
        set(edi(1:4),'Visible','on');
        handles.t1.String='Mw';
        handles.t2.String='Rrup (km)';
        handles.t3.String='Mechanism';
        handles.t4.String='Vs30 (m/s)';
        handles.e1.String='7.0';
        handles.e2.String='50';
        handles.e3.Style='popupmenu'; handles.e3.Value=1; handles.e3.String={'strike-slip','reverse'};
        handles.e4.String='760';
        handles.e1.BackgroundColor=[1 1 0.7];
        handles.e2.BackgroundColor=[1 1 0.7];
        
    case 'ChiouYoungs2008_nga'
        set(txt(1:11),'Visible','on');
        set(edi(1:11),'Visible','on');
        handles.t1.String='Mw';
        handles.t2.String='Rrup (km)';
        handles.t3.String='Rjb (km)';
        handles.t4.String='Rx (km)';
        handles.t5.String='Ztor (km)';
        handles.t6.String='Dip (°)';
        handles.t7.String='Z1.0 (m)';
        handles.t8.String='Mechanism';
        handles.t9.String='Event';
        handles.t10.String='Vs30 (m/s)';
        handles.t11.String='VS30 type';
        handles.e1.String='7.0';
        handles.e2.String='50';
        handles.e3.String='50';
        handles.e4.String='50';
        handles.e5.String='3';
        handles.e6.String='90';
        handles.e7.String='unk';
        handles.e8.Style='popupmenu'; handles.e8.Value=1; handles.e8.String={'strike-slip','normal','normal-oblique','reverse','reverse-oblique','thrust'};
        handles.e9.Style='popupmenu'; handles.e9.Value=1; handles.e9.String={'mainshock','aftershock'};
        handles.e10.String='760';
        handles.e11.Style='popupmenu'; handles.e11.Value=1; handles.e11.String={'measured','inferred'};
        handles.e1.BackgroundColor=[1 1 0.7];
        handles.e2.BackgroundColor=[1 1 0.7];
        handles.e3.BackgroundColor=[1 1 0.7];
        handles.e4.BackgroundColor=[1 1 0.7];
        handles.e5.BackgroundColor=[1 1 0.7];
        handles.e6.BackgroundColor=[1 1 0.7];
        
    case 'BooreAtkinson_2008_nga'
        set(txt(1:4),'Visible','on');
        set(edi(1:4),'Visible','on');
        handles.t1.String='Mw';
        handles.t2.String='Rjb (km)';
        handles.t3.String='Mechanism';
        handles.t4.String='Vs30 (m/s)';
        handles.e1.String='7.0';
        handles.e2.String='50';
        handles.e3.Style='popupmenu'; handles.e3.Value=2; handles.e3.String={'unspecified','strike-slip','normal','reverse'};
        handles.e4.String='760';
        handles.e1.BackgroundColor=[1 1 0.7];
        handles.e2.BackgroundColor=[1 1 0.7];
        
    case 'CampbellBozorgnia_2008_nga'
        set(txt(1:9),'Visible','on');
        set(edi(1:9),'Visible','on');
        handles.t1.String='Mw';
        handles.t2.String='Rrup (km)';
        handles.t3.String='Rjb (km)';
        handles.t4.String='Ztor (km)';
        handles.t5.String='Dip (°)';
        handles.t6.String='Mechanism';
        handles.t7.String='Vs30 (m/s)';
        handles.t8.String='Z2.5 (km)';
        handles.t9.String='Sigma Type';
        handles.e1.String='7.0';
        handles.e2.String='50';
        handles.e3.String='50';
        handles.e4.String='3';
        handles.e5.String='90';
        handles.e6.Style='popupmenu'; handles.e6.Value=1; handles.e6.String={'strike-slip','normal','normal-oblique','reverse','reverse-oblique','thrust'};
        handles.e7.String='760';
        handles.e8.String='5';
        handles.e9.Style='popupmenu'; handles.e9.Value=1; handles.e9.String={'arbitrary','average'};
        handles.e1.BackgroundColor=[1 1 0.7];
        handles.e2.BackgroundColor=[1 1 0.7];
        handles.e3.BackgroundColor=[1 1 0.7];
        handles.e4.BackgroundColor=[1 1 0.7];
        handles.e5.BackgroundColor=[1 1 0.7];
        
    case 'AbrahamsonSilva2008_nga'
        set(txt(1:12),'Visible','on');
        set(edi(1:12),'Visible','on');
        handles.t1.String='Mw';
        handles.t2.String='Rrup (km)';
        handles.t3.String='Rjb (km)';
        handles.t4.String='Rx (km)';
        handles.t5.String='Ztor (km)';
        handles.t6.String='Dip (°)';
        handles.t7.String='W (km)';
        handles.t8.String='Z1.0 (m)';
        handles.t9.String='Vs30 (m/s)';
        handles.t10.String='Mechanism';
        handles.t11.String='Event';
        handles.t12.String='VS30 type';
        handles.e1.String='7.0';
        handles.e2.String='50';
        handles.e3.String='50';
        handles.e4.String='50';
        handles.e5.String='3';
        handles.e6.String='90';
        handles.e7.String='10';
        handles.e8.String= 'unk';
        handles.e9.String='760';
        handles.e10.Style='popupmenu'; handles.e10.Value=1; handles.e10.String={'strike-slip','normal','normal-oblique','reverse','reverse-oblique','thrust'};
        handles.e11.Style='popupmenu'; handles.e11.Value=2; handles.e11.String={'aftershock','mainshock','foreshock','swarms'};
        handles.e12.Style='popupmenu'; handles.e12.Value=1; handles.e12.String={'measured','inferred'};
        handles.e1.BackgroundColor=[1 1 0.7];
        handles.e2.BackgroundColor=[1 1 0.7];
        handles.e3.BackgroundColor=[1 1 0.7];
        handles.e4.BackgroundColor=[1 1 0.7];
        handles.e5.BackgroundColor=[1 1 0.7];
        handles.e6.BackgroundColor=[1 1 0.7];
        handles.e7.BackgroundColor=[1 1 0.7];
end

%% NGA2014
switch str
    case 'I_2014_nga'
        set(txt(1:4),'Visible','on');
        set(edi(1:4),'Visible','on');
        handles.t1.String='Mw';
        handles.t2.String='Rrup (km)';
        handles.t3.String='Mechanism';
        handles.t4.String='Vs30 (m/s)';
        handles.e1.String='7.0';
        handles.e2.String='50';
        handles.e3.Style='popupmenu'; handles.e3.Value=1; handles.e3.String={'strike-slip','reverse'};
        handles.e4.String='760';
        handles.e1.BackgroundColor=[1 1 0.7];
        handles.e2.BackgroundColor=[1 1 0.7];
        
    case 'CY_2014_nga'
        set(txt(1:11),'Visible','on');
        set(edi(1:11),'Visible','on');
        handles.t1.String='Mw';
        handles.t2.String='Rrup (km)';
        handles.t3.String='Rjb (km)';
        handles.t4.String='Rx (km)';
        handles.t5.String='Ztor (km)';
        handles.t6.String='Dip (°)';
        handles.t7.String='Mechanism';
        handles.t8.String='Z1.0 (km)';
        handles.t9.String='Vs30 (m/s)';
        handles.t10.String='VS30 Type';
        handles.t11.String='Region';
        handles.e1.String='7.0';
        handles.e2.String='50';
        handles.e3.String='50';
        handles.e4.String='50';
        handles.e5.String='3';
        handles.e6.String='90';
        handles.e7.Style='popupmenu'; handles.e7.Value=1; handles.e7.String={'strike-slip','normal','normal-oblique','reverse','reverse-oblique','thrust'};
        handles.e8.String='unk';
        handles.e9.String='760';
        handles.e10.Style='popupmenu'; handles.e10.Value=1; handles.e10.String={'measured','inferred'};
        handles.e11.Style='popupmenu'; handles.e11.Value=1; handles.e11.String={'global','california','japan','china','italy','turkey'};
        handles.e1.BackgroundColor=[1 1 0.7];
        handles.e2.BackgroundColor=[1 1 0.7];
        handles.e3.BackgroundColor=[1 1 0.7];
        handles.e4.BackgroundColor=[1 1 0.7];
        handles.e5.BackgroundColor=[1 1 0.7];
        handles.e6.BackgroundColor=[1 1 0.7];
        
    case 'BSSA_2014_nga'
        set(txt(1:6),'Visible','on');
        set(edi(1:6),'Visible','on');
        % M, rjb, mechanism, reg, z1, Vs30
        handles.t1.String='Mw';
        handles.t2.String='Rjb (km)';
        handles.t3.String='Mechanism';
        handles.t4.String='Region';
        handles.t5.String='Basin Depth';
        handles.t6.String='Vs30 (m/s)';
        handles.e1.String='7.0';
        handles.e2.String='50';
        handles.e3.Style='popupmenu'; handles.e3.Value=2; handles.e3.String={'unspecified','strike-slip','normal','reverse'};
        handles.e4.Style='popupmenu'; handles.e4.Value=1; handles.e4.String={'global','california','japan','china','italy','turkey'};
        handles.e5.String='unk';
        handles.e6.String='760';
        handles.e1.BackgroundColor=[1 1 0.7];
        handles.e2.BackgroundColor=[1 1 0.7];
        
    case 'CB_2014_nga'
        set(txt(1:14),'Visible','on');
        set(edi(1:14),'Visible','on');
        handles.t1.String='Mw';
        handles.t2.String='Rrup (km)';
        handles.t3.String='Rjb (km)';
        handles.t4.String='Rx (km)';
        handles.t5.String='W (km)';
        handles.t6.String='Ztor (km)';
        handles.t7.String='Zbot (km)';
        handles.t8.String='Dip (°)';
        handles.t9.String='Mechanism';
        handles.t10.String='HW Effect';
        handles.t11.String='Vs30 (m/s)';
        handles.t12.String='Z2.5 (km)';
        handles.t13.String='Zhyp (km)';
        handles.t14.String='Region';
        handles.e1.String='7.0';
        handles.e2.String='50';
        handles.e3.String='50';
        handles.e4.String='50';
        handles.e5.String='12';
        handles.e6.String='3';
        handles.e7.String='9';
        handles.e8.String='90';
        handles.e9.Style ='popupmenu'; handles.e9.Value=1; handles.e9.String={'strike-slip','normal','normal-oblique','reverse','reverse-oblique','thrust'};
        handles.e10.Style ='popupmenu'; handles.e10.Value=1; handles.e10.String={'Include';'Exclude'};
        handles.e11.String='760';
        handles.e12.String='5';
        handles.e13.String='6';
        handles.e14.Style='popupmenu'; handles.e14.Value=1; handles.e14.String={'global','california','japan','china','italy','turkey'};
        handles.e1.BackgroundColor=[1 1 0.7];
        handles.e2.BackgroundColor=[1 1 0.7];
        handles.e3.BackgroundColor=[1 1 0.7];
        handles.e4.BackgroundColor=[1 1 0.7];
        handles.e5.BackgroundColor=[1 1 0.7];
        handles.e6.BackgroundColor=[1 1 0.7];
        handles.e7.BackgroundColor=[1 1 0.7];
        handles.e8.BackgroundColor=[1 1 0.7];
        
    case 'ASK_2014_nga'
        set(txt(1:14),'Visible','on');
        set(edi(1:14),'Visible','on');
        handles.t1.String='Mw';
        handles.t2.String='Rrup (km)';
        handles.t3.String='Rjb (km)';
        handles.t4.String='Rx (km)';
        handles.t5.String='Ry0(km)';
        handles.t6.String='Ztor (km)';
        handles.t7.String='Dip (°)';
        handles.t8.String='W (km)';
        handles.t9.String='Mechanism';
        handles.t10.String='Event';
        handles.t11.String='Z1.0 (km)';
        handles.t12.String='Vs30 (m/s)';
        handles.t13.String='VS30 type';
        handles.t14.String='Region';
        handles.e1.String='7.0';
        handles.e2.String='50';
        handles.e3.String='50';
        handles.e4.String='50';
        handles.e5.String='50';
        handles.e6.String='3';
        handles.e7.String='90';
        handles.e8.String='12';
        handles.e9.Style='popupmenu';  handles.e9.Value=1;  handles.e9.String={'strike-slip','normal','normal-oblique','reverse','reverse-oblique','thrust'};
        handles.e10.Style='popupmenu'; handles.e10.Value=1; handles.e10.String={'mainshock','aftershock'};
        handles.e11.String='unk';
        handles.e12.String='760';
        handles.e13.Style='popupmenu'; handles.e13.Value=1; handles.e13.String={'measured','inferred'};
        handles.e14.Style='popupmenu'; handles.e14.Value=1; handles.e14.String={'global','california','japan','china','italy','turkey'};
        handles.e1.BackgroundColor=[1 1 0.7];
        handles.e2.BackgroundColor=[1 1 0.7];
        handles.e3.BackgroundColor=[1 1 0.7];
        handles.e4.BackgroundColor=[1 1 0.7];
        handles.e5.BackgroundColor=[1 1 0.7];
        handles.e6.BackgroundColor=[1 1 0.7];
        handles.e7.BackgroundColor=[1 1 0.7];
        handles.e8.BackgroundColor=[1 1 0.7];
        
end

%% CAV MODELS - 
switch str
case 'DW12'
        set(txt(1:4),'Visible','on');
        set(edi(1:4),'Visible','on');
        handles.t1.String='Mw';
        handles.t2.String='Rrup (km)';
        handles.t3.String='Mechanism';
        handles.t4.String='Media';
        
        handles.e1.String='7.0';
        handles.e2.String='50';
        handles.e3.Style='popupmenu'; handles.e3.Value=1; handles.e3.String={'strike-slip','normal','normal-oblique','reverse','reverse-oblique','thrust'};
        handles.e4.Style='popupmenu'; handles.e4.Value=1; handles.e4.String={'sgs-b','sgs-c','sgs-d'};
        
        handles.e1.BackgroundColor=[1 1 0.7];
        handles.e2.BackgroundColor=[1 1 0.7];
        handles.e3.BackgroundColor=[1 1 0.7];
        handles.e4.BackgroundColor=[1 1 0.7];
        
        handles.rad1.Value=0;
        handles.rad2.Value=1;    
    
case 'FG15'
        set(txt(1:8),'Visible','on');
        set(edi(1:8),'Visible','on');
        handles.t1.String='Mw';
        handles.t2.String='Rrup (km)';
        handles.t3.String='H (km)';
        handles.t4.String='Mechanism';
        handles.t5.String='Style';
        handles.t6.String='Vs30';
        handles.t7.String='Region';
        handles.t8.String='Model';
        
        handles.e1.String='7.0';
        handles.e2.String='50';
        handles.e3.String='15';
        handles.e4.Style='popupmenu'; handles.e4.Value=1; handles.e4.String={'inslab','interface','crustal'};
        handles.e5.Style='popupmenu'; handles.e5.Value=1; handles.e5.String={'reverse','normal'};
        handles.e6.String='760';
        handles.e7.Style='popupmenu'; handles.e7.Value=1; handles.e7.String={'forearc','backarc','other'};
        handles.e8.Style='popupmenu'; handles.e8.Value=1; handles.e8.String={'linear','nonlinear'};
        
        handles.e1.BackgroundColor=[1 1 0.7];
        handles.e2.BackgroundColor=[1 1 0.7];
        handles.e3.BackgroundColor=[1 1 0.7];
        handles.e4.BackgroundColor=[1 1 0.7];
        
        handles.rad1.Value=0;
        handles.rad2.Value=1;         
        
end
    

%% user defined models
switch str
    case 'udm'
        
end
