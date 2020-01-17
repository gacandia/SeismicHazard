function[param]=mGMPErrupLoop(fun,Rrup,param)

str  = func2str(fun);
ON   = ones(size(Rrup));

switch str

    case 'Youngs1997'
        param{1}=ON*param{1}; %Mw
        param{2}=Rrup;
        param{3}=ON*param{3}; %H
        
    case 'AtkinsonBoore2003'
        param{1}=ON*param{1}; %Mw
        param{2}=Rrup;
        param{3}=ON*param{3}; %H
        
    case 'Zhao2006'
        param{1}=ON*param{1}; %Mw
        param{2}=Rrup;
        param{3}=ON*param{3}; %H
        
    case 'Mcverry2006'
        param{1}=ON*param{1}; %Mw
        param{2}=Rrup;
        param{3}=ON*param{3}; %H
        
    case 'ContrerasBoroschek2012'
        param{1}=ON*param{1}; %Mw
        param{2}=Rrup;
        param{3}=ON*param{3}; %H
        
    case 'BCHydro2012'
        param{1}=ON*param{1}; %Mw
        param{2}=Rrup;
        param{3}=ON*param{3}; %H
        
    case 'Arteta2018'
        param{1}=ON*param{1}; %Mw
        param{2}=Rrup;
        
    case 'Idini2016'
        param{1}=ON*param{1}; %Mw
        param{2}=Rrup;
        param{3}=ON*param{3}; %H
        
    case 'MontalvaBastias2017'
        param{1}=ON*param{1}; %Mw
        param{2}=Rrup;
        param{3}=ON*param{3}; %H
        
    case 'SiberRisk2019'
        param{1}=ON*param{1}; %Mw
        param{2}=Rrup;
        param{3}=ON*param{3}; %H
        
    case 'Garcia2005'
        param{1}=ON*param{1}; %Mw
        param{2}=Rrup;
        param{3}=Rrup;        %Rhyp
        param{4}=ON*param{4}; %H
    
    case 'Jaimes2006'
        param{1}=ON*param{1}; %Mw
        param{2}=Rrup;
        
    case 'Jaimes2015'
        param{1}=ON*param{1}; %Mw
        param{2}=Rrup;
        
    case 'Jaimes2016'
        param{1}=ON*param{1}; %Mw
        param{2}=Rrup;
        
    case 'GarciaJaimes2017'
        param{1}=ON*param{1}; %Mw
        param{2}=Rrup;
        
    case 'Bernal2014'
        param{1}=ON*param{1}; %Mw
        param{2}=Rrup;
        param{3}=ON*param{3}; %H
        
    case 'Sadigh1997'
        param{1}=ON*param{1}; %Mw
        param{2}=Rrup;
        
    case 'Idriss2008_nga'
        param{1}=ON*param{1}; %Mw
        param{2}=Rrup;
        
    case 'ChiouYoungs2008_nga'
        param{1}=ON*param{1}; %Mw
        param{2}=Rrup;
        param{3}=ON*param{3}; %Rjb
        param{4}=ON*param{4}; %Rx
        param{5}=ON*param{5}; %Ztor
        
    case 'BooreAtkinson_2008_nga'
        param{1}=ON*param{1}; %Mw
        param{2}=Rrup;
        
    case 'CampbellBozorgnia_2008_nga'
        param{1}=ON*param{1}; %Mw
        param{2}=Rrup;
        param{3}=ON*param{3}; %Rjb
        param{4}=ON*param{4}; %Ztor
        
    case 'AbrahamsonSilva2008_nga'
        %M, Rrup, Rjb, Rx, Ztor, dip,W, Z10, Vs30,mechanism, event, Vs30type
        param{1}=ON*param{1}; %Mw
        param{2}=Rrup;
        param{3}=ON*param{3}; %Rjb
        param{4}=ON*param{4}; %Rx
        param{5}=ON*param{5}; %Rx

    case 'AS1997h'
        param{1}=ON*param{1}; %Mw
        param{2}=Rrup;
        
    case 'Campbell1997h'
        param{1}=ON*param{1}; %Mw
        param{2}=Rrup;

    case 'I_2014_nga'
        param{1}=ON*param{1}; %Mw
        param{2}=Rrup;
        
    case 'CY_2014_nga'
        %M, Rup, Rjb, Rx, Ztor, delta, mechanism, Z10, Vs30, Vs30type, region
        param{1}=ON*param{1}; %Mw
        param{2}=Rrup;
        param{3}=ON*param{3}; %Rjb
        param{4}=ON*param{4}; %Rx
        param{5}=ON*param{5}; %Ztor
        
    case 'CB_2014_nga'
        %M, Rrup, Rjb, Rx, W, Ztor, Zbot, Zhyp, delta, mechanism, Fhw, Vs30, Z25, reg
        param{1}=ON*param{1}; %Mw
        param{2}=Rrup;
        param{3}=ON*param{3}; %Rjb
        param{4}=ON*param{4}; %Rx
        param{6}=ON*param{6}; %Ztor
        param{7}=ON*param{7}; %Zbot
        param{8}=ON*param{8}; %Zhyp
        
    case 'BSSA_2014_nga'
        param{1}=ON*param{1}; %Mw
        param{2}=Rrup;

    case 'ASK_2014_nga'
        %M, Rrup, Rjb, Rx, Ry0, Ztor, delta, mechanism, event, W, Z10, Vs30, Vs30type, reg
        param{1}=ON*param{1}; %Mw
        param{2}=Rrup;
        param{3}=ON*param{3}; %Rjb
        param{4}=ON*param{4}; %Rx
        param{5}=ON*param{5}; %Ry0
        param{6}=ON*param{6}; %Ztor
        
    case 'DW12'
        param{1}=ON*param{1}; %Mw
        param{2}=Rrup;
        
    case 'FG15'
        param{1}=ON*param{1}; %Mw
        param{2}=Rrup;        
        param{3}=ON*param{3}; %Mw
        

end